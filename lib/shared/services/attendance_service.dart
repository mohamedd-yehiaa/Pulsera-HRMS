import 'package:pulsera/models/work_schedule_config.dart';

/// Shared attendance analysis service.
///
/// Contains pure-logic utilities that both [AttendanceCubit] and [PayrollCubit]
/// can use, avoiding duplicated business rules.
class AttendanceService {
  AttendanceService._();

  // ===========================================================================
  // Shared Constants
  // ===========================================================================

  static const Map<String, int> dayCodeToWeekday = {
    'Mon': 1, 'Monday': 1,
    'Tue': 2, 'Tuesday': 2,
    'Wed': 3, 'Wednesday': 3,
    'Thu': 4, 'Thursday': 4,
    'Fri': 5, 'Friday': 5,
    'Sat': 6, 'Saturday': 6,
    'Sun': 7, 'Sunday': 7,
  };

  // ===========================================================================
  // Working-day helpers
  // ===========================================================================

  /// Converts a list of company working-day codes (e.g. ['Mon','Tue'])
  /// into a set of Dart [DateTime.weekday] ints.
  static Set<int> workingWeekdays(List<String> companyWorkingDays) {
    return companyWorkingDays
        .map((code) => dayCodeToWeekday[code])
        .whereType<int>()
        .toSet();
  }

  /// Count working days in [yearMonth] (format "YYYY-MM").
  static int countWorkingDaysInMonth(
    String yearMonth,
    List<String> companyWorkingDays,
  ) {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    return countWorkingDaysInRange(firstDay, lastDay, companyWorkingDays);
  }

  /// Count working days between [start] and [end] (inclusive).
  static int countWorkingDaysInRange(
    DateTime start,
    DateTime end,
    List<String> companyWorkingDays,
  ) {
    final days = workingWeekdays(companyWorkingDays);
    int count = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      if (days.contains(current.weekday)) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  // ===========================================================================
  // Time parsing helpers
  // ===========================================================================

  /// Parse "HH:mm:ss" or "HH:mm" into total minutes since midnight.
  static int parseTimeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Format total minutes into "HH:mm" display string.
  static String formatMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // Break-time calculation
  // ===========================================================================

  /// Calculates total break minutes from paired break-in / break-out lists.
  ///
  /// Each break period = breakOutTime[i] − breakInTime[i].
  /// Only completed pairs are counted (if breakIn has 3 entries but breakOut
  /// has only 2, the third ongoing break is ignored).
  static int calculateBreakMinutes(
    List<String>? breakInTimes,
    List<String>? breakOutTimes,
  ) {
    if (breakInTimes == null || breakOutTimes == null) return 0;

    int totalBreak = 0;
    final pairs = breakInTimes.length < breakOutTimes.length
        ? breakInTimes.length
        : breakOutTimes.length;

    for (int i = 0; i < pairs; i++) {
      try {
        final inMin = parseTimeToMinutes(breakInTimes[i]);
        final outMin = parseTimeToMinutes(breakOutTimes[i]);
        if (outMin > inMin) totalBreak += (outMin - inMin);
      } catch (_) {}
    }
    return totalBreak;
  }

  /// Calculates net worked minutes = (outTime − inTime) − breakMinutes.
  ///
  /// Returns 0 if check-in or check-out is missing.
  static int calculateWorkedMinutes({
    required String? inTime,
    required String? outTimeStr,
    List<String>? breakInTimes,
    List<String>? breakOutTimes,
  }) {
    if (inTime == null || outTimeStr == null) return 0;
    try {
      final inMin = parseTimeToMinutes(inTime);
      final outMin = parseTimeToMinutes(outTimeStr);
      final breakMin = calculateBreakMinutes(breakInTimes, breakOutTimes);
      final net = outMin - inMin - breakMin;
      return net > 0 ? net : 0;
    } catch (_) {
      return 0;
    }
  }

  // ===========================================================================
  // Attendance analysis (used by Payroll)
  // ===========================================================================

  /// Analyses a list of raw attendance Firestore documents and returns
  /// aggregate metrics for payroll calculation.
  ///
  /// [approvedLeaveDates] — set of 'yyyy-MM-dd' strings for approved leave
  /// days. Attendance records on these dates are excluded from workedDays
  /// to prevent double-counting (leave is already counted as a paid day).
  ///
  /// Keys returned:
  /// - `daysWorked` (int)
  /// - `lateDays` (int)
  /// - `lateMinutes` (int)
  /// - `overtimeMinutes` (int)
  /// - `overtimeDays` (int)
  /// - `earlyLeaveDays` (int)
  /// - `earlyLeaveMinutes` (int)
  /// - `missingCheckoutDays` (int)
  static Map<String, dynamic> analyseAttendance({
    required List<Map<String, dynamic>> attendanceDocs,
    required String companyStartTime,
    required String companyEndTime,
    required int lateGracePeriodMinutes,
    Set<String>? approvedLeaveDates,
  }) {
    int daysWorked = 0;
    int lateDays = 0;
    int totalLateMinutes = 0;
    int totalOvertimeMinutes = 0;
    int overtimeDays = 0;
    int earlyLeaveDays = 0;
    int totalEarlyLeaveMinutes = 0;
    int missingCheckoutDays = 0;

    final leaveDates = approvedLeaveDates ?? <String>{};
    final companyStartMinutes = parseTimeToMinutes(companyStartTime);
    final companyEndMinutes = parseTimeToMinutes(companyEndTime);
    final standardWorkingMinutes = companyEndMinutes - companyStartMinutes;

    for (final doc in attendanceDocs) {
      // Must have checkIn to count as worked
      if (doc['checkIn'] == null) continue;

      // --- Leave-Attendance dedup ---
      // If this date has an approved leave, skip it from worked-day count.
      // The leave is already counted as a paid day separately.
      final docId = doc['docId'] as String?; // 'yyyy-MM-dd'
      if (docId != null && leaveDates.contains(docId)) continue;

      // --- Missing checkout detection ---
      final outTimeMap = doc['outTime'];
      final hasCheckout = outTimeMap != null && outTimeMap['outTime'] != null;
      if (!hasCheckout) {
        missingCheckoutDays++;
        // Still count as worked (policy decides how to handle in payroll)
        daysWorked++;
        continue; // No further analysis possible without checkout
      }

      daysWorked++;

      final inTimeStr = doc['checkIn']['inTime'] as String?;
      if (inTimeStr == null) continue;

      // --- Lateness (prefer stored value, fall back to calculation) ---
      final storedLateMinutes = doc['lateMinutes'] as int?;
      if (storedLateMinutes != null && storedLateMinutes > 0) {
        lateDays++;
        totalLateMinutes += storedLateMinutes;
      } else if (storedLateMinutes == null) {
        // Fall back to recalculation for old records
        final inMinutes = parseTimeToMinutes(inTimeStr);
        final lateBy = inMinutes - companyStartMinutes;
        if (lateBy > lateGracePeriodMinutes) {
          lateDays++;
          totalLateMinutes += lateBy;
        }
      }

      // --- Early Leave (prefer stored value, fall back to calculation) ---
      final storedEarlyLeaveMinutes = doc['earlyLeaveMinutes'] as int?;
      if (storedEarlyLeaveMinutes != null && storedEarlyLeaveMinutes > 0) {
        earlyLeaveDays++;
        totalEarlyLeaveMinutes += storedEarlyLeaveMinutes;
      } else if (storedEarlyLeaveMinutes == null) {
        final outStr = outTimeMap['outTime'] as String;
        final outMinutes = parseTimeToMinutes(outStr);
        final earlyBy = companyEndMinutes - outMinutes;
        if (earlyBy > 0) {
          earlyLeaveDays++;
          totalEarlyLeaveMinutes += earlyBy;
        }
      }

      // --- Overtime (prefer stored value, fall back to calculation) ---
      final storedOvertimeMinutes = doc['overtimeMinutes'] as int?;
      if (storedOvertimeMinutes != null && storedOvertimeMinutes > 0) {
        totalOvertimeMinutes += storedOvertimeMinutes;
        overtimeDays++;
      } else if (storedOvertimeMinutes == null) {
        final outStr = outTimeMap['outTime'] as String;
        try {
          final breakMin = calculateBreakMinutes(
            (doc['breakInTime'] as List<dynamic>?)?.cast<String>(),
            (doc['breakOutTime'] as List<dynamic>?)?.cast<String>(),
          );
          final inMinutes = parseTimeToMinutes(inTimeStr);
          final outMinutes = parseTimeToMinutes(outStr);

          final netWorkedMinutes = outMinutes - inMinutes - breakMin;
          final extraMinutes = netWorkedMinutes - standardWorkingMinutes;
          if (extraMinutes > 0) {
            totalOvertimeMinutes += extraMinutes;
            overtimeDays++;
          }
        } catch (_) {}
      }
    }

    return {
      'daysWorked': daysWorked,
      'lateDays': lateDays,
      'lateMinutes': totalLateMinutes,
      'overtimeMinutes': totalOvertimeMinutes,
      'overtimeDays': overtimeDays,
      'earlyLeaveDays': earlyLeaveDays,
      'earlyLeaveMinutes': totalEarlyLeaveMinutes,
      'missingCheckoutDays': missingCheckoutDays,
    };
  }

  // ===========================================================================
  // Validation helpers
  // ===========================================================================

  /// Validates a check-in/check-out/break action, returning an error message
  /// or null if the action is valid.
  static String? validateAction({
    required String action, // 'IN', 'OUT', 'BREAKIN', 'BREAKOUT'
    required String? existingCheckIn,
    required String? existingCheckOut,
    required String timeNow,
    List<String>? breakInTimes,
    List<String>? breakOutTimes,
  }) {
    // --- Check-In validation ---
    if (action == 'IN' && existingCheckIn != null && existingCheckOut == null) {
      return 'Already checked in for today. Please check out first.';
    }
    if (action == 'IN' && existingCheckOut != null) {
      return 'Attendance already recorded for today.';
    }

    // --- Check-Out validation ---
    if (action == 'OUT' && existingCheckIn == null) {
      return 'Cannot check out without checking in first.';
    }
    if (action == 'OUT' && existingCheckOut != null) {
      return 'Already checked out for today.';
    }

    // Cannot check out while on an active break
    if (action == 'OUT') {
      final inCount = breakInTimes?.length ?? 0;
      final outCount = breakOutTimes?.length ?? 0;
      if (inCount > outCount) {
        return 'Cannot check out while on break. Please end your break first.';
      }
    }

    // Validate check-out time is after check-in time
    if (action == 'OUT' && existingCheckIn != null) {
      try {
        final inMin = parseTimeToMinutes(existingCheckIn);
        final outMin = parseTimeToMinutes(timeNow);
        if (outMin <= inMin) {
          return 'Check-out time must be after check-in time.';
        }
      } catch (_) {}
    }

    // --- Break-In validation ---
    if (action == 'BREAKIN') {
      if (existingCheckIn == null) {
        return 'Cannot start break without checking in first.';
      }
      if (existingCheckOut != null) {
        return 'Cannot start break after checking out.';
      }
      final inCount = breakInTimes?.length ?? 0;
      final outCount = breakOutTimes?.length ?? 0;
      if (inCount > outCount) {
        return 'Already on break. Please end your current break first.';
      }
    }

    // --- Break-Out validation ---
    if (action == 'BREAKOUT') {
      if (existingCheckIn == null) {
        return 'Cannot end break without checking in first.';
      }
      if (existingCheckOut != null) {
        return 'Cannot end break after checking out.';
      }
      final inCount = breakInTimes?.length ?? 0;
      final outCount = breakOutTimes?.length ?? 0;
      if (inCount <= outCount) {
        return 'No active break to end.';
      }
    }

    return null;
  }

  // ===========================================================================
  // Attendance status determination
  // ===========================================================================

  /// Determines whether an employee is 'present' or 'late' based on their
  /// check-in time compared to company start time + grace period.
  ///
  /// Returns 'late' if check-in is after [companyStartTime] + [graceMinutes],
  /// otherwise 'present'.
  static String determineAttendanceStatus({
    required String checkInTime,
    required String companyStartTime,
    int graceMinutes = 0,
  }) {
    try {
      final checkInMin = parseTimeToMinutes(checkInTime);
      final startMin = parseTimeToMinutes(companyStartTime);
      if (checkInMin > startMin + graceMinutes) {
        return 'late';
      }
      return 'present';
    } catch (_) {
      return 'present'; // Default if parsing fails
    }
  }

  /// Calculates worked minutes at the moment of check-out, deducting breaks.
  /// This is the value that gets persisted in Firestore for payroll.
  static int calculateWorkedMinutesOnCheckOut({
    required String checkInTime,
    required String checkOutTime,
    List<String>? breakInTimes,
    List<String>? breakOutTimes,
  }) {
    return calculateWorkedMinutes(
      inTime: checkInTime,
      outTimeStr: checkOutTime,
      breakInTimes: breakInTimes,
      breakOutTimes: breakOutTimes,
    );
  }

  // ===========================================================================
  // Time-window check-in validation
  // ===========================================================================

  /// Validates a check-in attempt against the work schedule configuration.
  ///
  /// Returns a [CheckInResult] with the status and a user-facing message.
  /// Check-in is always **allowed** but categorised as:
  /// - `early`     — before the allowed window
  /// - `on_time`   — within grace period
  /// - `late`      — after grace but before cutoff
  /// - `very_late` — after cutoff
  static CheckInResult validateCheckInTime(
    String timeNow,
    WorkScheduleConfig config,
  ) {
    try {
      final nowMin = parseTimeToMinutes(timeNow);
      final startMin = parseTimeToMinutes(config.workStartTime);
      final earliestAllowed = startMin - config.earlyAllowanceMinutes;
      final graceEnd = startMin + config.gracePeriodMinutes;
      final cutoff = startMin + config.lateCutoffMinutes;

      if (nowMin < earliestAllowed) {
        return CheckInResult(
          status: 'early',
          lateMinutes: 0,
          message: 'You are checking in early. '
              'Work starts at ${config.workStartTime}.',
        );
      }

      if (nowMin <= graceEnd) {
        return CheckInResult(
          status: 'on_time',
          lateMinutes: 0,
          message: 'On time! Have a great day.',
        );
      }

      if (nowMin <= cutoff) {
        final late = nowMin - graceEnd;
        return CheckInResult(
          status: 'late',
          lateMinutes: late,
          message: 'You are late by $late minutes.',
        );
      }

      // Past cutoff — allowed but marked very late
      final late = nowMin - graceEnd;
      return CheckInResult(
        status: 'very_late',
        lateMinutes: late,
        message: 'You are very late by $late minutes.',
      );
    } catch (_) {
      return CheckInResult(
        status: 'on_time',
        lateMinutes: 0,
        message: 'Checked in.',
      );
    }
  }

  // ===========================================================================
  // Time-window check-out validation
  // ===========================================================================

  /// Validates a check-out attempt against the work schedule configuration.
  ///
  /// Returns a [CheckOutResult] with the status and user-facing message.
  static CheckOutResult validateCheckOutTime(
    String timeNow,
    String checkInTime,
    WorkScheduleConfig config, {
    List<String>? breakInTimes,
    List<String>? breakOutTimes,
  }) {
    try {
      final nowMin = parseTimeToMinutes(timeNow);
      final endMin = parseTimeToMinutes(config.workEndTime);

      final workedMin = calculateWorkedMinutes(
        inTime: checkInTime,
        outTimeStr: timeNow,
        breakInTimes: breakInTimes,
        breakOutTimes: breakOutTimes,
      );

      final minWorkMinutes = config.minimumWorkHours * 60;

      // Early leave
      if (nowMin < endMin) {
        final earlyBy = endMin - nowMin;

        if (workedMin < minWorkMinutes) {
          return CheckOutResult(
            status: 'insufficient_hours',
            earlyLeaveMinutes: earlyBy,
            overtimeMinutes: 0,
            workedMinutes: workedMin,
            message: 'Early leave by $earlyBy min. '
                'Worked ${formatMinutes(workedMin)} — '
                'below minimum ${config.minimumWorkHours}h.',
          );
        }

        return CheckOutResult(
          status: 'early_leave',
          earlyLeaveMinutes: earlyBy,
          overtimeMinutes: 0,
          workedMinutes: workedMin,
          message: 'You are checking out $earlyBy minutes early.',
        );
      }

      // Overtime
      if (nowMin > endMin) {
        final overtime = nowMin - endMin;
        return CheckOutResult(
          status: 'overtime',
          earlyLeaveMinutes: 0,
          overtimeMinutes: overtime,
          workedMinutes: workedMin,
          message: 'Great work! ${formatMinutes(overtime)} overtime today.',
        );
      }

      // Exactly on time
      return CheckOutResult(
        status: 'completed',
        earlyLeaveMinutes: 0,
        overtimeMinutes: 0,
        workedMinutes: workedMin,
        message: 'Day completed. Well done!',
      );
    } catch (_) {
      final workedMin = calculateWorkedMinutes(
        inTime: checkInTime,
        outTimeStr: timeNow,
        breakInTimes: breakInTimes,
        breakOutTimes: breakOutTimes,
      );
      return CheckOutResult(
        status: 'completed',
        earlyLeaveMinutes: 0,
        overtimeMinutes: 0,
        workedMinutes: workedMin,
        message: 'Checked out.',
      );
    }
  }

  // ===========================================================================
  // Calculation helpers for late / early-leave / overtime
  // ===========================================================================

  /// Minutes late past grace period. Returns 0 if on time or early.
  static int calculateLateMinutes(
    String checkInTime,
    String workStartTime,
    int gracePeriodMinutes,
  ) {
    try {
      final inMin = parseTimeToMinutes(checkInTime);
      final graceEnd = parseTimeToMinutes(workStartTime) + gracePeriodMinutes;
      return inMin > graceEnd ? inMin - graceEnd : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Minutes before workEndTime. Returns 0 if at or after end time.
  static int calculateEarlyLeaveMinutes(
    String checkOutTime,
    String workEndTime,
  ) {
    try {
      final outMin = parseTimeToMinutes(checkOutTime);
      final endMin = parseTimeToMinutes(workEndTime);
      return outMin < endMin ? endMin - outMin : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Minutes worked past workEndTime. Returns 0 if before or at end time.
  static int calculateOvertimeMinutes(
    String checkOutTime,
    String workEndTime,
  ) {
    try {
      final outMin = parseTimeToMinutes(checkOutTime);
      final endMin = parseTimeToMinutes(workEndTime);
      return outMin > endMin ? outMin - endMin : 0;
    } catch (_) {
      return 0;
    }
  }
}

// ===========================================================================
// Result classes
// ===========================================================================

/// Result of a check-in time validation.
class CheckInResult {
  /// 'early', 'on_time', 'late', or 'very_late'.
  final String status;

  /// Minutes late past grace period (0 if not late).
  final int lateMinutes;

  /// User-facing message.
  final String message;

  const CheckInResult({
    required this.status,
    required this.lateMinutes,
    required this.message,
  });
}

/// Result of a check-out time validation.
class CheckOutResult {
  /// 'early_leave', 'completed', 'overtime', or 'insufficient_hours'.
  final String status;

  /// Minutes before workEndTime (0 if not early).
  final int earlyLeaveMinutes;

  /// Minutes past workEndTime (0 if not overtime).
  final int overtimeMinutes;

  /// Net worked minutes.
  final int workedMinutes;

  /// User-facing message.
  final String message;

  const CheckOutResult({
    required this.status,
    required this.earlyLeaveMinutes,
    required this.overtimeMinutes,
    required this.workedMinutes,
    required this.message,
  });
}
