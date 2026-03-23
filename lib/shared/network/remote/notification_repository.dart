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
    required String type,
    String? leaveId,
  }) async {
    await _firestore.collection('notifications').add({
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'message': message,
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
}
