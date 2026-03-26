import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    _absenceMultiplierController.text = config.absenceMultiplier.toString();
    _lateGraceController.text = config.lateGracePeriodMinutes.toString();
    _lateDeductionValueController.text = config.lateDeductionValue.toString();
    _overtimeMinController.text = config.overtimeMinMinutes.toString();
    _overtimeBonusController.text = config.overtimeBonusPercentage.toString();
    _earlyLeaveDeductionValueController.text =
        config.earlyLeaveDeductionValue.toString();
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
      absenceMultiplier:
          double.tryParse(_absenceMultiplierController.text) ?? 1.0,
      lateGracePeriodMinutes:
          int.tryParse(_lateGraceController.text) ?? 15,
      lateDeductionMode: _lateDeductionMode,
      lateDeductionValue:
          double.tryParse(_lateDeductionValueController.text) ?? 0.0,
      overtimeMinMinutes:
          int.tryParse(_overtimeMinController.text) ?? 30,
      overtimeBonusPercentage:
          double.tryParse(_overtimeBonusController.text) ?? 0.0,
      earlyLeaveDeductionMode: _earlyLeaveDeductionMode,
      earlyLeaveDeductionValue:
          double.tryParse(_earlyLeaveDeductionValueController.text) ?? 0.0,
      missingCheckoutPolicy: _missingCheckoutPolicy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Payroll Configuration',
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
      body: BlocConsumer<PayrollConfigCubit, PayrollConfigStates>(
        listener: (context, state) {
          if (state is PayrollConfigLoadedState) {
            _populateFields();
          }
          if (state is PayrollConfigSavedState) {
            Fluttertoast.showToast(msg: 'Configuration saved successfully!');
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
                            'Configure payroll deduction and bonus rules for your company. These rules apply to all employees.',
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

                  // ===========================================================
                  // ABSENCE DEDUCTION
                  // ===========================================================
                  _sectionTitle(context, 'Absence Deduction'),
                  const SizedBox(height: 8),
                  Text(
                    'Multiplier applied to daily salary for each unapproved absence day.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _absenceMultiplierController,
                    type:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: const Text('Absence Multiplier (e.g. 1.0, 1.5, 2.0)'),
                    prefix: IconBroken.Close_Square,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final val = double.tryParse(value);
                      if (val == null || val < 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ===========================================================
                  // LATE ARRIVAL
                  // ===========================================================
                  _sectionTitle(context, 'Late Arrival Deduction'),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _lateGraceController,
                    type: TextInputType.number,
                    label: const Text('Grace Period (minutes)'),
                    prefix: IconBroken.Time_Circle,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _lateDeductionMode,
                    decoration: const InputDecoration(
                      labelText: 'Deduction Mode',
                      prefixIcon: Icon(IconBroken.Setting),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text('Percentage of Daily Salary'),
                      ),
                      DropdownMenuItem(
                        value: 'minutes',
                        child: Text('Per Minute Deduction'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _lateDeductionMode = val ?? 'percentage';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _lateDeductionValueController,
                    type:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: Text(_lateDeductionMode == 'percentage'
                        ? 'Deduction % per Late Day'
                        : 'Deduction Amount per Minute'),
                    prefix: IconBroken.Wallet,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ===========================================================
                  // EARLY LEAVE DEDUCTION
                  // ===========================================================
                  _sectionTitle(context, 'Early Leave Deduction'),
                  const SizedBox(height: 8),
                  Text(
                    'Deduction applied when employees leave before the scheduled end time.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _earlyLeaveDeductionMode,
                    decoration: const InputDecoration(
                      labelText: 'Early Leave Deduction Mode',
                      prefixIcon: Icon(IconBroken.Setting),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text('Percentage of Daily Salary'),
                      ),
                      DropdownMenuItem(
                        value: 'minutes',
                        child: Text('Per Minute Deduction'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _earlyLeaveDeductionMode = val ?? 'percentage';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _earlyLeaveDeductionValueController,
                    type:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: Text(_earlyLeaveDeductionMode == 'percentage'
                        ? 'Deduction % per Early Leave Day'
                        : 'Deduction Amount per Minute'),
                    prefix: IconBroken.Wallet,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ===========================================================
                  // OVERTIME BONUS
                  // ===========================================================
                  _sectionTitle(context, 'Overtime Bonus'),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _overtimeMinController,
                    type: TextInputType.number,
                    label: const Text('Minimum Overtime Minutes'),
                    prefix: IconBroken.Time_Circle,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DefaultFormField(
                    controller: _overtimeBonusController,
                    type:
                        const TextInputType.numberWithOptions(decimal: true),
                    label:
                        const Text('Bonus % of Daily Salary (per overtime day)'),
                    prefix: IconBroken.Star,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ===========================================================
                  // MISSING CHECKOUT POLICY
                  // ===========================================================
                  _sectionTitle(context, 'Missing Checkout Policy'),
                  const SizedBox(height: 8),
                  Text(
                    'How to handle days where an employee checked in but never checked out.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _missingCheckoutPolicy,
                    decoration: const InputDecoration(
                      labelText: 'Policy',
                      prefixIcon: Icon(IconBroken.Shield_Fail),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'half_day',
                        child: Text('Count as Half Day'),
                      ),
                      DropdownMenuItem(
                        value: 'absent',
                        child: Text('Count as Absent'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _missingCheckoutPolicy = val ?? 'half_day';
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Text(
                        'Save Configuration',
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
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
