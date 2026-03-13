import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulsera/models/team_members_model.dart';
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
    required UserModel employee,
    required String managerId,
    required double monthlySalary,
    required int annualVacationDays,
    required String companyId,
    required String roleType,
    required String email,

  }) async {
    final newMember = MembersData(
      uId: employee.uId,
      fullName: '${employee.firstName} ${employee.lastName}',
      roleType: roleType,
      managerId: managerId,
      email: employee.email,
      monthlySalary: monthlySalary,
      monthlyVacationDays: annualVacationDays,
      remainingVacationDays: annualVacationDays,
      joinedAt: DateTime.now().toIso8601String(),
      status: 'Active',
    );
    await _firestore.collection('teams').doc(managerId).set({
      'managerId': managerId,
      'companyId': companyId,
      'members': FieldValue.arrayUnion([newMember.toJson()]),
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(employee.uId).update({
      'managerId': managerId,
      'companyId': companyId,
      'roleType': roleType,
    });
  }

  /// Fetches all employees assigned to this manager within the same company.
  // Future<List<MemberModel>> getTeamMembers({
  //   required String managerId,
  //   required String companyId,
  // }) async {
  //   // final snapshot = await _firestore
  //   //     .collection('users')
  //   //     .where('managerId', isEqualTo: managerId)
  //   //     .where('companyId', isEqualTo: companyId)
  //   //     .get();
  //   final doc = await _firestore.collection('teams').doc(managerId).get();
  //
  //   return snapshot.docs
  //       .map((doc) => UserModel.fromJson(doc.data()))
  //       .toList();
  //
  // }
  Future<MemberModel?> getFullTeamData({
    required String managerId,
  }) async {
    final doc = await _firestore.collection('teams').doc(managerId).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;

      // We need to fetch the Manager's identity to fill the manager field in MemberModel
      final managerUser = await _firestore.collection('users').doc(managerId).get();

      Map<String, dynamic> teamJson = {
        'manager': managerUser.exists ? {
          'uId': managerId,
          'fullName': '${managerUser['firstName']} ${managerUser['lastName']}',
          'roleType': 'Manager',

        } : null,
        'members': data['members'] ?? [],
      };

      return MemberModel.fromJson(teamJson);
    }
    return null;
  }

  /// Fetches the manager's info for an employee view.
  Future<UserModel?> getManagerInfo(String managerId) async {
    return getUserByUid(managerId);
  }

  /// Soft-deletes an employee: marks as Terminated with endDate instead of
  /// removing from the array. Keeps historical data for payroll.
  Future<void> removeEmployeeFromTeam({
    required String managerId,
    required MembersData memberToRemove,
  }) async {
    final docRef = _firestore.collection('teams').doc(managerId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data() == null) return;

    final members = List<Map<String, dynamic>>.from(
      (doc.data()!['members'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          ?? [],
    );

    // Find and update the member's status
    for (int i = 0; i < members.length; i++) {
      if (members[i]['uId'] == memberToRemove.uId) {
        members[i]['status'] = 'Terminated';
        members[i]['endDate'] = DateTime.now().toIso8601String();
        break;
      }
    }

    await docRef.update({'members': members});

    // Reset the fields on the user's primary identity document
    await _firestore.collection('users').doc(memberToRemove.uId).update({
      'managerId': FieldValue.delete(),
      'companyId': FieldValue.delete(),
    });
  }
}
