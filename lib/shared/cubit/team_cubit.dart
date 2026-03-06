import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  if (user.userType == null ||
      user.userType != 'Employee') {
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

  // State holders
  List<UserModel> teamMembers = [];
  UserModel? validatedUser;
  UserModel? myManager;

  // Text controllers for the Add Member form
  final userIdController = TextEditingController();
  final salaryController = TextEditingController();
  final vacationDaysController = TextEditingController();

  // -------------------------------------------------------------------------
  // 1. Validate employee by UserID
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

    _repository.getUserByUid(userId.trim()).then((user) {
      final error = validateTeamAssignment(
        user: user,
        currentManagerId: currentManagerId,
      );

      if (error != null) {
        validatedUser = null;
        emit(TeamUserValidationErrorState(error));
      } else {
        validatedUser = user;
        emit(TeamUserValidatedState());
      }
    }).catchError((e) {
      validatedUser = null;
      emit(TeamErrorState(e.toString()));
    });
  }

  // -------------------------------------------------------------------------
  // 2. Add validated employee to team
  // -------------------------------------------------------------------------
  void addEmployeeToTeam({
    required String managerId,
    required double monthlySalary,
    required int annualVacationDays,
    required String companyId,
  }) {
    if (validatedUser == null) {
      emit(TeamErrorState('Please validate the employee first.'));
      return;
    }

    emit(TeamLoadingState());

    _repository
        .assignEmployeeToManager(
      employeeUid: validatedUser!.uId!,
      companyId: companyId,
      managerId: managerId,
      monthlySalary: monthlySalary,
      annualVacationDays: annualVacationDays,
    )
        .then((_) {
      Fluttertoast.showToast(msg: 'Employee added to team successfully!');
      validatedUser = null;
      userIdController.clear();
      salaryController.clear();
      vacationDaysController.clear();
      emit(TeamMemberAddedState());
    }).catchError((e) {
      emit(TeamErrorState(e.toString()));
    });
  }

  // -------------------------------------------------------------------------
  // 3. Load team members (for Manager view)
  // -------------------------------------------------------------------------
  void loadTeamMembers({
    required String managerId,
    required String companyId,
  }) {
    emit(TeamLoadingState());

    _repository
        .getTeamMembers(managerId: managerId, companyId: companyId)
        .then((members) {
      teamMembers = members;
      emit(TeamMembersLoadedState());
    }).catchError((e) {
      emit(TeamErrorState(e.toString()));
    });
  }

  // -------------------------------------------------------------------------
  // 4. Load my manager (for Employee view)
  // -------------------------------------------------------------------------
  void loadMyManager(String? managerId) {
    if (managerId == null || managerId.isEmpty) {
      myManager = null;
      emit(TeamMembersLoadedState());
      return;
    }

    emit(TeamLoadingState());

    _repository.getManagerInfo(managerId).then((manager) {
      myManager = manager;
      emit(TeamMembersLoadedState());
    }).catchError((e) {
      emit(TeamErrorState(e.toString()));
    });
  }

  // -------------------------------------------------------------------------
  // 5. Remove employee from team
  // -------------------------------------------------------------------------
  void removeEmployeeFromTeam({
    required String employeeUid,
    required String managerId,
    required String companyId,
  }) {
    emit(TeamLoadingState());

    _repository.removeEmployeeFromTeam(employeeUid).then((_) {
      Fluttertoast.showToast(msg: 'Employee removed from team.');
      loadTeamMembers(managerId: managerId, companyId: companyId);
    }).catchError((e) {
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
