import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pulsera/shared/network/remote/notification_repository.dart';

/// Top-level background handler — must be a top-level function.
///
/// Called by the OS when an FCM data message arrives while the app is
/// terminated or in the background. Firebase handles displaying the
/// notification automatically for messages with a `notification` payload,
/// so this handler is primarily for data-only messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op: Firebase automatically displays notification-payload messages.
  // The Firestore stream in NotificationCubit will sync the notification
  // data when the app is next opened.
  debugPrint('[FCM] Background message received: ${message.messageId}');
}

/// Manages all FCM-related functionality:
/// - Local notification display (foreground)
/// - FCM token lifecycle (save/refresh/remove)
/// - Permission requests
///
/// Does NOT replace or duplicate any existing notification logic.
/// The existing [NotificationCubit] + [NotificationRepository] Firestore
/// stream remains the single source of truth for in-app notifications.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final NotificationRepository _repository = NotificationRepository();

  String? _currentUserId;
  String? _currentToken;

  // ---------------------------------------------------------------------------
  // Android notification channel
  // ---------------------------------------------------------------------------

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'pulsera_notifications',
        'Pulsera Notifications',
        description: 'Push notifications for Pulsera HRMS',
        importance: Importance.high,
      );

  // ---------------------------------------------------------------------------
  // One-time local-notification plugin setup (called from main before runApp)
  // ---------------------------------------------------------------------------

  /// Initializes the local notification plugin and creates the Android channel.
  /// Must be called once at app startup, before the widget tree is built.
  static Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the Android notification channel.
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }

    // Tell Firebase to show foreground alerts
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true, // to show the banner while app is open
          badge: true,
          sound: true, // to play the sound while app is open
        );
  }

  /// Called when the user taps a local notification (foreground-displayed).
  /// Navigation to NotificationsScreen is handled by the widget layer via
  /// the initial-message / onMessageOpenedApp callbacks.
  static void _onNotificationTap(NotificationResponse response) {
    // Navigation is handled in [initialize] via onMessageOpenedApp and
    // getInitialMessage. This callback is for foreground-displayed local
    // notifications — the payload can be used for navigation if needed.
    debugPrint('[FCM] Local notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Full initialization (called after user authentication)
  // ---------------------------------------------------------------------------

  /// Sets up FCM for the authenticated user:
  /// 1. Requests notification permission
  /// 2. Retrieves and stores the FCM token
  /// 3. Listens for token refreshes
  /// 4. Listens for foreground messages
  /// 5. Sets up notification-tap handling (background + terminated)
  ///
  /// [onNotificationTap] is called when the user taps a notification and the
  /// app needs to navigate. The caller (widget layer) provides the navigation
  /// callback since this service has no access to BuildContext/Navigator.
  Future<void> initialize(
    String userId, {
    void Function()? onNotificationTap,
  }) async {
    _currentUserId = userId;

    // 1. Request permission (iOS will show the system prompt; Android auto-grants)
    await _requestPermission();

    // 2. Get and save the FCM token
    await _getAndSaveToken();

    // 3. Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      _saveToken(newToken);
    });

    // 4. Foreground message listener — display local notification
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // 5. Handle notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] onMessageOpenedApp: ${message.messageId}');
      onNotificationTap?.call();
    });

    // 6. Handle notification tap when app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] getInitialMessage: ${initialMessage.messageId}');
      onNotificationTap?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup (called on logout)
  // ---------------------------------------------------------------------------

  /// Removes the FCM token from Firestore so the device stops receiving
  /// push notifications for this user. Called during logout.
  Future<void> cleanup() async {
    if (_currentUserId != null && _currentToken != null) {
      await _repository.removeFcmToken(_currentUserId!, _currentToken!);
    }
    _currentUserId = null;
    _currentToken = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    _currentToken = token;
    if (_currentUserId != null) {
      await _repository.saveFcmToken(_currentUserId!, token);
    }
    debugPrint('[FCM] Token saved for user $_currentUserId');
  }

  /// Displays a local notification for an FCM message received while the
  /// app is in the foreground. Uses the same channel as background messages.
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['notificationId'],
    );
  }
}
