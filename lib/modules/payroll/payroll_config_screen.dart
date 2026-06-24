import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/app_extension.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_config_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/components/components.dart';

class PayrollConfigScreen extends StatefulWidget {
  const PayrollConfigScreen({super.key});

  @override
  State<PayrollConfigScreen> createState() => _PayrollConfigScreenState();
}

class _PayrollConfigScreenState extends State<PayrollConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _absenceMultiplierController = TextEditingController();
  final _lateGraceController = TextEditingController();
  final _lateDeductionValueController = TextEditingController();
  final _overtimeMinController = TextEditingController();
  final _overtimeBonusController = TextEditingController();
  final _earlyLeaveDeductionValueController = TextEditingController();

  String _lateDeductionMode = 'percentage';
  String _earlyLeaveDeductionMode = 'percentage';
  String _missingCheckoutPolicy = 'half_day';

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

  @override
  void dispose() {
    _absenceMultiplierController.dispose();
    _lateGraceController.dispose();
    _lateDeductionValueController.dispose();
    _overtimeMinController.dispose();
    _overtimeBonusController.dispose();
    _earlyLeaveDeductionValueController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final config = PayrollConfigCubit.get(context).config;
    if (config == null) return;

    // Add .localizeDigits(context) to everything going into a controller
    _absenceMultiplierController.text = config.absenceMultiplier
        .toString()
        .localizeDigits(context);
    _lateGraceController.text = config.lateGracePeriodMinutes
        .toString()
        .localizeDigits(context);
    _lateDeductionValueController.text = config.lateDeductionValue
        .toString()
        .localizeDigits(context);
    _overtimeMinController.text = config.overtimeMinMinutes
        .toString()
        .localizeDigits(context);
    _overtimeBonusController.text = config.overtimeBonusPercentage
        .toString()
        .localizeDigits(context);
    _earlyLeaveDeductionValueController.text = config.earlyLeaveDeductionValue
        .toString()
        .localizeDigits(context);

    setState(() {
      _lateDeductionMode = config.lateDeductionMode;
      _earlyLeaveDeductionMode = config.earlyLeaveDeductionMode;
      _missingCheckoutPolicy = config.missingCheckoutPolicy;
    });
  }

  void _saveConfig() {
    if (!_formKey.currentState!.validate()) return;

    final companyId = AppCubit.get(context).userModel?.companyId;
    if (companyId == null) return;

    PayrollConfigCubit.get(context).saveConfig(
      companyId: companyId,

      // Add .toEnglishDigits() BEFORE you tryParse!
      absenceMultiplier:
          double.tryParse(
            _absenceMultiplierController.text.toEnglishDigits(),
          ) ??
          1.0,
      lateGracePeriodMinutes:
          int.tryParse(_lateGraceController.text.toEnglishDigits()) ?? 15,
      lateDeductionMode: _lateDeductionMode,
      lateDeductionValue:
          double.tryParse(
            _lateDeductionValueController.text.toEnglishDigits(),
          ) ??
          0.0,
      overtimeMinMinutes:
          int.tryParse(_overtimeMinController.text.toEnglishDigits()) ?? 30,
      overtimeBonusPercentage:
          double.tryParse(_overtimeBonusController.text.toEnglishDigits()) ??
          0.0,
      earlyLeaveDeductionMode: _earlyLeaveDeductionMode,
      earlyLeaveDeductionValue:
          double.tryParse(
            _earlyLeaveDeductionValueController.text.toEnglishDigits(),
          ) ??
          0.0,
      missingCheckoutPolicy: _missingCheckoutPolicy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          S.of(context).payrollConfig,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<PayrollConfigCubit, PayrollConfigStates>(
        listener: (context, state) {
          if (state is PayrollConfigLoadedState) {
            _populateFields();
          }
          if (state is PayrollConfigSavedState) {
            Fluttertoast.showToast(msg: S.of(context).configSavedSuccessfully);
            Navigator.pop(context);
          }
          if (state is PayrollConfigErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
        },
        builder: (context, state) {
          if (state is PayrollConfigLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
                      border: Border.all(
                        color: AppColors.primary.withAlpha(60),
                      ),
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
                            S.of(context).payrollConfigInfo,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===========================================================
                  // ABSENCE DEDUCTION
                  // ===========================================================
                  _sectionTitle(context, S.of(context).absenceDeductionSection),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).absenceMultiplierDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 18),
                  DefaultFormField(
                    controller: _absenceMultiplierController,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    label: Text(S.of(context).absenceMultiplierLabel),
                    prefix: IconBroken.Close_Square,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).required;
                      }
                      final val = double.tryParse(value);
                      if (val == null || val < 0)
                        return S.of(context).enterValidNumber;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // LATE ARRIVAL
                  // ===========================================================
                  _sectionTitle(context, S.of(context).lateArrivalDeduction),
                  const SizedBox(height: 8),
                  DefaultFormField(
                    controller: _lateGraceController,
                    type: TextInputType.number,
                    label: Text(S.of(context).gracePeriodMinutes),
                    prefix: IconBroken.Time_Circle,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return S.of(context).required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _lateDeductionMode,
                    decoration: InputDecoration(
                      labelText: S.of(context).deductionMode,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 10.0,
                      ),
                      prefixIcon: const Icon(
                        IconBroken.Setting,
                        color: AppColors.blue500,
                      ),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text(S.of(context).percentageOfDailySalary),
                      ),
                      DropdownMenuItem(
                        value: 'minutes',
                        child: Text(S.of(context).perMinuteDeduction),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _lateDeductionMode = val ?? 'percentage';
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DefaultFormField(
                    controller: _lateDeductionValueController,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    label: Text(
                      _lateDeductionMode == 'percentage'
                          ? S.of(context).deductionPercentPerLateDay
                          : S.of(context).deductionAmountPerMinute,
                    ),
                    prefix: IconBroken.Wallet,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return S.of(context).required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // EARLY LEAVE DEDUCTION
                  // ===========================================================
                  _sectionTitle(
                    context,
                    S.of(context).earlyLeaveDeductionSection,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).earlyLeaveDeductionDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _earlyLeaveDeductionMode,
                    decoration: InputDecoration(
                      labelText: S.of(context).earlyLeaveDeductionMode,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 10.0,
                      ),
                      prefixIcon: const Icon(
                        IconBroken.Setting,
                        color: AppColors.blue500,
                      ),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text(S.of(context).percentageOfDailySalary),
                      ),
                      DropdownMenuItem(
                        value: 'minutes',
                        child: Text(S.of(context).perMinuteDeduction),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _earlyLeaveDeductionMode = val ?? 'percentage';
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DefaultFormField(
                    controller: _earlyLeaveDeductionValueController,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    label: Text(
                      _earlyLeaveDeductionMode == 'percentage'
                          ? S.of(context).deductionPercentPerEarlyLeave
                          : S.of(context).deductionAmountPerMinute,
                    ),
                    prefix: IconBroken.Wallet,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return S.of(context).required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // OVERTIME BONUS
                  // ===========================================================
                  _sectionTitle(context, S.of(context).overtimeBonusSection),
                  const SizedBox(height: 8),
                  DefaultFormField(
                    controller: _overtimeMinController,
                    type: TextInputType.number,
                    label: Text(S.of(context).minimumOvertimeMinutes),
                    prefix: IconBroken.Time_Circle,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return S.of(context).required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DefaultFormField(
                    controller: _overtimeBonusController,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    label: Text(S.of(context).bonusPercentPerOvertimeDay),
                    prefix: IconBroken.Star,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return S.of(context).required;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // MISSING CHECKOUT POLICY
                  // ===========================================================
                  _sectionTitle(context, S.of(context).missingCheckoutPolicy),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).missingCheckoutDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _missingCheckoutPolicy,
                    decoration: InputDecoration(
                      labelText: S.of(context).policy,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 10.0,
                      ),
                      prefixIcon: const Icon(
                        IconBroken.Shield_Fail,
                        color: AppColors.blue500,
                      ),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'half_day',
                        child: Text(S.of(context).countAsHalfDay),
                      ),
                      DropdownMenuItem(
                        value: 'absent',
                        child: Text(S.of(context).countAsAbsent),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _missingCheckoutPolicy = val ?? 'half_day';
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Text(
                        S.of(context).saveConfiguration,
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
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
