import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a notification document in Firestore.
  Future<void> addNotification({
    required String toUserId,
    required String fromUserName,
    required String message,
    String? messageKey,
    Map<String, dynamic>? messageParams,
    required String type,
    String? leaveId,
  }) async {
    await _firestore.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'message': message,
      'messageKey': messageKey,
      'messageParams': messageParams,
      'type': type,
      'leaveId': leaveId,
      'createdAt': DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      'isRead': false,
    });
  }

  /// Real-time stream of notifications for a user, ordered by most recent.
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var model = NotificationModel.fromJson(doc.data());
        model.id = doc.id;
        return model;
      }).toList();
    });
  }

  /// Marks a notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Marks all unread notifications for a user as read.
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Deletes all notifications for a user.
  Future<void> clearAllNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
