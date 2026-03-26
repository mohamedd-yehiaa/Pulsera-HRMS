import 'package:flutter_test/flutter_test.dart';
import 'package:pulsera/models/work_schedule_config.dart';
import 'package:pulsera/shared/services/attendance_service.dart';

void main() {
  // ===========================================================================
  // calculateWorkedMinutes
  // ===========================================================================
  group('calculateWorkedMinutes', () {
    test('returns correct net worked minutes for a normal day', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: '09:00:00',
        outTimeStr: '17:00:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: ['13:00:00'],
      );
      // 8h gross - 1h break = 7h = 420 min
      expect(result, 420);
    });

    test('returns correct minutes with no breaks', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: '09:00:00',
        outTimeStr: '17:00:00',
      );
      // 8h gross, no breaks = 480 min
      expect(result, 480);
    });

    test('returns 0 when inTime is null', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: null,
        outTimeStr: '17:00:00',
      );
      expect(result, 0);
    });

    test('returns 0 when outTimeStr is null', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: '09:00:00',
        outTimeStr: null,
      );
      expect(result, 0);
    });

    test('handles multiple breaks correctly', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: '08:00:00',
        outTimeStr: '18:00:00',
        breakInTimes: ['10:00:00', '14:00:00'],
        breakOutTimes: ['10:30:00', '14:30:00'],
      );
      // 10h gross - 1h total breaks = 9h = 540 min
      expect(result, 540);
    });

    test('returns 0 when break exceeds worked time', () {
      final result = AttendanceService.calculateWorkedMinutes(
        inTime: '09:00:00',
        outTimeStr: '09:30:00',
        breakInTimes: ['09:05:00'],
        breakOutTimes: ['09:35:00'],
      );
      // would be negative → clamped to 0
      expect(result, 0);
    });
  });

  // ===========================================================================
  // calculateBreakMinutes
  // ===========================================================================
  group('calculateBreakMinutes', () {
    test('returns 0 for null break lists', () {
      final result = AttendanceService.calculateBreakMinutes(null, null);
      expect(result, 0);
    });

    test('returns 0 for empty break lists', () {
      final result = AttendanceService.calculateBreakMinutes([], []);
      expect(result, 0);
    });

    test('calculates single break correctly', () {
      final result = AttendanceService.calculateBreakMinutes(
        ['12:00:00'],
        ['12:45:00'],
      );
      expect(result, 45);
    });

    test('calculates multiple breaks correctly', () {
      final result = AttendanceService.calculateBreakMinutes(
        ['10:00:00', '14:00:00'],
        ['10:15:00', '14:30:00'],
      );
      // 15 + 30 = 45 min
      expect(result, 45);
    });

    test('ignores unpaired ongoing break (breakIn > breakOut)', () {
      final result = AttendanceService.calculateBreakMinutes(
        ['10:00:00', '14:00:00', '16:00:00'],
        ['10:15:00', '14:30:00'],
      );
      // Only 2 pairs counted: 15 + 30 = 45 min
      expect(result, 45);
    });

    test('ignores break where outTime < inTime', () {
      final result = AttendanceService.calculateBreakMinutes(
        ['14:00:00'],
        ['13:00:00'],
      );
      // outTime < inTime → not counted
      expect(result, 0);
    });
  });

  // ===========================================================================
  // validateAction (enhanced with BREAKIN/BREAKOUT)
  // ===========================================================================
  group('validateAction', () {
    // --- Check-In ---
    test('allows check-in when no prior record', () {
      final error = AttendanceService.validateAction(
        action: 'IN',
        existingCheckIn: null,
        existingCheckOut: null,
        timeNow: '09:00:00',
      );
      expect(error, isNull);
    });

    test('rejects double check-in', () {
      final error = AttendanceService.validateAction(
        action: 'IN',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '10:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('Already checked in'));
    });

    test('rejects check-in when day completed', () {
      final error = AttendanceService.validateAction(
        action: 'IN',
        existingCheckIn: '09:00:00',
        existingCheckOut: '17:00:00',
        timeNow: '18:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('already recorded'));
    });

    // --- Check-Out ---
    test('allows valid check-out', () {
      final error = AttendanceService.validateAction(
        action: 'OUT',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '17:00:00',
      );
      expect(error, isNull);
    });

    test('rejects check-out before check-in', () {
      final error = AttendanceService.validateAction(
        action: 'OUT',
        existingCheckIn: null,
        existingCheckOut: null,
        timeNow: '17:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('without checking in'));
    });

    test('rejects double check-out', () {
      final error = AttendanceService.validateAction(
        action: 'OUT',
        existingCheckIn: '09:00:00',
        existingCheckOut: '17:00:00',
        timeNow: '18:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('Already checked out'));
    });

    test('rejects check-out while on break', () {
      final error = AttendanceService.validateAction(
        action: 'OUT',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '17:00:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: [],
      );
      expect(error, isNotNull);
      expect(error, contains('while on break'));
    });

    test('rejects check-out time before check-in time', () {
      final error = AttendanceService.validateAction(
        action: 'OUT',
        existingCheckIn: '17:00:00',
        existingCheckOut: null,
        timeNow: '09:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('after check-in'));
    });

    // --- Break-In ---
    test('allows break-in when checked in and no active break', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKIN',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '12:00:00',
        breakInTimes: [],
        breakOutTimes: [],
      );
      expect(error, isNull);
    });

    test('rejects break-in without checking in', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKIN',
        existingCheckIn: null,
        existingCheckOut: null,
        timeNow: '12:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('without checking in'));
    });

    test('rejects break-in after checking out', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKIN',
        existingCheckIn: '09:00:00',
        existingCheckOut: '17:00:00',
        timeNow: '18:00:00',
      );
      expect(error, isNotNull);
      expect(error, contains('after checking out'));
    });

    test('rejects break-in when already on break', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKIN',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '14:00:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: [],
      );
      expect(error, isNotNull);
      expect(error, contains('Already on break'));
    });

    // --- Break-Out ---
    test('allows break-out when on active break', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKOUT',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '12:30:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: [],
      );
      expect(error, isNull);
    });

    test('rejects break-out without checking in', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKOUT',
        existingCheckIn: null,
        existingCheckOut: null,
        timeNow: '12:30:00',
      );
      expect(error, isNotNull);
      expect(error, contains('without checking in'));
    });

    test('rejects break-out when no active break', () {
      final error = AttendanceService.validateAction(
        action: 'BREAKOUT',
        existingCheckIn: '09:00:00',
        existingCheckOut: null,
        timeNow: '12:30:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: ['12:30:00'],
      );
      expect(error, isNotNull);
      expect(error, contains('No active break'));
    });
  });

  // ===========================================================================
  // determineAttendanceStatus
  // ===========================================================================
  group('determineAttendanceStatus', () {
    test('returns present when on-time', () {
      final status = AttendanceService.determineAttendanceStatus(
        checkInTime: '09:00:00',
        companyStartTime: '09:00:00',
      );
      expect(status, 'present');
    });

    test('returns present when within grace period', () {
      final status = AttendanceService.determineAttendanceStatus(
        checkInTime: '09:10:00',
        companyStartTime: '09:00:00',
        graceMinutes: 15,
      );
      expect(status, 'present');
    });

    test('returns late when after grace period', () {
      final status = AttendanceService.determineAttendanceStatus(
        checkInTime: '09:20:00',
        companyStartTime: '09:00:00',
        graceMinutes: 15,
      );
      expect(status, 'late');
    });

    test('returns present when early', () {
      final status = AttendanceService.determineAttendanceStatus(
        checkInTime: '08:30:00',
        companyStartTime: '09:00:00',
      );
      expect(status, 'present');
    });

    test('returns late when exactly 1 min after grace', () {
      final status = AttendanceService.determineAttendanceStatus(
        checkInTime: '09:16:00',
        companyStartTime: '09:00:00',
        graceMinutes: 15,
      );
      expect(status, 'late');
    });
  });

  // ===========================================================================
  // countWorkingDaysInMonth
  // ===========================================================================
  group('countWorkingDaysInMonth', () {
    test('counts working days for a full week (Mon-Fri)', () {
      // March 2026 has 22 weekdays (Mon-Fri)
      final count = AttendanceService.countWorkingDaysInMonth(
        '2026-03',
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );
      expect(count, 22);
    });

    test('counts working days for Sun-Thu pattern', () {
      // March 2026: Sun=5, Mon=5, Tue=5, Wed=4, Thu=4 → 23
      final count = AttendanceService.countWorkingDaysInMonth(
        '2026-03',
        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'],
      );
      expect(count, 23);
    });

    test('returns 0 for empty working days list', () {
      final count = AttendanceService.countWorkingDaysInMonth('2026-03', []);
      expect(count, 0);
    });
  });

  // ===========================================================================
  // countWorkingDaysInRange
  // ===========================================================================
  group('countWorkingDaysInRange', () {
    test('counts working days in a mid-month range', () {
      // March 10-20, 2026 (Tue-Fri, Mon-Fri)
      final count = AttendanceService.countWorkingDaysInRange(
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 20),
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );
      // Mar 10(Tue), 11(Wed), 12(Thu), 13(Fri), 16(Mon), 17(Tue), 18(Wed), 19(Thu), 20(Fri) = 9
      expect(count, 9);
    });

    test('returns 1 for single working day', () {
      final count = AttendanceService.countWorkingDaysInRange(
        DateTime(2026, 3, 10), // Tuesday
        DateTime(2026, 3, 10),
        ['Tue'],
      );
      expect(count, 1);
    });

    test('returns 0 for single non-working day', () {
      final count = AttendanceService.countWorkingDaysInRange(
        DateTime(2026, 3, 14), // Saturday
        DateTime(2026, 3, 14),
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );
      expect(count, 0);
    });
  });

  // ===========================================================================
  // calculateWorkedMinutesOnCheckOut
  // ===========================================================================
  group('calculateWorkedMinutesOnCheckOut', () {
    test('delegates correctly to calculateWorkedMinutes', () {
      final result = AttendanceService.calculateWorkedMinutesOnCheckOut(
        checkInTime: '09:00:00',
        checkOutTime: '17:00:00',
        breakInTimes: ['12:00:00'],
        breakOutTimes: ['13:00:00'],
      );
      expect(result, 420); // 7h = 420 min
    });
  });

  // ===========================================================================
  // parseTimeToMinutes
  // ===========================================================================
  group('parseTimeToMinutes', () {
    test('parses HH:mm:ss format', () {
      expect(AttendanceService.parseTimeToMinutes('09:30:00'), 570);
    });

    test('parses HH:mm format', () {
      expect(AttendanceService.parseTimeToMinutes('09:30'), 570);
    });

    test('parses midnight', () {
      expect(AttendanceService.parseTimeToMinutes('00:00:00'), 0);
    });

    test('parses end of day', () {
      expect(AttendanceService.parseTimeToMinutes('23:59'), 1439);
    });
  });

  // ===========================================================================
  // formatMinutes
  // ===========================================================================
  group('formatMinutes', () {
    test('formats 0 minutes', () {
      expect(AttendanceService.formatMinutes(0), '00:00');
    });

    test('formats 90 minutes as 01:30', () {
      expect(AttendanceService.formatMinutes(90), '01:30');
    });

    test('formats 480 minutes as 08:00', () {
      expect(AttendanceService.formatMinutes(480), '08:00');
    });
  });

  // ===========================================================================
  // validateCheckInTime
  // ===========================================================================
  group('validateCheckInTime', () {
    const config = WorkScheduleConfig(
      workStartTime: '09:00',
      workEndTime: '17:00',
      gracePeriodMinutes: 15,
      earlyAllowanceMinutes: 30,
      lateCutoffMinutes: 120,
      minimumWorkHours: 6,
    );

    test('returns early when before allowed window', () {
      final result = AttendanceService.validateCheckInTime('08:20:00', config);
      expect(result.status, 'early');
      expect(result.lateMinutes, 0);
      expect(result.message, contains('early'));
    });

    test('returns on_time at exact start time', () {
      final result = AttendanceService.validateCheckInTime('09:00:00', config);
      expect(result.status, 'on_time');
      expect(result.lateMinutes, 0);
    });

    test('returns on_time within grace period', () {
      final result = AttendanceService.validateCheckInTime('09:10:00', config);
      expect(result.status, 'on_time');
      expect(result.lateMinutes, 0);
    });

    test('returns on_time at exact grace boundary', () {
      final result = AttendanceService.validateCheckInTime('09:15:00', config);
      expect(result.status, 'on_time');
      expect(result.lateMinutes, 0);
    });

    test('returns late 1 minute after grace', () {
      final result = AttendanceService.validateCheckInTime('09:16:00', config);
      expect(result.status, 'late');
      expect(result.lateMinutes, 1);
      expect(result.message, contains('late'));
    });

    test('returns late with correct minutes', () {
      final result = AttendanceService.validateCheckInTime('09:45:00', config);
      expect(result.status, 'late');
      expect(result.lateMinutes, 30); // 09:45 - 09:15 = 30 min
    });

    test('returns late at exactly cutoff time', () {
      // cutoff = 09:00 + 120 = 11:00
      final result = AttendanceService.validateCheckInTime('11:00:00', config);
      expect(result.status, 'late');
      expect(result.lateMinutes, 105); // 11:00 - 09:15 = 105 min
    });

    test('returns very_late after cutoff', () {
      final result = AttendanceService.validateCheckInTime('11:01:00', config);
      expect(result.status, 'very_late');
      expect(result.lateMinutes, 106); // 11:01 - 09:15 = 106 min
      expect(result.message, contains('very late'));
    });

    test('returns very_late with correct minutes for very late arrival', () {
      final result = AttendanceService.validateCheckInTime('12:00:00', config);
      expect(result.status, 'very_late');
      expect(result.lateMinutes, 165); // 12:00 - 09:15 = 165 min
    });

    test('returns on_time at earliest allowed time', () {
      // earliest = 09:00 - 30 = 08:30
      final result = AttendanceService.validateCheckInTime('08:30:00', config);
      expect(result.status, 'on_time');
      expect(result.lateMinutes, 0);
    });
  });

  // ===========================================================================
  // validateCheckOutTime
  // ===========================================================================
  group('validateCheckOutTime', () {
    const config = WorkScheduleConfig(
      workStartTime: '09:00',
      workEndTime: '17:00',
      gracePeriodMinutes: 15,
      earlyAllowanceMinutes: 30,
      lateCutoffMinutes: 120,
      minimumWorkHours: 6,
    );

    test('returns early_leave when checking out before end time', () {
      final result = AttendanceService.validateCheckOutTime(
        '16:00:00', '09:00:00', config,
      );
      expect(result.status, 'early_leave');
      expect(result.earlyLeaveMinutes, 60);
      expect(result.overtimeMinutes, 0);
      expect(result.message, contains('60 minutes early'));
    });

    test('returns completed when checking out exactly at end time', () {
      final result = AttendanceService.validateCheckOutTime(
        '17:00:00', '09:00:00', config,
      );
      expect(result.status, 'completed');
      expect(result.earlyLeaveMinutes, 0);
      expect(result.overtimeMinutes, 0);
      expect(result.workedMinutes, 480);
    });

    test('returns overtime when checking out after end time', () {
      final result = AttendanceService.validateCheckOutTime(
        '18:00:00', '09:00:00', config,
      );
      expect(result.status, 'overtime');
      expect(result.earlyLeaveMinutes, 0);
      expect(result.overtimeMinutes, 60);
      expect(result.workedMinutes, 540);
    });

    test('returns insufficient_hours when worked less than minimum', () {
      // Check in at 09:00, check out at 13:00 = 4h < 6h minimum
      final result = AttendanceService.validateCheckOutTime(
        '13:00:00', '09:00:00', config,
      );
      expect(result.status, 'insufficient_hours');
      expect(result.earlyLeaveMinutes, 240); // 17:00 - 13:00 = 240 min
      expect(result.workedMinutes, 240);
      expect(result.message, contains('below minimum'));
    });

    test('returns early_leave when worked more than min but before end', () {
      // Check in at 09:00, check out at 16:00 = 7h > 6h min, still early
      final result = AttendanceService.validateCheckOutTime(
        '16:00:00', '09:00:00', config,
      );
      expect(result.status, 'early_leave');
      expect(result.earlyLeaveMinutes, 60);
      expect(result.workedMinutes, 420);
    });

    test('accounts for breaks in worked time', () {
      // In 09:00, break 12:00-13:00, out 17:00 = 7h
      final result = AttendanceService.validateCheckOutTime(
        '17:00:00', '09:00:00', config,
        breakInTimes: ['12:00:00'],
        breakOutTimes: ['13:00:00'],
      );
      expect(result.status, 'completed');
      expect(result.workedMinutes, 420); // 8h - 1h break = 7h
    });

    test('overtime calculation with breaks', () {
      // In 09:00, break 12:00-13:00, out 18:30 = 8.5h worked
      final result = AttendanceService.validateCheckOutTime(
        '18:30:00', '09:00:00', config,
        breakInTimes: ['12:00:00'],
        breakOutTimes: ['13:00:00'],
      );
      expect(result.status, 'overtime');
      expect(result.overtimeMinutes, 90); // 18:30 - 17:00 = 90 min
      expect(result.workedMinutes, 510); // 9.5h - 1h = 8.5h = 510 min
    });
  });

  // ===========================================================================
  // calculateLateMinutes
  // ===========================================================================
  group('calculateLateMinutes', () {
    test('returns 0 when on time', () {
      expect(
        AttendanceService.calculateLateMinutes('09:00:00', '09:00', 15),
        0,
      );
    });

    test('returns 0 when within grace period', () {
      expect(
        AttendanceService.calculateLateMinutes('09:10:00', '09:00', 15),
        0,
      );
    });

    test('returns correct minutes when late', () {
      expect(
        AttendanceService.calculateLateMinutes('09:30:00', '09:00', 15),
        15, // 09:30 - 09:15 = 15 min
      );
    });

    test('returns 0 when early', () {
      expect(
        AttendanceService.calculateLateMinutes('08:30:00', '09:00', 15),
        0,
      );
    });
  });

  // ===========================================================================
  // calculateEarlyLeaveMinutes
  // ===========================================================================
  group('calculateEarlyLeaveMinutes', () {
    test('returns 0 when at end time', () {
      expect(
        AttendanceService.calculateEarlyLeaveMinutes('17:00:00', '17:00'),
        0,
      );
    });

    test('returns 0 when after end time', () {
      expect(
        AttendanceService.calculateEarlyLeaveMinutes('18:00:00', '17:00'),
        0,
      );
    });

    test('returns correct minutes when early', () {
      expect(
        AttendanceService.calculateEarlyLeaveMinutes('16:30:00', '17:00'),
        30,
      );
    });

    test('returns correct minutes for very early leave', () {
      expect(
        AttendanceService.calculateEarlyLeaveMinutes('14:00:00', '17:00'),
        180,
      );
    });
  });

  // ===========================================================================
  // calculateOvertimeMinutes
  // ===========================================================================
  group('calculateOvertimeMinutes', () {
    test('returns 0 when at end time', () {
      expect(
        AttendanceService.calculateOvertimeMinutes('17:00:00', '17:00'),
        0,
      );
    });

    test('returns 0 when before end time', () {
      expect(
        AttendanceService.calculateOvertimeMinutes('16:30:00', '17:00'),
        0,
      );
    });

    test('returns correct minutes when overtime', () {
      expect(
        AttendanceService.calculateOvertimeMinutes('18:30:00', '17:00'),
        90,
      );
    });
  });
}
