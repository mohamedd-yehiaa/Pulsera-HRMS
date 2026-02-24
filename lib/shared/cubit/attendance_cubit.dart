import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/user_activity_model.dart';
import '../network/remote/attendance_repository.dart';

class AttendanceCubit extends Cubit<AttendanceStates> {
  static AttendanceCubit get(context) => BlocProvider.of(context);
  final AttendanceRepository _repository;

  StreamSubscription? _subscription;
  Timer? _ticker;

  // Local variables to hold data while transitioning between success states
  UserActivityModel? _currentActivity;
  String _workingTime = "00:00:00";
  DateTime _selectedDate = DateTime.now();

  AttendanceCubit(this._repository) : super(AttendanceInitialState());

  void init(String userId) {

    emit(AttendanceLoadingState());

    _subscription?.cancel();
    _subscription = _repository
        .watchUserActivity(userId, DateFormat('yyyy-MM-dd').format(_selectedDate))
        .listen((activity) {

      // If activity is null, we still need to show the screen (with 00:00:00 time)
      _currentActivity = activity;

      if (activity != null) {
        _startWorkingTimer();
      } else {
        _workingTime = "00:00:00";
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
      final diff = DateTime.now().difference(startDateTime);
      _workingTime = diff.toString().split('.').first.padLeft(8, "0");

      // Emit success state every second to update the timer in UI
      emit(AttendanceSuccessState());
    });
  }

  Future<void> performSwipeAction(String userId, String companyId) async {
    // Logic to determine action based on your model lists
    final nextAction = _calculateNextAction();

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
    if (_currentActivity?.outTime != null) return UserPerformActivty.OUT;

    int inCount = _currentActivity?.breakInTime?.length ?? 0;
    int outCount = _currentActivity?.breakOutTime?.length ?? 0;

    return (inCount > outCount) ? UserPerformActivty.BREAKOUT : UserPerformActivty.BREAKIN;
  }

  // Getters for UI convenience
  UserActivityModel? get activity => _currentActivity;
  String get workingTime => _workingTime;
  DateTime get selectedDate => _selectedDate;

  @override
  Future<void> close() {
    _subscription?.cancel();
    _ticker?.cancel();
    return super.close();
  }

}
