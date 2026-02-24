import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/user_activity_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for Real-time updates
  Stream<UserActivityModel?> watchUserActivity(String userId, String date) {
    return _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .doc(date)
        .snapshots()
        .map((doc) => doc.exists ? UserActivityModel.fromJson(doc.data()!) : null);
  }

  Future<void> logAction({
    required String userId,
    required String activityId,
    required UserPerformActivty action,
    required String companyId,
  }) async {
    final docRef = _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()));

    final timeNow = DateFormat("HH:mm:ss").format(DateTime.now());

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (action == UserPerformActivty.IN) {
        transaction.set(docRef, {
          'activityID': activityId,
          'userID': userId,
          'companyID': companyId,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'checkIn': {'inTime': timeNow, 'msg': 'Started Day'},
          'breakInTime': [],
          'breakOutTime': [],
        });
      } else {
        Map<String, dynamic> updateData = {};
        if (action == UserPerformActivty.BREAKIN) {
          updateData['breakInTime'] = FieldValue.arrayUnion([timeNow]);
        } else if (action == UserPerformActivty.BREAKOUT) {
          updateData['breakOutTime'] = FieldValue.arrayUnion([timeNow]);
        } else if (action == UserPerformActivty.OUT) {
          updateData['outTime'] = {'outTime': timeNow, 'msg': 'Ended Day'};
        }
        transaction.update(docRef, updateData);
      }
    });
  }
}