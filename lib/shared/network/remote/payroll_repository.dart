import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulsera/models/payroll_config_model.dart';
import 'package:pulsera/models/payroll_model.dart';
import 'package:pulsera/models/team_members_model.dart';


class PayrollRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // Attendance
  // ===========================================================================

  /// Fetches all attendance day documents for [userId] in the given [yearMonth] (e.g. "2026-03").
  /// Returns a list of raw Firestore maps, each representing one day's attendance.
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
      data['docId'] = doc.id; // Include the date key
      return data;
    }).toList();
  }

  // ===========================================================================
  // Approved Leaves
  // ===========================================================================

  /// Fetches approved leave records for a user that overlap with [yearMonth].
  /// Returns leave docs with fromdate/todate for date-range calculations.
  Future<List<Map<String, dynamic>>> fetchApprovedLeavesForMonth(
    String userId,
    String yearMonth,
  ) async {
    final snapshot = await _firestore
        .collection('leaves')
        .where('userID', isEqualTo: userId)
        .where('leaveStatus', isEqualTo: 'APPROVED')
        .get();

    // Filter client-side: keep only leaves that overlap with the target month
    final monthStart = DateTime.parse('$yearMonth-01');
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);

    return snapshot.docs.where((doc) {
      final data = doc.data();
      final fromStr = data['fromdate'] as String?;
      final toStr = data['todate'] as String?;
      if (fromStr == null || toStr == null) return false;

      try {
        final from = DateTime.parse(fromStr);
        final to = DateTime.parse(toStr);
        // Overlap: leave starts before month ends AND leave ends after month starts
        return from.isBefore(monthEnd.add(const Duration(days: 1))) &&
            to.isAfter(monthStart.subtract(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ===========================================================================
  // Team Members (for payroll generation)
  // ===========================================================================

  /// Fetches all team members for a company, including terminated employees
  /// whose endDate falls within or after [yearMonth].
  Future<List<MembersData>> getCompanyTeamMembers(
    String companyId,
    String yearMonth,
  ) async {
    final snapshot = await _firestore
        .collection('teams')
        .where('companyId', isEqualTo: companyId)
        .get();

    final monthStart = DateTime.parse('$yearMonth-01');
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    final List<MembersData> allMembers = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final members = data['members'] as List<dynamic>? ?? [];

      for (final memberJson in members) {
        final member = MembersData.fromJson(Map<String, dynamic>.from(memberJson));

        if (member.status == 'Active') {
          allMembers.add(member);
        } else if (member.status == 'Terminated' && member.endDate != null) {
          // Include terminated employees whose end date is within this month
          try {
            final endDate = DateTime.parse(member.endDate!);
            if (endDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                endDate.isBefore(monthEnd.add(const Duration(days: 1)))) {
              allMembers.add(member);
            }
          } catch (_) {}
        }
      }
    }

    return allMembers;
  }

  // ===========================================================================
  // Payroll CRUD
  // ===========================================================================

  /// Saves a payroll record. Uses the [payroll.payrollId] as the doc ID.
  Future<void> savePayroll(PayrollModel payroll) async {
    final docRef = _firestore.collection('payrolls').doc(payroll.payrollId);
    await docRef.set(payroll.toJson());
  }

  /// Checks if a payroll already exists for the given employee and month.
  Future<bool> checkPayrollExists(String employeeId, String month) async {
    final snapshot = await _firestore
        .collection('payrolls')
        .where('employeeId', isEqualTo: employeeId)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Deletes an existing payroll record (for override support).
  Future<void> deletePayroll(String payrollId) async {
    await _firestore.collection('payrolls').doc(payrollId).delete();
  }

  /// Fetches all payroll records for a specific employee, ordered by month descending.
  Future<List<PayrollModel>> getPayrollsByEmployee(String employeeId) async {
    final snapshot = await _firestore
        .collection('payrolls')
        .where('employeeId', isEqualTo: employeeId)
        // .orderBy('month', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PayrollModel.fromJson(doc.data()))
        .toList();
  }

  /// Fetches all payroll records for a company in a specific month.
  Future<List<PayrollModel>> getPayrollsByCompanyAndMonth(
    String companyId,
    String month,
  ) async {
    final snapshot = await _firestore
        .collection('payrolls')
        .where('companyId', isEqualTo: companyId)
        .where('month', isEqualTo: month)
        .get();

    return snapshot.docs
        .map((doc) => PayrollModel.fromJson(doc.data()))
        .toList();
  }

  // ===========================================================================
  // Payroll Configuration
  // ===========================================================================

  /// Fetches the payroll config for a company. Returns null if none exists.
  Future<PayrollConfigModel?> getPayrollConfig(String companyId) async {
    final doc = await _firestore
        .collection('payroll_config')
        .doc(companyId)
        .get();

    if (doc.exists && doc.data() != null) {
      return PayrollConfigModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Saves or updates the payroll configuration for a company.
  Future<void> savePayrollConfig(PayrollConfigModel config) async {
    await _firestore
        .collection('payroll_config')
        .doc(config.companyId)
        .set(config.toJson());
  }
}
