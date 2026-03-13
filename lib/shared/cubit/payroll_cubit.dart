import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/payroll_config_model.dart';
import 'package:pulsera/models/payroll_model.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/payroll_repository.dart';
import 'package:pulsera/shared/services/attendance_service.dart';

class PayrollCubit extends Cubit<PayrollStates> {
  final PayrollRepository _repository;

  PayrollCubit(this._repository) : super(PayrollInitialState());

  static PayrollCubit get(context) => BlocProvider.of(context);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  List<PayrollModel> payrolls = [];
  PayrollModel? selectedPayroll;
  DateTime selectedMonth = DateTime.now();

  // ---------------------------------------------------------------------------
  // Role-based access control
  // ---------------------------------------------------------------------------
  static bool isPayrollAuthorized(String? userType) {
    return userType == 'Company Owner' || userType == 'Hr admin';
  }

  // ---------------------------------------------------------------------------
  // Month picker
  // ---------------------------------------------------------------------------
  void changeMonth(DateTime newMonth) {
    selectedMonth = newMonth;
    emit(PayrollMonthChangedState());
  }

  // ---------------------------------------------------------------------------
  // Select a payroll for detail view
  // ---------------------------------------------------------------------------
  void selectPayroll(PayrollModel payroll) {
    selectedPayroll = payroll;
    emit(PayrollLoadedState());
  }

  // ---------------------------------------------------------------------------
  // Load payrolls for a single employee (Employee's own view)
  // ---------------------------------------------------------------------------
  Future<void> loadPayrollsForEmployee(String employeeId) async {
    emit(PayrollLoadingState());
    try {
      payrolls = await _repository.getPayrollsByEmployee(employeeId);
      emit(PayrollLoadedState());
    } catch (e) {
      emit(PayrollErrorState(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Load payrolls for a company in a month (Admin view)
  // ---------------------------------------------------------------------------
  Future<void> loadPayrollsForCompany(String companyId, String month) async {
    emit(PayrollLoadingState());
    try {
      payrolls = await _repository.getPayrollsByCompanyAndMonth(companyId, month);
      emit(PayrollLoadedState());
    } catch (e) {
      emit(PayrollErrorState(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Generate payroll for ALL employees in a company
  // ---------------------------------------------------------------------------
  Future<void> generateBulkPayroll({
    required String companyId,
    required String month,
    required List<String> companyWorkingDays,
    required String companyStartTime,
    required String companyEndTime,
    required PayrollConfigModel config,
    bool override = false,
  }) async {
    emit(PayrollGeneratingState());
    try {
      // 1. Fetch all team members (including terminated within month)
      final members = await _repository.getCompanyTeamMembers(companyId, month);

      if (members.isEmpty) {
        emit(PayrollErrorState('No employees found for this company.'));
        return;
      }

      // 2. Generate payroll for each employee
      for (final member in members) {
        if (member.uId == null) continue;

        await _generateForEmployee(
          member: member,
          companyId: companyId,
          month: month,
          companyWorkingDays: companyWorkingDays,
          companyStartTime: companyStartTime,
          companyEndTime: companyEndTime,
          config: config,
          override: override,
        );
      }

      emit(PayrollGeneratedSuccessState());
    } catch (e) {
      emit(PayrollErrorState(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Core: Generate payroll for a SINGLE employee
  // ---------------------------------------------------------------------------
  Future<void> _generateForEmployee({
    required MembersData member,
    required String companyId,
    required String month,
    required List<String> companyWorkingDays,
    required String companyStartTime,
    required String companyEndTime,
    required PayrollConfigModel config,
    bool override = false,
  }) async {
    final payrollId = '${member.uId}_$month';

    // 1. Check for duplicate (handle override)
    final exists = await _repository.checkPayrollExists(member.uId!, month);
    if (exists && !override) {
      // Skip this employee — payroll already exists
      return;
    }
    if (exists && override) {
      await _repository.deletePayroll(payrollId);
    }

    // 2. Employee's basic salary
    final basicSalary = member.monthlySalary ?? 0.0;
    if (basicSalary <= 0) return; // Skip employees with no salary

    // 3. Determine employee's effective date range within the month
    final monthStart = DateTime.parse('$month-01');
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    DateTime effectiveStart = monthStart;
    DateTime effectiveEnd = monthEnd;

    // Employee joined mid-month
    if (member.joinedAt != null) {
      try {
        final joinDate = DateTime.parse(member.joinedAt!);
        if (joinDate.isAfter(monthStart)) {
          effectiveStart = joinDate;
        }
      } catch (_) {}
    }

    // Employee terminated mid-month
    if (member.status == 'Terminated' && member.endDate != null) {
      try {
        final endDate = DateTime.parse(member.endDate!);
        if (endDate.isBefore(monthEnd)) {
          effectiveEnd = endDate;
        }
      } catch (_) {}
    }

    // 4. Count total working days in the FULL month (for daily rate)
    final totalWorkingDays = AttendanceService.countWorkingDaysInMonth(month, companyWorkingDays);
    if (totalWorkingDays == 0) return;

    final dailySalary = basicSalary / totalWorkingDays;

    // 5. Count expected working days in the employee's effective range
    final expectedWorkingDays = AttendanceService.countWorkingDaysInRange(
      effectiveStart,
      effectiveEnd,
      companyWorkingDays,
    );

    // 6. Fetch approved leaves for this month
    final approvedLeaves = await _repository.fetchApprovedLeavesForMonth(
      member.uId!,
      month,
    );
    final paidVacationDays = _countApprovedLeaveDays(
      approvedLeaves,
      effectiveStart,
      effectiveEnd,
      companyWorkingDays,
    );

    // 7. Fetch attendance and analyse
    final attendanceDocs = await _repository.fetchAttendanceForMonth(
      member.uId!,
      month,
    );
    final analysis = AttendanceService.analyseAttendance(
      attendanceDocs: attendanceDocs,
      companyStartTime: companyStartTime,
      companyEndTime: companyEndTime,
      lateGracePeriodMinutes: config.lateGracePeriodMinutes,
    );

    final workedDays = analysis['daysWorked'] as int;
    final totalLateMinutes = analysis['lateMinutes'] as int;
    final totalOvertimeMinutes = analysis['overtimeMinutes'] as int;

    // 8. Unapproved absences
    final unapprovedAbsences = expectedWorkingDays - workedDays - paidVacationDays;
    final clampedAbsences = unapprovedAbsences > 0 ? unapprovedAbsences : 0;

    // 9. Calculate salary components
    final workedDaysSalary = workedDays * dailySalary;
    final paidVacationSalary = paidVacationDays * dailySalary;

    // 10. Absence deduction (configurable multiplier)
    final absenceDeduction = clampedAbsences * config.absenceMultiplier * dailySalary;

    // 11. Late deduction (configurable)
    double lateDeduction = 0.0;
    if (totalLateMinutes > 0) {
      if (config.lateDeductionMode == 'percentage') {
        // Percentage of daily salary per late day
        final lateDays = analysis['lateDays'] as int;
        lateDeduction = lateDays * (config.lateDeductionValue / 100) * dailySalary;
      } else {
        // Per-minute deduction
        lateDeduction = totalLateMinutes * config.lateDeductionValue;
      }
    }

    // 12. Overtime bonus (configurable)
    double overtimeBonus = 0.0;
    if (totalOvertimeMinutes >= config.overtimeMinMinutes &&
        config.overtimeBonusPercentage > 0) {
      // Count how many full overtime events (each day's overtime qualifies separately)
      final overtimeDays = analysis['overtimeDays'] as int;
      overtimeBonus = overtimeDays * (config.overtimeBonusPercentage / 100) * dailySalary;
    }

    // 13. Final salary
    final rawFinal = workedDaysSalary + paidVacationSalary -
        lateDeduction - absenceDeduction + overtimeBonus;
    final finalSalary = rawFinal < 0 ? 0.0 : rawFinal;

    // 14. Determine employee status label
    final employeeStatus = member.status == 'Terminated'
        ? 'Former Employee'
        : 'Active';

    // 15. Build and save model
    final payroll = PayrollModel(
      payrollId: payrollId,
      employeeId: member.uId,
      employeeName: member.fullName ?? '',
      companyId: companyId,
      month: month,
      generatedDate: DateTime.now().toIso8601String(),
      employeeStatus: employeeStatus,
      basicSalary: basicSalary,
      dailySalary: dailySalary,
      totalWorkingDays: totalWorkingDays,
      workedDays: workedDays,
      paidVacationDays: paidVacationDays,
      unapprovedAbsenceDays: clampedAbsences,
      lateMinutes: totalLateMinutes,
      overtimeMinutes: totalOvertimeMinutes,
      workedDaysSalary: workedDaysSalary,
      paidVacationSalary: paidVacationSalary,
      absenceDeduction: absenceDeduction,
      lateDeduction: lateDeduction,
      overtimeBonus: overtimeBonus,
      finalSalary: finalSalary,
    );

    await _repository.savePayroll(payroll);
  }

  // ===========================================================================
  // Private helpers
  // ===========================================================================

  // Delegates to AttendanceService for static methods
  static int countWorkingDaysInMonth(String yearMonth, List<String> companyWorkingDays) =>
      AttendanceService.countWorkingDaysInMonth(yearMonth, companyWorkingDays);

  static int countWorkingDaysInRange(
    DateTime start,
    DateTime end,
    List<String> companyWorkingDays,
  ) => AttendanceService.countWorkingDaysInRange(start, end, companyWorkingDays);

  /// Count approved leave days that fall on working days within the effective range.
  int _countApprovedLeaveDays(
    List<Map<String, dynamic>> approvedLeaves,
    DateTime effectiveStart,
    DateTime effectiveEnd,
    List<String> companyWorkingDays,
  ) {
    final workingWeekdays = AttendanceService.workingWeekdays(companyWorkingDays);

    // Collect all approved leave working days (dedup via Set)
    final Set<String> leaveDates = {};

    for (final leave in approvedLeaves) {
      final fromStr = leave['fromdate'] as String?;
      final toStr = leave['todate'] as String?;
      if (fromStr == null || toStr == null) continue;

      try {
        DateTime from = DateTime.parse(fromStr);
        DateTime to = DateTime.parse(toStr);

        // Clamp to effective range
        if (from.isBefore(effectiveStart)) from = effectiveStart;
        if (to.isAfter(effectiveEnd)) to = effectiveEnd;

        DateTime current = DateTime(from.year, from.month, from.day);
        final endDate = DateTime(to.year, to.month, to.day);

        while (!current.isAfter(endDate)) {
          if (workingWeekdays.contains(current.weekday)) {
            leaveDates.add(DateFormat('yyyy-MM-dd').format(current));
          }
          current = current.add(const Duration(days: 1));
        }
      } catch (_) {}
    }

    return leaveDates.length;
  }
}
