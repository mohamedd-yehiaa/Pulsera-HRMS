import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/leave_activity_model.dart';


class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // Team & Employee Lookup
  // ===========================================================================

  /// Finds the team doc where [userId] is a member.
  /// Returns the team document data including managerId and members array.
  Future<Map<String, dynamic>?> getEmployeeTeam(String userId) async {
    final snapshot = await _firestore.collection('teams').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final members = data['members'] as List<dynamic>? ?? [];
      for (final member in members) {
        if (member['uId'] == userId) {
          return {
            'teamId': doc.id,
            'managerId': data['managerId'],
            'companyId': data['companyId'],
            'members': members,
            'memberData': member,
          };
        }
      }
    }
    return null;
  }

  /// Fetches the manager's display info from the users collection.
  Future<Map<String, dynamic>?> getManagerInfo(String managerId) async {
    final doc = await _firestore.collection('users').doc(managerId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return {
        'uId': managerId,
        'fullName': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
        'email': data['email'],
        'roleType': data['userType'] ?? 'Manager',
      };
    }
    return null;
  }

  // ===========================================================================
  // Leave CRUD
  // ===========================================================================

  /// Fetches all leaves for a given company.
  Future<List<LeaveActivityModel>> getAllLeaves({
    required String companyId,
  }) async {
    final snapshot = await _firestore
        .collection('leaves')
        .where('companyID', isEqualTo: companyId)
        .get();

    return snapshot.docs.map((doc) {
      var model = LeaveActivityModel.fromJson(doc.data());
      model.id = doc.id;
      return model;
    }).toList();
  }

  /// Real-time stream of leaves for a given company.
  Stream<List<LeaveActivityModel>> watchLeaves({
    required String companyId,
  }) {
    return _firestore
        .collection('leaves')
        .where('companyID', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var model = LeaveActivityModel.fromJson(doc.data());
              model.id = doc.id;
              return model;
            }).toList());
  }

  /// Creates a new leave request with auto-assigned team admin.
  Future<String> applyLeave({
    required String userId,
    required String companyId,
    required String teamId,
    required String userFullName,
    required Map<String, dynamic> approvalToJson,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required int totalDays,
  }) async {
    final docRef = await _firestore.collection('leaves').add({
      'userID': userId,
      'companyID': companyId,
      'teamId': teamId,
      'approvalTo': approvalToJson,
      'leaveStatus': 'PENDING',
      'fromdate': DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate),
      'todate': DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate),
      'applyDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'leaveReason': reason,
      'totalDays': totalDays,
      'user': {
        'uId': userId,
        'fullName': userFullName,
      },
    });
    return docRef.id;
  }

  /// Updates the status of a leave (approve / reject / cancel).
  Future<void> updateLeaveStatus({
    required String leaveId,
    required String statusCode,
    String? rejectReason,
  }) async {
    final updateData = <String, dynamic>{
      'leaveStatus': statusCode,
    };
    if (rejectReason != null) {
      updateData['rejectedReason'] = rejectReason;
    }
    await _firestore.collection('leaves').doc(leaveId).update(updateData);
  }

  // ===========================================================================
  // Validation
  // ===========================================================================

  /// Checks if a leave request overlaps with existing pending/approved leaves.
  Future<bool> hasOverlappingLeaves({
    required String userId,
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _firestore
        .collection('leaves')
        .where('userID', isEqualTo: userId)
        .where('companyID', isEqualTo: companyId)
        .get();

    final startStr = DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate);
    final endStr = DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['leaveStatus'] as String?;

      // Only check against pending and approved leaves
      if (status != 'PENDING' && status != 'APPROVED') continue;

      final existingFrom = data['fromdate'] as String?;
      final existingTo = data['todate'] as String?;
      if (existingFrom == null || existingTo == null) continue;

      // Overlap: new start <= existing end AND new end >= existing start
      if (startStr.compareTo(existingTo) <= 0 &&
          endStr.compareTo(existingFrom) >= 0) {
        return true;
      }
    }
    return false;
  }

  // ===========================================================================
  // Vacation Balance Management (in teams collection)
  // ===========================================================================

  /// Updates a member's remainingVacationDays in the team document.
  /// This does a read-modify-write on the members array.
  Future<void> updateMemberVacationDays({
    required String managerId,
    required String userId,
    required int newBalance,
  }) async {
    final docRef = _firestore.collection('teams').doc(managerId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data() == null) return;

    final members = List<Map<String, dynamic>>.from(
      (doc.data()!['members'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
          ?? [],
    );

    // Find and update the member's vacation balance
    for (int i = 0; i < members.length; i++) {
      if (members[i]['uId'] == userId) {
        members[i]['remainingVacationDays'] = newBalance;
        break;
      }
    }

    await docRef.update({'members': members});
  }

  /// Gets a member's remaining vacation days from the team document.
  Future<int?> getRemainingVacationDays({
    required String managerId,
    required String userId,
  }) async {
    final doc =
        await _firestore.collection('teams').doc(managerId).get();

    if (!doc.exists || doc.data() == null) return null;

    final members = doc.data()!['members'] as List<dynamic>? ?? [];
    for (final member in members) {
      if (member['uId'] == userId) {
        return member['remainingVacationDays'] as int?;
      }
    }
    return null;
  }

  // ===========================================================================
  // Monthly Leave Balance Reset
  // ===========================================================================

  /// Checks if the current month differs from `lastResetMonth` for the member.
  /// If so, resets `remainingVacationDays` to `monthlyVacationDays` (default 4)
  /// and updates `lastResetMonth`. Prevents multiple resets in the same month.
  /// Returns `true` if a reset was performed.
  Future<bool> resetLeaveBalanceIfNeeded({
    required String managerId,
    required String userId,
  }) async {
    final docRef = _firestore.collection('teams').doc(managerId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data() == null) return false;

    final members = List<Map<String, dynamic>>.from(
      (doc.data()!['members'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
          ?? [],
    );

    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    bool didReset = false;

    for (int i = 0; i < members.length; i++) {
      if (members[i]['uId'] == userId) {
        final lastResetMonth = members[i]['lastResetMonth'] as String?;

        if (lastResetMonth != currentMonth) {
          // Reset balance to the configured monthly allowance (default 4)
          final defaultBalance = (members[i]['monthlyVacationDays'] as int?) ?? 4;
          members[i]['remainingVacationDays'] = defaultBalance;
          members[i]['lastResetMonth'] = currentMonth;
          didReset = true;
        }
        break;
      }
    }

    if (didReset) {
      await docRef.update({'members': members});
    }

    return didReset;
  }
}
