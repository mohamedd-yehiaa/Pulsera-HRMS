import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/payroll_config_model.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_config_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/components/components.dart';

class GeneratePayrollScreen extends StatefulWidget {
  const GeneratePayrollScreen({super.key});

  @override
  State<GeneratePayrollScreen> createState() => _GeneratePayrollScreenState();
}

class _GeneratePayrollScreenState extends State<GeneratePayrollScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _override = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companyId = AppCubit.get(context).userModel?.companyId;
      if (companyId != null) {
        PayrollConfigCubit.get(context).loadConfig(companyId);
      }
    });
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Payroll Month',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _generatePayroll() {
    final appCubit = AppCubit.get(context);
    final company = appCubit.companyModel;
    final user = appCubit.userModel;
    final configCubit = PayrollConfigCubit.get(context);

    if (company == null || user?.companyId == null) {
      Fluttertoast.showToast(msg: 'Company data not available');
      return;
    }

    final config = configCubit.config ??
        PayrollConfigModel.defaults(companyId: user!.companyId!);

    final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);

    PayrollCubit.get(context).generateBulkPayroll(
      companyId: user!.companyId!,
      month: monthStr,
      companyWorkingDays:
          company.workingDays ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      companyStartTime: company.startTime ?? '09:00',
      companyEndTime: company.endTime ?? '17:00',
      config: config,
      override: _override,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Generate Payroll',
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
      body: BlocConsumer<PayrollCubit, PayrollStates>(
        listener: (context, state) {
          if (state is PayrollGeneratedSuccessState) {
            Fluttertoast.showToast(msg: 'Payroll generated successfully!');
            Navigator.pop(context);
          }
          if (state is PayrollErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Info Banner ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(IconBroken.Info_Circle,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payroll will be calculated using each employee\'s individual salary from their team profile. '
                          'Deduction rules are loaded from your payroll configuration.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Month Picker ---
                Text(
                  'Payroll Month',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                AppButton.appOulineButtonRow(
                  onPressed: _pickMonth,
                  label: DateFormat('MMMM yyyy').format(_selectedMonth),
                  context: context,
                  prefixIcon: Icon(IconBroken.Calendar,
                      color: AppColors.primary, size: 20),
                  suffixIcon: Icon(IconBroken.Arrow___Down_2,
                      color: AppColors.grey500, size: 18),
                ),
                const SizedBox(height: 20),

                // --- Override Toggle ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(IconBroken.Danger,
                          color: AppColors.orange500, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Override Existing Payroll',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Re-generate payroll even if it already exists for this month',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _override,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _override = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- Config Summary ---
                BlocBuilder<PayrollConfigCubit, PayrollConfigStates>(
                  builder: (context, configState) {
                    final config = PayrollConfigCubit.get(context).config;
                    if (config == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Rules',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _ruleRow(
                              'Absence Multiplier',
                              '${config.absenceMultiplier}× daily salary'),
                          _ruleRow(
                              'Late Grace',
                              '${config.lateGracePeriodMinutes} min'),
                          _ruleRow(
                              'Late Deduction',
                              config.lateDeductionMode == 'percentage'
                                  ? '${config.lateDeductionValue}% of daily salary'
                                  : '\$${config.lateDeductionValue}/min'),
                          _ruleRow(
                              'Overtime Min',
                              '${config.overtimeMinMinutes} min'),
                          _ruleRow(
                              'Overtime Bonus',
                              '${config.overtimeBonusPercentage}% of daily salary'),
                          _ruleRow(
                              'Early Leave',
                              config.earlyLeaveDeductionMode == 'percentage'
                                  ? '${config.earlyLeaveDeductionValue}% of daily salary'
                                  : '\$${config.earlyLeaveDeductionValue}/min'),
                          _ruleRow(
                              'Missing Checkout',
                              config.missingCheckoutPolicy == 'half_day'
                                  ? 'Count as Half Day'
                                  : 'Count as Absent'),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Generate Button ---
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state is PayrollGeneratingState
                        ? null
                        : _generatePayroll,
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: state is PayrollGeneratingState
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Generate for All Employees',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _ruleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.grey500)),
          Text(value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}
