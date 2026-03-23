import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/user_activity_model.dart';
import '../network/remote/attendance_repository.dart';
import '../network/remote/notification_repository.dart';
import '../services/attendance_service.dart';

class AttendanceCubit extends Cubit<AttendanceStates> {
  static AttendanceCubit get(context) => BlocProvider.of(context);
  final AttendanceRepository _repository;
  final NotificationRepository _notificationRepo = NotificationRepository();

  StreamSubscription? _subscription;
  Timer? _ticker;

  // Local variables to hold data while transitioning between success states
  UserActivityModel? _currentActivity;
  String _workingTime = "00:00:00";
  String _breakTime = "00:00";
  DateTime _selectedDate = DateTime.now();

  // Monthly summary data
  int _monthWorkedDays = 0;
  int _monthLateMinutes = 0;
  int _monthAbsenceDays = 0;
  int _monthPaidLeaveDays = 0;

  // Guard against double-swipe
  bool _isPerformingAction = false;

  // Track which user/date the stream is currently for
  String? _currentStreamUserId;
  String? _currentStreamDate;

  // Team attendance data (admin view)
  List<Map<String, dynamic>> _teamAttendanceRecords = [];

  AttendanceCubit(this._repository) : super(AttendanceInitialState());

  // ===========================================================================
  // Employee attendance — real-time stream
  // ===========================================================================

  void init(String userId) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Skip re-initialization if already streaming for this user+date
    if (_currentStreamUserId == userId &&
        _currentStreamDate == dateStr &&
        _subscription != null) {
      // Already tracking — just re-emit current state to update UI
      if (_currentActivity != null) {
        emit(AttendanceSuccessState());
      }
      return;
    }

    _currentStreamUserId = userId;
    _currentStreamDate = dateStr;
    emit(AttendanceLoadingState());

    _subscription?.cancel();
    _subscription = _repository
        .watchUserActivity(userId, dateStr)
        .listen((activity) {
      // ── Debug: attendance state ──
      debugPrint('[Attendance] checkIn=${activity?.checkIn?.inTime}, '
          'outTime=${activity?.outTime?.outTime}, '
          'nextAction=${activity?.nextAction}, '
          'canTakeBreak=${activity?.canTakeBreak}');
      _currentActivity = activity;

      if (activity != null && activity.checkIn?.inTime != null) {
        _updateBreakTime();
        if (activity.outTime == null) {
          _startWorkingTimer();
        } else {
          // Day completed — show final worked time
          _ticker?.cancel();
          // Use persisted workedMinutes if available, otherwise calculate
          if (activity.workedMinutes != null) {
            final h = activity.workedMinutes! ~/ 60;
            final m = activity.workedMinutes! % 60;
            _workingTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
          } else {
            _workingTime = _calculateFinalWorkedTime();
          }
        }
      } else {
        _workingTime = "00:00:00";
        _breakTime = "00:00";
        _ticker?.cancel();
      }
      emit(AttendanceSuccessState());
    }, onError: (e) {
      emit(AttendanceErrorState(e.toString()));
    });
  }

  void changeDate(DateTime newDate, String userId) {
    _selectedDate = newDate;
    _currentStreamDate = null; // Force re-init for new date
    emit(AttendanceChangeDateState());
    init(userId); // Re-fetch for the new date
  }

  // ===========================================================================
  // Monthly summary
  // ===========================================================================

  /// Loads monthly summary from attendance records.
  Future<void> loadMonthlySummary({
    required String userId,
    required String yearMonth,
    required List<String> companyWorkingDays,
    required String companyStartTime,
    required int lateGracePeriodMinutes,
  }) async {
    try {
      final docs = await _repository.fetchAttendanceForMonth(userId, yearMonth);
      final analysis = AttendanceService.analyseAttendance(
        attendanceDocs: docs,
        companyStartTime: companyStartTime,
        companyEndTime: '23:59', // No overtime calc needed for summary
        lateGracePeriodMinutes: lateGracePeriodMinutes,
      );
      _monthWorkedDays = analysis['daysWorked'] as int;
      _monthLateMinutes = analysis['lateMinutes'] as int;

      final totalWorkingDays = AttendanceService.countWorkingDaysInMonth(
        yearMonth,
        companyWorkingDays,
      );
      _monthAbsenceDays = totalWorkingDays - _monthWorkedDays;
      if (_monthAbsenceDays < 0) _monthAbsenceDays = 0;

      emit(AttendanceSuccessState());
    } catch (e) {
      // Silently fail — monthly summary is supplementary
    }
  }

  // ===========================================================================
  // Break time calculation
  // ===========================================================================

  void _updateBreakTime() {
    final breakMinutes = AttendanceService.calculateBreakMinutes(
      _currentActivity?.breakInTime,
      _currentActivity?.breakOutTime,
    );
    _breakTime = AttendanceService.formatMinutes(breakMinutes);
  }

  String _calculateFinalWorkedTime() {
    if (_currentActivity?.checkIn?.inTime == null ||
        _currentActivity?.outTime?.outTime == null) {
      return "00:00:00";
    }
    final workedMin = AttendanceService.calculateWorkedMinutes(
      inTime: _currentActivity!.checkIn!.inTime!,
      outTimeStr: _currentActivity!.outTime!.outTime!,
      breakInTimes: _currentActivity?.breakInTime,
      breakOutTimes: _currentActivity?.breakOutTime,
    );
    final h = workedMin ~/ 60;
    final m = workedMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
  }

  // ===========================================================================
  // Live working timer
  // ===========================================================================

  void _startWorkingTimer() {
    _ticker?.cancel();

    // Safety check: only start if checked in and not checked out
    if (_currentActivity?.checkIn?.inTime == null || _currentActivity?.outTime != null) {
      return;
    }

    final startTime = DateFormat("HH:mm:ss").parse(_currentActivity!.checkIn!.inTime!);
    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute, startTime.second);

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final grossDiff = DateTime.now().difference(startDateTime);

      // Deduct break time
      final breakMinutes = AttendanceService.calculateBreakMinutes(
        _currentActivity?.breakInTime,
        _currentActivity?.breakOutTime,
      );
      final netDiff = grossDiff - Duration(minutes: breakMinutes);
      final effectiveDiff = netDiff.isNegative ? Duration.zero : netDiff;

      _workingTime = effectiveDiff.toString().split('.').first.padLeft(8, "0");

      // Emit success state every second to update the timer in UI
      emit(AttendanceSuccessState());
    });
  }

  // ===========================================================================
  // Swipe action (check-in/out, breaks) — with double-swipe guard
  // ===========================================================================

  Future<void> performSwipeAction(
    String userId,
    String companyId, {
    String? teamId,
    String? companyStartTime,
    int lateGracePeriodMinutes = 0,
    String? userName,
  }) async {
    // Prevent double-swipe
    if (_isPerformingAction) return;

    // Use model's nextAction — single source of truth (DRY)
    final nextAction = _currentActivity?.nextAction ?? UserPerformActivty.IN;

    // Don't allow action if day is already done
    if (nextAction == UserPerformActivty.DONE) return;

    _isPerformingAction = true;
    emit(AttendanceActionInProgressState());

    try {
      await _repository.logAction(
        userId: userId,
        activityId: _currentActivity?.activityID ?? "NEW",
        action: nextAction,
        companyId: companyId,
        teamId: teamId,
        companyStartTime: companyStartTime,
        lateGracePeriodMinutes: lateGracePeriodMinutes,
      );

      // Notify team manager on check-in / check-out
      if (teamId != null && userName != null) {
        if (nextAction == UserPerformActivty.IN) {
          await _notificationRepo.addNotification(
            toUserId: teamId,
            fromUserName: userName,
            message: '$userName checked in.',
            type: 'attendance_checkin',
          );
        } else if (nextAction == UserPerformActivty.OUT) {
          await _notificationRepo.addNotification(
            toUserId: teamId,
            fromUserName: userName,
            message: '$userName checked out.',
            type: 'attendance_checkout',
          );
        }
      }
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    } finally {
      _isPerformingAction = false;
      // ── Debug: button visibility ──
      debugPrint('[Attendance] After action: nextAction=${_currentActivity?.nextAction}, '
          'canTakeBreak=${_currentActivity?.canTakeBreak}, '
          'isPerformingAction=$_isPerformingAction');
    }
  }

  // ===========================================================================
  // Break action
  // ===========================================================================

  Future<void> performBreakAction(
    String userId,
    String companyId, {
    String? teamId,
    String? userName,
  }) async {
    // Prevent double-swipe
    if (_isPerformingAction) return;

    // Use model's canTakeBreak — single source of truth
    final canTakeBreak = _currentActivity?.canTakeBreak ?? false;

    // Don't allow action if cannot take break
    if (!canTakeBreak) return;

    _isPerformingAction = true;
    emit(AttendanceActionInProgressState());

    try {
      await _repository.logAction(
        userId: userId,
        activityId: _currentActivity?.activityID ?? "NEW",
        action: UserPerformActivty.BREAKIN,
        companyId: companyId,
        teamId: teamId,
      );

      // Notify team manager on taking a break
      if (teamId != null && userName != null) {
        await _notificationRepo.addNotification(
          toUserId: teamId,
          fromUserName: userName,
          message: '$userName is on a break.',
          type: 'attendance_breakin',
        );
      }
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    } finally {
      _isPerformingAction = false;
      debugPrint('[Attendance] After break action: nextAction=${_currentActivity?.nextAction}, '
          'canTakeBreak=${_currentActivity?.canTakeBreak}, '
          'isPerformingAction=$_isPerformingAction');
    }
  }

  // ===========================================================================
  // Admin: Team attendance
  // ===========================================================================

  /// Loads all attendance records for [managerId]'s team on [date].
  Future<void> loadTeamAttendanceForDate({
    required String managerId,
    required String date,
  }) async {
    emit(TeamAttendanceLoadingState());
    try {
      _teamAttendanceRecords = await _repository.fetchTeamAttendanceForDate(
        managerId,
        date,
      );
      emit(TeamAttendanceLoadedState());
    } catch (e) {
      emit(TeamAttendanceErrorState(e.toString()));
    }
  }

  /// Admin: update a specific employee's attendance record.
  Future<void> updateEmployeeAttendance({
    required String userId,
    required String date,
    required Map<String, dynamic> updates,
  }) async {
    emit(AttendanceLoadingState());
    try {
      await _repository.updateAttendanceRecord(
        userId: userId,
        date: date,
        updates: updates,
      );
      emit(AttendanceSuccessState());
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    }
  }

  // ===========================================================================
  // Getters for UI
  // ===========================================================================

  UserActivityModel? get activity => _currentActivity;
  String get workingTime => _workingTime;
  String get breakTime => _breakTime;
  DateTime get selectedDate => _selectedDate;
  int get monthWorkedDays => _monthWorkedDays;
  int get monthLateMinutes => _monthLateMinutes;
  int get monthAbsenceDays => _monthAbsenceDays;
  int get monthPaidLeaveDays => _monthPaidLeaveDays;
  bool get isPerformingAction => _isPerformingAction;
  List<Map<String, dynamic>> get teamAttendanceRecords => _teamAttendanceRecords;

  @override
  Future<void> close() {
    _subscription?.cancel();
    _ticker?.cancel();
    return super.close();
  }
}
