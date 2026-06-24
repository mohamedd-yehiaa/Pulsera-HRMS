import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/payroll_config_model.dart';
import 'package:pulsera/shared/app_extension.dart';
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
      helpText: S.of(context).selectPayrollMonth,
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
      Fluttertoast.showToast(msg: S.of(context).companyDataNotAvailable);
      return;
    }

    final config =
        configCubit.config ??
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
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).generatePayroll,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: backButton(context),
      ),
      body: BlocConsumer<PayrollCubit, PayrollStates>(
        listener: (context, state) {
          if (state is PayrollGeneratedSuccessState) {
            Fluttertoast.showToast(msg: S.of(context).payrollGenerated);
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
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconBroken.Info_Circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          S.of(context).payrollInfoBanner,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Month Picker ---
                Text(
                  S.of(context).payrollMonth,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppButton.appOulineButtonRow(
                  onPressed: _pickMonth,
                  label: DateFormat(
                    'MMMM yyyy',
                    locale,
                  ).format(_selectedMonth).localizeDigits(context),
                  context: context,
                  prefixIcon: Icon(
                    IconBroken.Calendar,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    IconBroken.Arrow___Down_2,
                    color: AppColors.grey500,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Override Toggle ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconBroken.Danger,
                        color: AppColors.orange500,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).overrideExistingPayroll,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              S.of(context).overrideDescription,
                              style: Theme.of(context).textTheme.bodySmall
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
                            S.of(context).activeRules,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _ruleRow(
                            S.of(context).absenceMultiplier,
                            // Uses: "{value}× daily salary"
                            S
                                .of(context)
                                .timesDailySalary(
                                  config.absenceMultiplier.toString(),
                                ),
                          ),
                          _ruleRow(
                            S.of(context).lateGrace,
                            // Uses: "{value} min"
                            S
                                .of(context)
                                .minutesSuffix(
                                  config.lateGracePeriodMinutes.toString(),
                                ),
                          ),
                          _ruleRow(
                            S.of(context).lateDeductionRule,
                            config.lateDeductionMode == 'percentage'
                                // Uses: "{value}% of daily salary"
                                ? S
                                      .of(context)
                                      .percentOfDailySalary(
                                        config.lateDeductionValue.toString(),
                                      )
                                // Uses: "{value}/min" AND applies formatMoney to add LE/جم
                                : S
                                      .of(context)
                                      .perMinuteRate(
                                        config.lateDeductionValue.formatMoney(
                                          context,
                                        ),
                                      ),
                          ),
                          _ruleRow(
                            S.of(context).overtimeMin,
                            // Uses: "{value} min"
                            S
                                .of(context)
                                .minutesSuffix(
                                  config.overtimeMinMinutes.toString(),
                                ),
                          ),
                          _ruleRow(
                            S.of(context).overtimeBonusRule,
                            // Uses: "{value}% of daily salary"
                            S
                                .of(context)
                                .percentOfDailySalary(
                                  config.overtimeBonusPercentage.toString(),
                                ),
                          ),
                          _ruleRow(
                            S.of(context).earlyLeaveRule,
                            config.earlyLeaveDeductionMode == 'percentage'
                                // Uses: "{value}% of daily salary"
                                ? S
                                      .of(context)
                                      .percentOfDailySalary(
                                        config.earlyLeaveDeductionValue
                                            .toString(),
                                      )
                                // Uses: "{value}/min" AND applies formatMoney to add LE/جم
                                : S
                                      .of(context)
                                      .perMinuteRate(
                                        config.earlyLeaveDeductionValue
                                            .formatMoney(context),
                                      ),
                          ),
                          _ruleRow(
                            S.of(context).missingCheckoutRule,
                            config.missingCheckoutPolicy == 'half_day'
                                ? S.of(context).countAsHalfDay
                                : S.of(context).countAsAbsent,
                          ),
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
                        : Text(
                            S.of(context).generateForAll,
                            style: const TextStyle(
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
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
          ),
          Text(
            value.localizeDigits(context),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
