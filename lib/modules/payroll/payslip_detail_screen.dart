import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/models/payroll_model.dart';
import 'package:pulsera/shared/app_extension.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/payroll_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/styles/theme.dart';

class PayslipDetailScreen extends StatelessWidget {
  const PayslipDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PayrollModel? payroll = PayrollCubit.get(context).selectedPayroll;

    if (payroll == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context).payslip)),
        body: Center(child: Text(S.of(context).noPayrollSelected)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          S.of(context).payslipDetails,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Header Card ---
            _buildHeaderCard(context, payroll),
            const SizedBox(height: 20),

            // --- Attendance Summary ---
            _buildSectionTitle(context, S.of(context).attendanceSummary),
            const SizedBox(height: 12),
            _buildAttendanceSummary(context, payroll),
            const SizedBox(height: 20),

            // --- Earnings Breakdown ---
            _buildSectionTitle(context, S.of(context).earnings),
            const SizedBox(height: 12),
            _buildEarningsCard(context, payroll),
            const SizedBox(height: 20),

            // --- Deductions Breakdown ---
            _buildSectionTitle(context, S.of(context).deductions),
            const SizedBox(height: 12),
            _buildDeductionsCard(context, payroll),
            const SizedBox(height: 20),

            // --- Final Salary ---
            _buildFinalSalaryCard(context, payroll),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header Card
  // ---------------------------------------------------------------------------
  Widget _buildHeaderCard(BuildContext context, PayrollModel payroll) {
    final isFormer = payroll.employeeStatus == 'Former Employee';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.blue700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconBroken.Profile, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  payroll.employeeName ?? S.of(context).employee,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isFormer)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange500.withAlpha(200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    S.of(context).formerEmployee,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            S
                .of(context)
                .period((payroll.month ?? 'N/A').localizeDigits(context)),
            style: TextStyle(
              color: AppColors.white.withAlpha(200),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                S
                    .of(context)
                    .baseSalary(payroll.basicSalary.formatMoney(context)),
                style: TextStyle(
                  color: AppColors.white.withAlpha(200),
                  fontSize: 12,
                ),
              ),
              Text(
                S
                    .of(context)
                    .dailyRate(payroll.dailySalary.formatMoney(context)),
                style: TextStyle(
                  color: AppColors.white.withAlpha(180),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            S
                .of(context)
                .generated(_formatDate(payroll.generatedDate, context)),
            style: TextStyle(
              color: AppColors.white.withAlpha(180),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Title
  // ---------------------------------------------------------------------------
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      // The crucial fix to make titles dynamically pin Right or Left
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Attendance Summary (6 stats)
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSummary(BuildContext context, PayrollModel payroll) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final String minSuffix = isArabic ? 'د' : 'm';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Calendar,
                '${payroll.totalWorkingDays ?? 0}',
                S.of(context).workingDays,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Tick_Square,
                '${payroll.workedDays ?? 0}',
                S.of(context).workedDays,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Shield_Done,
                '${payroll.paidVacationDays ?? 0}',
                S.of(context).paidLeave,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Close_Square,
                '${payroll.unapprovedAbsenceDays ?? 0}',
                S.of(context).absences,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Time_Circle,
                '${payroll.lateMinutes ?? 0} $minSuffix',
                S.of(context).late,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Time_Square,
                '${payroll.overtimeMinutes ?? 0} $minSuffix',
                S.of(context).overtime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.exit_to_app,
                '${payroll.earlyLeaveMinutes ?? 0} $minSuffix',
                S.of(context).earlyLeave,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.warning_amber_rounded,
                '${payroll.missingCheckoutDays ?? 0}',
                S.of(context).noCheckout,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.payments_outlined,
                '${payroll.totalPayableDays ?? (payroll.workedDays ?? 0) + (payroll.paidVacationDays ?? 0)}',
                S.of(context).payableDays,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Earnings Card
  // ---------------------------------------------------------------------------
  Widget _buildEarningsCard(BuildContext context, PayrollModel payroll) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLineItem(
            context,
            S.of(context).workedDaysSalary,
            payroll.workedDaysSalary.formatMoney(context, prefix: '+'),
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            S.of(context).paidVacationSalary,
            payroll.paidVacationSalary.formatMoney(context, prefix: '+'),
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            S.of(context).overtimeBonus,
            payroll.overtimeBonus.formatMoney(context, prefix: '+'),
            AppColors.success,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Deductions Card
  // ---------------------------------------------------------------------------
  Widget _buildDeductionsCard(BuildContext context, PayrollModel payroll) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLineItem(
            context,
            S.of(context).absenceDeduction,
            payroll.absenceDeduction.formatMoney(context, prefix: '-'),
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            S.of(context).lateDeduction,
            payroll.lateDeduction.formatMoney(context, prefix: '-'),
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            S.of(context).earlyLeaveDeduction,
            payroll.earlyLeaveDeduction.formatMoney(context, prefix: '-'),
            AppColors.error,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Final Salary Card
  // ---------------------------------------------------------------------------
  Widget _buildFinalSalaryCard(BuildContext context, PayrollModel payroll) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).netSalary,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            payroll.finalSalary.formatMoney(context),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Widget _buildLineItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        // No redundant localizeDigits here, formatMoney handles it upstream!
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: boxDecoration,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          // Localize the raw integers and durations passed into the card
          Text(
            value.localizeDigits(context),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate, BuildContext context) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      final locale = Localizations.localeOf(context).toString();
      // localize the generated string output
      return DateFormat.yMMMd(locale).format(date).localizeDigits(context);
    } catch (_) {
      return isoDate;
    }
  }
}
