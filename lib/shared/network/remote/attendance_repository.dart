import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/services/attendance_service.dart';
import '../../../models/user_activity_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // Real-time streams
  // ===========================================================================

  /// Stream for a single user's attendance on a given date.
  Stream<UserActivityModel?> watchUserActivity(String userId, String date) {
    return _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .doc(date)
        .snapshots()
        .map((doc) => doc.exists ? UserActivityModel.fromJson(doc.data()!) : null);
  }

  // ===========================================================================
  // Fetch methods
  // ===========================================================================

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

  /// Fetches attendance for all employees in a team for a specific date.
  /// Uses `teamId` field stored in attendance docs.
  Future<List<Map<String, dynamic>>> fetchTeamAttendanceForDate(
      String managerId,
      String date,
      ) async {
    // Query all attendance_logs subcollections is not directly possible
    // in Firestore without a collection group query.
    // We use a collectionGroup query on 'days' filtered by teamId and date.
    final snapshot = await _firestore
        .collectionGroup('days')
        .where('teamId', isEqualTo: managerId)
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return data;
    }).toList();
  }

  // ===========================================================================
  // Employee actions (check-in/out, breaks)
  // ===========================================================================

  /// Logs a check-in, check-out, or break action for an employee.
  ///
  /// On check-in: stores `teamId` and `companyId` for team-scoped queries.
  /// On check-out: computes and stores `workedMinutes` and `status`.
  Future<void> logAction({
    required String userId,
    required String activityId,
    required UserPerformActivty action,
    required String companyId,
    String? teamId,
    String? companyStartTime,
    int lateGracePeriodMinutes = 0,
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
        final breakInTimes = (data['breakInTime'] as List<dynamic>?)?.cast<String>();
        final breakOutTimes = (data['breakOutTime'] as List<dynamic>?)?.cast<String>();

        final error = AttendanceService.validateAction(
          action: action.name,
          existingCheckIn: existingCheckIn,
          existingCheckOut: existingCheckOut,
          timeNow: timeNow,
          breakInTimes: breakInTimes,
          breakOutTimes: breakOutTimes,
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
          if (teamId != null) 'teamId': teamId,
        });
      } else {
        Map<String, dynamic> updateData = {};
        if (action == UserPerformActivty.BREAKIN) {
          updateData['breakInTime'] = FieldValue.arrayUnion([timeNow]);
        } else if (action == UserPerformActivty.BREAKOUT) {
          updateData['breakOutTime'] = FieldValue.arrayUnion([timeNow]);
        } else if (action == UserPerformActivty.OUT) {
          updateData['outTime'] = {'outTime': timeNow, 'msg': 'Ended Day'};

          // Compute and store worked minutes and status on check-out
          final data = snapshot.data() ?? {};
          final checkInTime = data['checkIn']?['inTime'] as String?;
          final breakInTimes = (data['breakInTime'] as List<dynamic>?)?.cast<String>();
          final breakOutTimes = (data['breakOutTime'] as List<dynamic>?)?.cast<String>();

          if (checkInTime != null) {
            final workedMinutes = AttendanceService.calculateWorkedMinutesOnCheckOut(
              checkInTime: checkInTime,
              checkOutTime: timeNow,
              breakInTimes: breakInTimes,
              breakOutTimes: breakOutTimes,
            );
            updateData['workedMinutes'] = workedMinutes;

            // Determine attendance status (late or present)
            if (companyStartTime != null) {
              final status = AttendanceService.determineAttendanceStatus(
                checkInTime: checkInTime,
                companyStartTime: companyStartTime,
                graceMinutes: lateGracePeriodMinutes,
              );
              updateData['status'] = status;
            }
          }
        }
        transaction.update(docRef, updateData);
      }
    });
  }

  // ===========================================================================
  // Admin operations
  // ===========================================================================

  /// Updates an attendance record for a given user and date.
  /// Used by admins to modify check-in/out times, status, or worked hours.
  Future<void> updateAttendanceRecord({
    required String userId,
    required String date,
    required Map<String, dynamic> updates,
  }) async {
    final docRef = _firestore
        .collection('attendance_logs')
        .doc(userId)
        .collection('days')
        .doc(date);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('No attendance record found for $date.');
      }

      // If check-in or check-out times are being modified, recalculate workedMinutes
      final data = snapshot.data() ?? {};
      final mergedData = {...data, ...updates};

      final checkInTime = mergedData['checkIn']?['inTime'] as String?;
      final checkOutTime = mergedData['outTime']?['outTime'] as String?;

      if (checkInTime != null && checkOutTime != null) {
        final breakInTimes = (mergedData['breakInTime'] as List<dynamic>?)?.cast<String>();
        final breakOutTimes = (mergedData['breakOutTime'] as List<dynamic>?)?.cast<String>();

        updates['workedMinutes'] = AttendanceService.calculateWorkedMinutesOnCheckOut(
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          breakInTimes: breakInTimes,
          breakOutTimes: breakOutTimes,
        );
      }

      transaction.update(docRef, updates);
    });
  }
}