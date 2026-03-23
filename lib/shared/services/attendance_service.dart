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
  /// Keys returned:
  /// - `daysWorked` (int)
  /// - `lateDays` (int)
  /// - `lateMinutes` (int)
  /// - `overtimeMinutes` (int)
  /// - `overtimeDays` (int)
  static Map<String, dynamic> analyseAttendance({
    required List<Map<String, dynamic>> attendanceDocs,
    required String companyStartTime,
    required String companyEndTime,
    required int lateGracePeriodMinutes,
  }) {
    int daysWorked = 0;
    int lateDays = 0;
    int totalLateMinutes = 0;
    int totalOvertimeMinutes = 0;
    int overtimeDays = 0;

    final companyStartMinutes = parseTimeToMinutes(companyStartTime);
    final companyEndMinutes = parseTimeToMinutes(companyEndTime);
    final standardWorkingMinutes = companyEndMinutes - companyStartMinutes;

    for (final doc in attendanceDocs) {
      // Must have checkIn to count as worked
      if (doc['checkIn'] == null) continue;

      daysWorked++;

      // --- Lateness ---
      final inTimeStr = doc['checkIn']['inTime'] as String?;
      if (inTimeStr != null) {
        final inMinutes = parseTimeToMinutes(inTimeStr);
        final lateBy = inMinutes - companyStartMinutes;
        if (lateBy > lateGracePeriodMinutes) {
          lateDays++;
          totalLateMinutes += lateBy;
        }
      }

      // --- Overtime (deducting breaks) ---
      final outTimeMap = doc['outTime'];
      if (outTimeMap != null && outTimeMap['outTime'] != null && inTimeStr != null) {
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
}

