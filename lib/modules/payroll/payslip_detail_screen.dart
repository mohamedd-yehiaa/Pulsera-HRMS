import 'package:flutter/material.dart';
import 'package:pulsera/models/payroll_model.dart';
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
        appBar: AppBar(title: const Text('Payslip')),
        body: const Center(child: Text('No payroll selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Payslip Details',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconBroken.Arrow___Left_2,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Header Card ---
            _buildHeaderCard(context, payroll),
            const SizedBox(height: 20),

            // --- Attendance Summary ---
            _buildSectionTitle(context, 'Attendance Summary'),
            const SizedBox(height: 12),
            _buildAttendanceSummary(context, payroll),
            const SizedBox(height: 20),

            // --- Earnings Breakdown ---
            _buildSectionTitle(context, 'Earnings'),
            const SizedBox(height: 12),
            _buildEarningsCard(context, payroll),
            const SizedBox(height: 20),

            // --- Deductions Breakdown ---
            _buildSectionTitle(context, 'Deductions'),
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
                  payroll.employeeName ?? 'Employee',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isFormer)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange500.withAlpha(200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Former Employee',
                    style: TextStyle(
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
            'Period: ${payroll.month ?? 'N/A'}',
            style: TextStyle(
              color: AppColors.white.withAlpha(200),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Base Salary: \$${payroll.basicSalary?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  color: AppColors.white.withAlpha(200),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Daily Rate: \$${payroll.dailySalary?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  color: AppColors.white.withAlpha(180),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Generated: ${_formatDate(payroll.generatedDate)}',
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
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Attendance Summary (6 stats)
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSummary(BuildContext context, PayrollModel payroll) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Calendar,
                '${payroll.totalWorkingDays ?? 0}',
                'Working Days',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Tick_Square,
                '${payroll.workedDays ?? 0}',
                'Worked',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Shield_Done,
                '${payroll.paidVacationDays ?? 0}',
                'Paid Leave',
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
                'Absences',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Time_Circle,
                '${payroll.lateMinutes ?? 0}m',
                'Late',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                IconBroken.Time_Square,
                '${payroll.overtimeMinutes ?? 0}m',
                'Overtime',
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
                '${payroll.earlyLeaveMinutes ?? 0}m',
                'Early Leave',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.warning_amber_rounded,
                '${payroll.missingCheckoutDays ?? 0}',
                'No Checkout',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.payments_outlined,
                '${payroll.totalPayableDays ?? (payroll.workedDays ?? 0) + (payroll.paidVacationDays ?? 0)}',
                'Payable Days',
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
            'Worked Days Salary',
            '+\$${payroll.workedDaysSalary?.toStringAsFixed(2) ?? '0.00'}',
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            'Paid Vacation Salary',
            '+\$${payroll.paidVacationSalary?.toStringAsFixed(2) ?? '0.00'}',
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            'Overtime Bonus',
            '+\$${payroll.overtimeBonus?.toStringAsFixed(2) ?? '0.00'}',
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
            'Absence Deduction',
            '-\$${payroll.absenceDeduction?.toStringAsFixed(2) ?? '0.00'}',
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            'Late Deduction',
            '-\$${payroll.lateDeduction?.toStringAsFixed(2) ?? '0.00'}',
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildLineItem(
            context,
            'Early Leave Deduction',
            '-\$${payroll.earlyLeaveDeduction?.toStringAsFixed(2) ?? '0.00'}',
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
            'Net Salary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '\$${payroll.finalSalary?.toStringAsFixed(2) ?? '0.00'}',
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
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grey500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
