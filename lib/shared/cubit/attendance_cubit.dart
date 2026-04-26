import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/work_schedule_config.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/services/totp_service.dart';
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

  // QR location verification flag — must be true before any Firestore write
  bool _isLocationVerified = false;

  // Rate-limit: timestamp of last successful validation
  DateTime? _lastValidationTime;

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
          'canTakeBreak=${activity?.canTakeBreak}, '
          'checkInStatus=${activity?.checkInStatus}, '
          'checkOutStatus=${activity?.checkOutStatus}');
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
  // QR Location Validation — single source of truth
  // ===========================================================================

  /// Validates a scanned QR hash against the company's shared secret.
  ///
  /// This is the ONLY entry point for QR validation. The UI passes the raw
  /// scanned hash here; the Cubit decides validity.
  ///
  /// Flow:
  /// 1. If [sharedSecret] is null → block, emit error (no fallback)
  /// 2. Validate via [TotpService.validate]
  /// 3. If valid → emit [LocationVerifiedState], call [onSuccess]
  /// 4. If invalid → emit [LocationValidationFailedState], do NOT call [onSuccess]
  void validateAndExecute({
    required String scannedHash,
    required String? sharedSecret,
    required VoidCallback onSuccess,
  }) {
    // Block: No shared_secret configured
    if (sharedSecret == null || sharedSecret.isEmpty) {
      emit(LocationValidationFailedState(
        'Company must configure QR verification',
      ));
      return;
    }

    // Rate-limit: prevent spam scans (minimum 2 seconds between validations)
    final now = DateTime.now();
    if (_lastValidationTime != null &&
        now.difference(_lastValidationTime!).inSeconds < 2) {
      return;
    }

    emit(LocationScanningState());

    final isValid = TotpService.validate(scannedHash, sharedSecret);

    if (!isValid) {
      _isLocationVerified = false;
      emit(LocationValidationFailedState('Invalid QR or Expired'));
      return;
    }

    // Validation succeeded
    _isLocationVerified = true;
    _lastValidationTime = now;
    emit(LocationVerifiedState());
    onSuccess();
  }

  // ===========================================================================
  // Swipe action (check-in/out, breaks) — with double-swipe guard
  // ===========================================================================

  // ===========================================================================
  // Pre-validation for confirmation UI
  // ===========================================================================

  /// Pre-validates an attendance action (check-in or check-out) to determine
  /// if the user is early/late, so the UI can show a confirmation dialog.
  ///
  /// Returns a user-facing message and status, or null if no schedule config.
  /// Does NOT modify state or write to Firestore.
  ({String status, String message})? preValidateAction({
    required WorkScheduleConfig? scheduleConfig,
  }) {
    if (scheduleConfig == null) return null;

    final nextAction = _currentActivity?.nextAction ?? UserPerformActivty.IN;
    final timeNow = DateFormat("HH:mm:ss").format(DateTime.now());

    if (nextAction == UserPerformActivty.IN) {
      final result = AttendanceService.validateCheckInTime(
        timeNow,
        scheduleConfig,
      );
      return (status: result.status, message: result.message);
    }

    if (nextAction == UserPerformActivty.OUT) {
      final checkInTime = _currentActivity?.checkIn?.inTime;
      if (checkInTime != null) {
        final result = AttendanceService.validateCheckOutTime(
          timeNow,
          checkInTime,
          scheduleConfig,
          breakInTimes: _currentActivity?.breakInTime,
          breakOutTimes: _currentActivity?.breakOutTime,
        );
        return (status: result.status, message: result.message);
      }
    }

    return null;
  }

  Future<void> performSwipeAction(
    String userId,
    String companyId, {
    String? teamId,
    String? companyStartTime,
    int lateGracePeriodMinutes = 0,
    String? userName,
    WorkScheduleConfig? scheduleConfig,
  }) async {
    // Prevent double-swipe
    if (_isPerformingAction) return;

    // Use model's nextAction — single source of truth (DRY)
    final nextAction = _currentActivity?.nextAction ?? UserPerformActivty.IN;

    // Don't allow action if day is already done
    if (nextAction == UserPerformActivty.DONE) return;

    _isPerformingAction = true;

    // Guard: no Firestore write without location verification
    if (!_isLocationVerified) {
      _isPerformingAction = false;
      emit(LocationValidationFailedState(
        'Location verification required',
      ));
      return;
    }

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
        scheduleConfig: scheduleConfig,
      );

      // Generate user-facing message from schedule config (emitted once via state)
      String? feedbackMessage;
      if (scheduleConfig != null) {
        final timeNow = DateFormat("HH:mm:ss").format(DateTime.now());
        if (nextAction == UserPerformActivty.IN) {
          final result = AttendanceService.validateCheckInTime(
            timeNow,
            scheduleConfig,
          );
          feedbackMessage = result.message;
        } else if (nextAction == UserPerformActivty.OUT) {
          final checkInTime = _currentActivity?.checkIn?.inTime;
          if (checkInTime != null) {
            final result = AttendanceService.validateCheckOutTime(
              timeNow,
              checkInTime,
              scheduleConfig,
              breakInTimes: _currentActivity?.breakInTime,
              breakOutTimes: _currentActivity?.breakOutTime,
            );
            feedbackMessage = result.message;
          }
        }
      }

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

      // Emit completed state with feedback — fires the toast exactly once
      emit(AttendanceActionCompletedState(message: feedbackMessage));
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    } finally {
      _isPerformingAction = false;
      _isLocationVerified = false; // Reset after each action
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

    // Guard: no Firestore write without location verification
    if (!_isLocationVerified) {
      _isPerformingAction = false;
      emit(LocationValidationFailedState(
        'Location verification required',
      ));
      return;
    }

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
      _isLocationVerified = false; // Reset after each action
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