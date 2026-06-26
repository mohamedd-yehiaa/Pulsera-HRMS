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

    final teamDocRef = _firestore.collection('teams').doc(managerId);
    final doc = await teamDocRef.get();

    List<Map<String, dynamic>> members = [];
    bool userAlreadyExists = false;

    // 1. Read the existing team data
    if (doc.exists && doc.data() != null) {
      members = List<Map<String, dynamic>>.from(
        (doc.data()!['members'] as List<dynamic>?)?.map(
              (e) => Map<String, dynamic>.from(e),
            ) ??
            [],
      );

      // 2. Look for the employee in the list
      for (int i = 0; i < members.length; i++) {
        if (members[i]['uId'] == employee.uId) {
          // Overwrite the old "Terminated" record with the fresh "Active" data
          members[i] = newMember.toJson();
          userAlreadyExists = true;
          break; // Stop searching once we find them
        }
      }
    }

    // 3. If they were never on the team before, add them to the end
    if (!userAlreadyExists) {
      members.add(newMember.toJson());
    }

    // 4. Save the updated list back to Firestore
    await teamDocRef.set({
      'managerId': managerId,
      'companyId': companyId,
      'members': members,
    }, SetOptions(merge: true));

    // 5. Update the user's primary document
    await _firestore.collection('users').doc(employee.uId).update({
      'managerId': managerId,
      'companyId': companyId,
      'roleType': roleType,
    });
  }

  /// Fetches all employees assigned to this manager within the same company.
  Future<MemberModel?> getFullTeamData({required String managerId}) async {
    final doc = await _firestore.collection('teams').doc(managerId).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      List<dynamic> rawMembers = data['members'] ?? [];
      List<Map<String, dynamic>> syncedMembers = [];

      // 1. Loop through the static team array
      for (var member in rawMembers) {
        Map<String, dynamic> memberMap = Map<String, dynamic>.from(member);

        // 2. Fetch the LATEST, live profile data for this specific user
        final userDoc = await _firestore
            .collection('users')
            .doc(memberMap['uId'])
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;

          // 3. Inject the live image and name into the team data
          // Now, if they change their picture, the team list instantly updates!
          memberMap['image'] = userData['image'];
          memberMap['fullName'] =
              '${userData['firstName']} ${userData['lastName']}';
        }

        syncedMembers.add(memberMap);
      }

      // We need to fetch the Manager's identity
      final managerUser = await _firestore
          .collection('users')
          .doc(managerId)
          .get();

      Map<String, dynamic> teamJson = {
        'manager': managerUser.exists
            ? {
                'uId': managerId,
                'fullName':
                    '${managerUser['firstName']} ${managerUser['lastName']}',
                'roleType': 'Manager',
              }
            : null,
        // 4. Pass our newly synced list to the model instead of the raw data
        'members': syncedMembers,
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
      (doc.data()!['members'] as List<dynamic>?)?.map(
            (e) => Map<String, dynamic>.from(e),
          ) ??
          [],
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

  /// Completely and permanently removes an employee from the manager's team array.
  /// Use this strictly AFTER their final payroll has been generated.
  Future<void> permanentlyRemoveEmployeeFromTeam({
    required String managerId,
    required String employeeUid,
  }) async {
    final teamDocRef = _firestore.collection('teams').doc(managerId);
    final doc = await teamDocRef.get();

    if (!doc.exists || doc.data() == null) return;

    // 1. Read the current list of team members
    List<Map<String, dynamic>> members = List<Map<String, dynamic>>.from(
      (doc.data()!['members'] as List<dynamic>?)?.map(
            (e) => Map<String, dynamic>.from(e),
          ) ??
          [],
    );

    // 2. Completely remove the employee from the list using their ID
    // This safely deletes them even if their exact data changed slightly
    members.removeWhere((member) => member['uId'] == employeeUid);

    // 3. Save the newly scrubbed list back to Firestore
    await teamDocRef.update({'members': members});

    // 4. Ensure the employee's main profile is stripped of the manager's info
    await _firestore.collection('users').doc(employeeUid).update({
      'managerId': FieldValue.delete(),
      'companyId': FieldValue.delete(),
    });
  }
}
