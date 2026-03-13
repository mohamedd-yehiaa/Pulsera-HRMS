import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/leave_repository.dart';

class ApplyLeaveCubit extends Cubit<ApplyLeaveStates> {
  ApplyLeaveCubit() : super(ApplyLeaveInitialState());

  static ApplyLeaveCubit get(context) => BlocProvider.of(context);

  final LeaveRepository _repository = LeaveRepository();

  var leavereasonTC = TextEditingController();
  DateTime? leaveStartDate;
  DateTime? leaveEndDate;

  // Auto-resolved from team data
  String? teamId;
  String? managerId;
  MembersData? teamAdmin;
  int? remainingVacationDays;
  int? totalDays;
  bool isTeamLoading = false;

  /// Fetches the employee's team and auto-resolves the team admin.
  void fetchTeamData({required String? userId}) {
    if (userId == null) return;

    isTeamLoading = true;
    emit(ApplyLeaveLoadingState());

    _repository.getEmployeeTeam(userId).then((teamData) async {
      if (teamData == null) {
        isTeamLoading = false;
        emit(ApplyLeaveErrorState('You are not assigned to any team. Contact your manager.'));
        return;
      }

      teamId = teamData['teamId'];
      managerId = teamData['managerId'];
      final memberData = teamData['memberData'] as Map<String, dynamic>;
      remainingVacationDays = memberData['remainingVacationDays'] as int?;

      // Fetch manager info for display
      final managerInfo = await _repository.getManagerInfo(managerId!);
      if (managerInfo != null) {
        teamAdmin = MembersData.fromJson(managerInfo);
      }

      isTeamLoading = false;
      emit(ApplyLeaveTeamLoadedState());
    }).catchError((error) {
      isTeamLoading = false;
      emit(ApplyLeaveErrorState(error.toString()));
    });
  }

  /// Recalculates total days when dates change.
  void _updateTotalDays() {
    if (leaveStartDate != null && leaveEndDate != null) {
      totalDays = LeaveActivityModel.calculateTotalDays(
        leaveStartDate!,
        leaveEndDate!,
      );
    } else {
      totalDays = null;
    }
  }

  /// Validates form inputs. Returns null if valid, or an error message.
  String? validateForm() {
    if (leaveStartDate == null || leaveEndDate == null) {
      return 'Please select both start and end dates.';
    }
    if (leaveEndDate!.isBefore(leaveStartDate!)) {
      return 'End date cannot be before start date.';
    }
    if (leavereasonTC.text.trim().isEmpty) {
      return 'Please enter a reason for your leave.';
    }
    if (teamAdmin == null) {
      return 'No team admin found. Contact your manager.';
    }
    // Balance check
    _updateTotalDays();
    if (remainingVacationDays != null &&
        totalDays != null &&
        totalDays! > remainingVacationDays!) {
      return 'Insufficient vacation balance. You have $remainingVacationDays days remaining but requested $totalDays days.';
    }
    return null;
  }

  /// Submits the leave request with overlap check and auto-assignment.
  void applyLeave({
    required String? uId,
    required String? companyId,
    required dynamic userModel,
  }) async {
    final validationError = validateForm();
    if (validationError != null) {
      emit(ApplyLeaveValidationErrorState(validationError));
      return;
    }

    emit(ApplyLeaveLoadingState());

    try {
      // Check for overlapping leaves
      final hasOverlap = await _repository.hasOverlappingLeaves(
        userId: uId!,
        companyId: companyId!,
        startDate: leaveStartDate!,
        endDate: leaveEndDate!,
      );

      if (hasOverlap) {
        emit(ApplyLeaveOverlapErrorState(
          'You already have a leave request that overlaps with these dates.',
        ));
        return;
      }

      final userFullName = '${userModel.firstName} ${userModel.lastName}';

      final leaveId = await _repository.applyLeave(
        userId: uId,
        companyId: companyId,
        teamId: teamId!,
        userFullName: userFullName,
        approvalToJson: teamAdmin!.toJson(),
        startDate: leaveStartDate!,
        endDate: leaveEndDate!,
        reason: leavereasonTC.text,
        totalDays: totalDays!,
      );

      // Notify the team admin
      await _repository.addNotification(
        toUserId: managerId!,
        fromUserName: userFullName,
        message: '$userFullName submitted a leave request for $totalDays days.',
        type: 'leave_submitted',
        leaveId: leaveId,
      );

      emit(ApplyLeaveSuccessState());
    } catch (error) {
      emit(ApplyLeaveErrorState(error.toString()));
    }
  }

  void setDate(BuildContext context, {required bool isStart}) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((value) {
      if (value != null) {
        if (isStart) {
          leaveStartDate = value;
        } else {
          leaveEndDate = value;
        }
        _updateTotalDays();
        emit(ApplyLeaveFieldChangedState());
      }
    });
  }
}