import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/user_activity_model.dart';
import '../network/remote/attendance_repository.dart';
import '../services/attendance_service.dart';

class AttendanceCubit extends Cubit<AttendanceStates> {
  static AttendanceCubit get(context) => BlocProvider.of(context);
  final AttendanceRepository _repository;

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

  AttendanceCubit(this._repository) : super(AttendanceInitialState());

  void init(String userId) {

    emit(AttendanceLoadingState());

    _subscription?.cancel();
    _subscription = _repository
        .watchUserActivity(userId, DateFormat('yyyy-MM-dd').format(_selectedDate))
        .listen((activity) {

      // If activity is null, we still need to show the screen (with 00:00:00 time)
      _currentActivity = activity;

      if (activity != null && activity.checkIn?.inTime != null) {
        _updateBreakTime();
        if (activity.outTime == null) {
          _startWorkingTimer();
        } else {
          // Day completed — show final worked time
          _ticker?.cancel();
          _workingTime = _calculateFinalWorkedTime();
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
    emit(AttendanceChangeDateState());
    init(userId); // Re-fetch for the new date
  }

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

  Future<void> performSwipeAction(String userId, String companyId) async {
    // Logic to determine action based on your model lists
    final nextAction = _calculateNextAction();

    // Don't allow action if day is already done
    if (nextAction == UserPerformActivty.DONE) return;

    try {
      // Don't emit loading here if you want a smooth swipe,
      // or emit it if you want a blocker.
      await _repository.logAction(
        userId: userId,
        activityId: _currentActivity?.activityID ?? "NEW",
        action: nextAction,
        companyId: companyId,
      );
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    }
  }

  UserPerformActivty _calculateNextAction() {
    if (_currentActivity?.checkIn == null) return UserPerformActivty.IN;
    if (_currentActivity?.outTime != null) return UserPerformActivty.DONE;

    int inCount = _currentActivity?.breakInTime?.length ?? 0;
    int outCount = _currentActivity?.breakOutTime?.length ?? 0;

    return (inCount > outCount) ? UserPerformActivty.BREAKOUT : UserPerformActivty.BREAKIN;
  }

  // Getters for UI convenience
  UserActivityModel? get activity => _currentActivity;
  String get workingTime => _workingTime;
  String get breakTime => _breakTime;
  DateTime get selectedDate => _selectedDate;
  int get monthWorkedDays => _monthWorkedDays;
  int get monthLateMinutes => _monthLateMinutes;
  int get monthAbsenceDays => _monthAbsenceDays;
  int get monthPaidLeaveDays => _monthPaidLeaveDays;

  @override
  Future<void> close() {
    _subscription?.cancel();
    _ticker?.cancel();
    return super.close();
  }

}
