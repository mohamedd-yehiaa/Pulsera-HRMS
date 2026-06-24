import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/leave_repository.dart';
import 'package:pulsera/shared/network/remote/notification_repository.dart';

class LeaveCubit extends Cubit<LeaveStates> {
  LeaveCubit() : super(LeaveInitialState());

  static LeaveCubit get(context) => BlocProvider.of(context);

  final LeaveRepository _repository = LeaveRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();

  StreamSubscription? _subscription;

  // Variables and Controllers
  List<LeaveActivityModel> mainList = [];
  List<LeaveActivityModel> filteredLeaves = [];
  var leaveReasonTC = TextEditingController();

  bool myData = true;
  String selectedTab = 'pending';

  // Leave Balance Stats (computed from data)
  int approvedCount = 0;
  int pendingCount = 0;
  int rejectedCount = 0;

  // Vacation balance for the current user (from team data)
  int? remainingVacationDays;
  String? managerId;

  // Track current stream to avoid duplicate setup
  String? _currentUserId;
  String? _currentCompanyId;

  // ===========================================================================
  // 1. Init — Start real-time stream of leaves
  // ===========================================================================
  void init(String userId, String companyId, {bool isAdmin = false}) {
    // Skip re-initialization if already streaming for this user+company
    if (_currentUserId == userId &&
        _currentCompanyId == companyId &&
        _subscription != null) {
      return;
    }

    _currentUserId = userId;
    _currentCompanyId = companyId;

    // Employees see their own leaves; admins/owners default to "Other" view
    myData = !isAdmin;

    emit(GetLeavesLoadingState());

    _subscription?.cancel();
    _subscription = _repository
        .watchLeaves(companyId: companyId)
        .listen((leaves) {
      mainList = leaves;
      _computeBalanceStats(userId);
      filterAndEmit(userId);
      emit(GetLeavesSuccessState());
    }, onError: (error) {
      print(error.toString());
      emit(LeaveStreamErrorState(error.toString()));
    });

    // Also load vacation balance (triggers monthly reset check)
    loadVacationBalance(userId: userId);
  }

  // ===========================================================================
  // 2. Refresh — One-shot re-fetch for pull-to-refresh
  // ===========================================================================
  Future<void> refreshLeaves() async {
    if (_currentUserId == null || _currentCompanyId == null) return;

    try {
      final leaves = await _repository.getAllLeaves(
        companyId: _currentCompanyId!,
      );
      mainList = leaves;
      _computeBalanceStats(_currentUserId!);
      filterAndEmit(_currentUserId!);
      emit(GetLeavesSuccessState());
      loadVacationBalance(userId: _currentUserId!);
    } catch (error) {
      print(error.toString());
      emit(GetLeavesErrorState(error.toString()));
    }
  }

  // ===========================================================================
  // 3. Get All Leaves (legacy one-shot, kept for backward compat)
  // ===========================================================================
  void getAllLeaves({required String? uId, required String? companyId}) {
    if (uId == null || companyId == null) return;

    emit(GetLeavesLoadingState());

    _repository.getAllLeaves(companyId: companyId).then((leaves) {
      mainList = leaves;
      _computeBalanceStats(uId);
      filterAndEmit(uId);
      emit(GetLeavesSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetLeavesErrorState(error.toString()));
    });
  }

  // ===========================================================================
  // 4. Load user's vacation balance from team data
  // ===========================================================================
  void loadVacationBalance({required String userId}) {
    _repository.getEmployeeTeam(userId).then((teamData) async {
      if (teamData != null) {
        managerId = teamData['managerId'];

        // Check monthly balance reset before reading the balance
        if (managerId != null) {
          final didReset = await _repository.resetLeaveBalanceIfNeeded(
            managerId: managerId!,
            userId: userId,
          );
          if (didReset) {
            // Re-read team data after reset
            final refreshed = await _repository.getEmployeeTeam(userId);
            if (refreshed != null) {
              final refreshedMember =
                  refreshed['memberData'] as Map<String, dynamic>;
              remainingVacationDays =
                  refreshedMember['remainingVacationDays'] as int?;
              emit(LeaveBalanceResetState());
              return;
            }
          }
        }

        final memberData = teamData['memberData'] as Map<String, dynamic>;
        remainingVacationDays = memberData['remainingVacationDays'] as int?;
        emit(VacationBalanceLoadedState());
      }
    }).catchError((error) {
      print('Failed to load vacation balance: $error');
    });
  }

  // ===========================================================================
  // 5. Compute leave balance stats for the current user
  // ===========================================================================
  void _computeBalanceStats(String uId) {
    final myLeaves = mainList.where((e) => e.userID == uId).toList();
    approvedCount = myLeaves
        .where((e) => e.leaveStatus == LeaveActivityState.approved)
        .length;
    pendingCount = myLeaves
        .where((e) => e.leaveStatus == LeaveActivityState.pending)
        .length;
    rejectedCount = myLeaves
        .where((e) => e.leaveStatus == LeaveActivityState.rejected)
        .length;
  }

  // ===========================================================================
  // 6. Filter logic for My/Other and Tabs
  // ===========================================================================
  void filterAndEmit(String uId) {
    // Filter by Role (My Leaves vs Others)
    List<LeaveActivityModel> roleFiltered = mainList.where((element) {
      if (myData) {
        return element.userID == uId;
      } else {
        // Show leaves where I am the approver
        return element.approvalTo?.uId == uId;
      }
    }).toList();

    // Filter by Tab (Pending/Approved/Rejected/Cancelled)
    filteredLeaves = roleFiltered.where((element) {
      return element.leaveStatus?.code.toLowerCase() ==
          selectedTab.toLowerCase();
    }).toList();
  }

  // ===========================================================================
  // 7. Tab Switching
  // ===========================================================================
  void emitTabChange(String status, String uId) {
    selectedTab = status;
    filterAndEmit(uId);
    emit(GetLeavesTabChangedState());
  }

  // ===========================================================================
  // 8. Toggle My/Other Leaves
  // ===========================================================================
  void changeMyData(bool value, String uId) {
    myData = value;
    filterAndEmit(uId);
    emit(ChangeMyDataState());
  }

  // ===========================================================================
  // 9. Approve or Reject Leave (Admin action)
  // ===========================================================================
  void updateLeaveStatus({
    required String leaveId,
    required LeaveActivityState status,
    String? rejectReason,
    required String uId,
    required String companyId,
    required String adminName,
  }) async {
    emit(UpdateLeaveLoadingState());

    try {
      await _repository.updateLeaveStatus(
        leaveId: leaveId,
        statusCode: status.code,
        rejectReason: rejectReason,
      );

      // Find the leave to get employee info
      final leave = mainList.firstWhere((e) => e.id == leaveId);

      // If approving, deduct vacation days from team collection
      if (status == LeaveActivityState.approved) {
        if (leave.fromdate != null &&
            leave.todate != null &&
            leave.userID != null &&
            leave.approvalTo?.uId != null) {
          final days = leave.totalDays ??
              LeaveActivityModel.calculateTotalDays(
                  leave.fromdate!, leave.todate!);

          // Get current balance
          final currentBalance = await _repository.getRemainingVacationDays(
            managerId: leave.approvalTo!.uId!,
            userId: leave.userID!,
          );

          if (currentBalance != null) {
            await _repository.updateMemberVacationDays(
              managerId: leave.approvalTo!.uId!,
              userId: leave.userID!,
              newBalance: currentBalance - days,
            );
          }
        }
      }

      // Notify the employee
      final notificationMessage = status == LeaveActivityState.approved
          ? '$adminName approved your leave request.'
          : '$adminName rejected your leave request.${rejectReason != null ? ' Reason: $rejectReason' : ''}';

      if (leave.userID != null) {
        final bool isApproved = status == LeaveActivityState.approved;
        await _notificationRepo.addNotification(
          toUserId: leave.userID!,
          fromUserName: adminName,
          message: notificationMessage,
          messageKey: isApproved
              ? 'notifLeaveApproved'
              : (rejectReason != null && rejectReason.isNotEmpty
                  ? 'notifLeaveRejectedWithReason'
                  : 'notifLeaveRejected'),
          messageParams: isApproved
              ? {'name': adminName}
              : (rejectReason != null && rejectReason.isNotEmpty
                  ? {'name': adminName, 'reason': rejectReason}
                  : {'name': adminName}),
          type: isApproved
              ? 'leave_approved'
              : 'leave_rejected',
          leaveId: leaveId,
        );
      }

      emit(UpdateLeaveSuccessState());
      // Stream will auto-update, but also refresh vacation balance
      loadVacationBalance(userId: uId);
    } catch (error) {
      print(error.toString());
      emit(UpdateLeaveErrorState(error.toString()));
    }
  }

  // ===========================================================================
  // 10. Cancel an approved leave (Employee action → restores days)
  // ===========================================================================
  void cancelLeave({
    required String leaveId,
    required String uId,
    required String companyId,
    required String employeeName,
  }) async {
    emit(CancelLeaveLoadingState());

    try {
      final leave = mainList.firstWhere((e) => e.id == leaveId);
      final wasApproved = leave.leaveStatus == LeaveActivityState.approved;

      // Update status to cancelled
      await _repository.updateLeaveStatus(
        leaveId: leaveId,
        statusCode: LeaveActivityState.cancelled.code,
      );

      // Only restore vacation days if the leave was previously approved
      // (pending leaves never had days deducted)
      if (wasApproved &&
          leave.fromdate != null &&
          leave.todate != null &&
          leave.approvalTo?.uId != null) {
        final days = leave.totalDays ??
            LeaveActivityModel.calculateTotalDays(
                leave.fromdate!, leave.todate!);

        final currentBalance = await _repository.getRemainingVacationDays(
          managerId: leave.approvalTo!.uId!,
          userId: uId,
        );

        if (currentBalance != null) {
          await _repository.updateMemberVacationDays(
            managerId: leave.approvalTo!.uId!,
            userId: uId,
            newBalance: currentBalance + days,
          );
        }
      }

      // Notify the admin
      final statusLabel = wasApproved ? 'approved' : 'pending';
      if (leave.approvalTo?.uId != null) {
        await _notificationRepo.addNotification(
          toUserId: leave.approvalTo!.uId!,
          fromUserName: employeeName,
          message: '$employeeName cancelled their $statusLabel leave request.',
          messageKey: 'notifLeaveCancelled',
          messageParams: {'name': employeeName, 'status': statusLabel},
          type: 'leave_cancelled',
          leaveId: leaveId,
        );
      }

      emit(CancelLeaveSuccessState());
      // Stream will auto-update, but also refresh vacation balance
      loadVacationBalance(userId: uId);
    } catch (error) {
      print(error.toString());
      emit(CancelLeaveErrorState(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
