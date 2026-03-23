import 'package:flutter_test/flutter_test.dart';
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
}
