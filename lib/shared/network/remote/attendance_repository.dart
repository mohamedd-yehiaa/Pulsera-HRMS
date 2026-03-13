import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/services/attendance_service.dart';
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

  /// Fetches all attendance day documents for [userId] in the given [yearMonth].
  Future<List<Map<String, dynamic>>> fetchAttendanceForMonth(
      String userId,
      String yearMonth,
      ) async {
    final snapshot = await _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$yearMonth-01')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '$yearMonth-31')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> logAction({
    required String userId,
    required String activityId,
    required UserPerformActivty action,
    required String companyId,
  }) async {
    // Don't process DONE action — it's a display-only state
    if (action == UserPerformActivty.DONE) return;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .doc(todayStr);

    final timeNow = DateFormat("HH:mm:ss").format(DateTime.now());

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      // --- Validation ---
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final existingCheckIn = data['checkIn']?['inTime'] as String?;
        final existingCheckOut = data['outTime']?['outTime'] as String?;

        final error = AttendanceService.validateAction(
          action: action.name,
          existingCheckIn: existingCheckIn,
          existingCheckOut: existingCheckOut,
          timeNow: timeNow,
        );

        if (error != null) {
          throw Exception(error);
        }
      } else if (action != UserPerformActivty.IN) {
        throw Exception('Cannot perform ${action.name} without checking in first.');
      }

      // --- Write ---
      if (action == UserPerformActivty.IN) {
        transaction.set(docRef, {
          'activityID': activityId,
          'userID': userId,
          'companyID': companyId,
          'date': todayStr,
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