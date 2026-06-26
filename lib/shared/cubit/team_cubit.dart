import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/team_repository.dart';

/// Standalone validation function — testable without Firebase.
/// Returns null if valid, or an error message string.
String? validateTeamAssignment({
  required UserModel? user,
  required String currentManagerId,
}) {
  if (user == null) {
    return 'User not found. Please check the UserID and try again.';
  }
  if (user.userType == null || user.userType != 'Employee') {
    return 'This user is not an Employee. Only employees can be added to a team.';
  }
  if (user.managerId != null && user.managerId!.isNotEmpty) {
    if (user.managerId == currentManagerId) {
      return 'This employee is already on your team.';
    }
    return 'This employee is already assigned to another manager.';
  }
  return null; // valid
}

class TeamCubit extends Cubit<TeamStates> {
  final TeamRepository _repository;

  TeamCubit(this._repository) : super(TeamInitialState());

  static TeamCubit get(context) => BlocProvider.of(context);

  MemberModel? teamData;
  UserModel? validatedUser;
  UserModel? myManager;

  String selectedRole = 'Employee';

  final userIdController = TextEditingController();
  final salaryController = TextEditingController();
  final vacationDaysController = TextEditingController();

  // -------------------------------------------------------------------------
  // 1. Validate employee
  // -------------------------------------------------------------------------
  void validateEmployee({
    required String userId,
    required String currentManagerId,
  }) {
    if (userId.trim().isEmpty) {
      emit(TeamUserValidationErrorState('Please enter a UserID.'));
      return;
    }

    emit(TeamLoadingState());

    _repository
        .getUserByUid(userId.trim())
        .then((user) {
          // Use your existing validation logic here
          if (user == null) {
            emit(TeamUserValidationErrorState('User not found.'));
            return;
          }

          validatedUser = user;
          emit(TeamUserValidatedState());
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  // -------------------------------------------------------------------------
  // 2. Add validated employee to team (Updated with roleType)
  // -------------------------------------------------------------------------
  void addEmployeeToTeam({
    required String managerId,
    required String companyId,
    required String roleType, // New parameter
  }) {
    if (validatedUser == null) {
      emit(TeamErrorState('Please validate the employee first.'));
      return;
    }

    emit(TeamLoadingState());

    _repository
        .assignEmployeeToManager(
          employee: validatedUser!,
          companyId: companyId,
          managerId: managerId,
          email: validatedUser!.email!,
          roleType: roleType,
          monthlySalary: double.parse(salaryController.text),
          annualVacationDays: int.parse(vacationDaysController.text),
        )
        .then((_) {
          Fluttertoast.showToast(msg: 'Employee added successfully!');

          // Reset form
          validatedUser = null;
          userIdController.clear();
          salaryController.clear();
          vacationDaysController.clear();

          // Reload the team to show the new member
          loadFullTeam(managerId: managerId);

          emit(TeamMemberAddedState());
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  // -------------------------------------------------------------------------
  // 3. Handle Unassigned Users (New Employees)
  // -------------------------------------------------------------------------
  void markAsUnassigned() {
    teamData = null;
    myManager = null;
    emit(TeamUnassignedState());
  }

  // -------------------------------------------------------------------------
  // 4. Load Full Team (Updated to use MemberModel)
  // -------------------------------------------------------------------------
  void loadFullTeam({required String managerId}) {
    emit(TeamLoadingState());
    if (managerId.trim().isEmpty) {
      markAsUnassigned();
      return;
    }

    _repository
        .getFullTeamData(managerId: managerId)
        .then((model) {
          teamData = model;
          emit(TeamMembersLoadedState());
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  // -------------------------------------------------------------------------
  // 5. Load my manager (for Employee view)
  // -------------------------------------------------------------------------
  void loadMyManager(String? managerId) {
    if (managerId == null || managerId.isEmpty) {
      myManager = null;
      emit(TeamMembersLoadedState());
      return;
    }

    emit(TeamLoadingState());

    _repository
        .getUserByUid(managerId)
        .then((manager) {
          myManager = manager;
          emit(TeamMembersLoadedState());
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  // -------------------------------------------------------------------------
  // 6. Remove employee (Soft Delete / Terminate)
  // -------------------------------------------------------------------------
  void removeEmployeeFromTeam({
    required String managerId,
    required MembersData member,
  }) {
    emit(TeamLoadingState());

    _repository
        .removeEmployeeFromTeam(managerId: managerId, memberToRemove: member)
        .then((_) {
          Fluttertoast.showToast(msg: 'Employee terminated.');
          loadFullTeam(managerId: managerId);
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  // -------------------------------------------------------------------------
  // 7. Permanently Delete Employee (Hard Delete after Payroll)
  // -------------------------------------------------------------------------
  void permanentlyRemoveEmployee({
    required String managerId,
    required String employeeUid,
  }) {
    emit(TeamLoadingState());

    _repository
        .permanentlyRemoveEmployeeFromTeam(
          managerId: managerId,
          employeeUid: employeeUid,
        )
        .then((_) {
          Fluttertoast.showToast(msg: 'Employee permanently deleted.');
          loadFullTeam(managerId: managerId);
        })
        .catchError((e) {
          emit(TeamErrorState(e.toString()));
        });
  }

  @override
  Future<void> close() {
    userIdController.dispose();
    salaryController.dispose();
    vacationDaysController.dispose();
    return super.close();
  }
}
