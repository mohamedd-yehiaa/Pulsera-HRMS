import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/models/notification_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/leave_repository.dart';

class LeaveCubit extends Cubit<LeaveStates> {
  LeaveCubit() : super(LeaveInitialState());

  static LeaveCubit get(context) => BlocProvider.of(context);

  final LeaveRepository _repository = LeaveRepository();

  // Variables and Controllers
  List<LeaveActivityModel> mainList = [];
  List<LeaveActivityModel> filteredLeaves = [];
  var leaveReasonTC = TextEditingController();

  bool myData = false;
  String selectedTab = 'pending';

  // Leave Balance Stats (computed from data)
  int approvedCount = 0;
  int pendingCount = 0;
  int rejectedCount = 0;

  // Vacation balance for the current user (from team data)
  int? remainingVacationDays;
  String? managerId;

  // Notifications
  List<NotificationModel> notifications = [];
  int unreadNotificationCount = 0;

  // ===========================================================================
  // 1. Get All Leaves for the Company
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
  // 2. Load user's vacation balance from team data
  // ===========================================================================
  void loadVacationBalance({required String userId}) {
    _repository.getEmployeeTeam(userId).then((teamData) {
      if (teamData != null) {
        managerId = teamData['managerId'];
        final memberData = teamData['memberData'] as Map<String, dynamic>;
        remainingVacationDays = memberData['remainingVacationDays'] as int?;
        emit(VacationBalanceLoadedState());
      }
    }).catchError((error) {
      print('Failed to load vacation balance: $error');
    });
  }

  // ===========================================================================
  // 3. Compute leave balance stats for the current user
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
  // 4. Filter logic for My/Other and Tabs
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
  // 5. Tab Switching
  // ===========================================================================
  void emitTabChange(String status, String uId) {
    selectedTab = status;
    filterAndEmit(uId);
    emit(GetLeavesTabChangedState());
  }

  // ===========================================================================
  // 6. Toggle My/Other Leaves
  // ===========================================================================
  void changeMyData(bool value, String uId) {
    myData = value;
    filterAndEmit(uId);
    emit(ChangeMyDataState());
  }

  // ===========================================================================
  // 7. Approve or Reject Leave (Admin action)
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
        await _repository.addNotification(
          toUserId: leave.userID!,
          fromUserName: adminName,
          message: notificationMessage,
          type: status == LeaveActivityState.approved
              ? 'leave_approved'
              : 'leave_rejected',
          leaveId: leaveId,
        );
      }

      emit(UpdateLeaveSuccessState());
      // Refresh data
      getAllLeaves(uId: uId, companyId: companyId);
      loadVacationBalance(userId: uId);
    } catch (error) {
      print(error.toString());
      emit(UpdateLeaveErrorState(error.toString()));
    }
  }

  // ===========================================================================
  // 8. Cancel an approved leave (Employee action → restores days)
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

      // Update status to cancelled
      await _repository.updateLeaveStatus(
        leaveId: leaveId,
        statusCode: LeaveActivityState.cancelled.code,
      );

      // Restore vacation days
      if (leave.fromdate != null &&
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
      if (leave.approvalTo?.uId != null) {
        await _repository.addNotification(
          toUserId: leave.approvalTo!.uId!,
          fromUserName: employeeName,
          message: '$employeeName cancelled their approved leave request.',
          type: 'leave_cancelled',
          leaveId: leaveId,
        );
      }

      emit(CancelLeaveSuccessState());
      getAllLeaves(uId: uId, companyId: companyId);
      loadVacationBalance(userId: uId);
    } catch (error) {
      print(error.toString());
      emit(CancelLeaveErrorState(error.toString()));
    }
  }

  // ===========================================================================
  // 9. Notifications
  // ===========================================================================
  void loadNotifications({required String userId}) {
    _repository.getNotifications(userId).then((result) {
      notifications = result;
      unreadNotificationCount = result.where((n) => !n.isRead).length;
      emit(NotificationsLoadedState());
    }).catchError((error) {
      print('Failed to load notifications: $error');
    });
  }

  void markNotificationRead(String notificationId) {
    _repository.markNotificationRead(notificationId).then((_) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index].isRead = true;
        unreadNotificationCount =
            notifications.where((n) => !n.isRead).length;
      }
      emit(NotificationMarkedReadState());
    });
  }
}

