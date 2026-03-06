import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulsera/models/user_model.dart';


class TeamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a user document by UID. Returns null if not found.
  Future<UserModel?> getUserByUid(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Assigns an employee to a manager's team and sets salary/vacation data.
  Future<void> assignEmployeeToManager({
    required String employeeUid,
    required String managerId,
    required double monthlySalary,
    required int annualVacationDays,
    required String companyId,

  }) async {
    await _firestore.collection('users').doc(employeeUid).update({
      'managerId': managerId,
      'companyId': companyId,
      'monthlySalary': monthlySalary,
      'annualVacationDays': annualVacationDays,
      'remainingVacationDays': annualVacationDays,

    });
  }

  /// Fetches all employees assigned to this manager within the same company.
  Future<List<UserModel>> getTeamMembers({
    required String managerId,
    required String companyId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .where('managerId', isEqualTo: managerId)
        .where('companyId', isEqualTo: companyId)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  /// Fetches the manager's info for an employee view.
  Future<UserModel?> getManagerInfo(String managerId) async {
    return getUserByUid(managerId);
  }

  /// Removes an employee from a manager's team (resets team-related fields).
  Future<void> removeEmployeeFromTeam(String employeeUid) async {
    await _firestore.collection('users').doc(employeeUid).update({
      'managerId': FieldValue.delete(),
      'companyId': FieldValue.delete(),
      'monthlySalary': FieldValue.delete(),
      'annualVacationDays': FieldValue.delete(),
      'remainingVacationDays': FieldValue.delete(),
    });
  }
}
