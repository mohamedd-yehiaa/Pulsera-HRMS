import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/payroll_model.dart';
import 'package:pulsera/modules/payroll/generate_payroll_screen.dart';
import 'package:pulsera/modules/payroll/payroll_config_screen.dart';
import 'package:pulsera/modules/payroll/payslip_detail_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/styles/theme.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayrolls();
    });
  }

  void _loadPayrolls() {
    final appCubit = AppCubit.get(context);
    final payrollCubit = PayrollCubit.get(context);
    final user = appCubit.userModel;

    if (user == null) return;

    final monthStr = DateFormat('yyyy-MM').format(payrollCubit.selectedMonth);

    if (PayrollCubit.isPayrollAuthorized(user.userType)) {
      // Admin / HR Admin → load company payrolls for the selected month
      if (user.companyId != null) {
        payrollCubit.loadPayrollsForCompany(user.companyId!, monthStr);
      }
    } else {
      // Employee → load own payrolls
      if (user.uId != null) {
        payrollCubit.loadPayrollsForEmployee(user.uId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppCubit.get(context).userModel;
    final isAuthorized = PayrollCubit.isPayrollAuthorized(user?.userType);

    return BlocConsumer<PayrollCubit, PayrollStates>(
      listener: (context, state) {
        if (state is PayrollErrorState) {
          Fluttertoast.showToast(msg: state.error);
        }
        if (state is PayrollGeneratedSuccessState) {
          Fluttertoast.showToast(msg: 'Payroll generated successfully!');
          _loadPayrolls();
        }
      },
      builder: (context, state) {
        final cubit = PayrollCubit.get(context);

        return SafeArea(
          child: Column(
            children: [
              // --- Month Selector (Admin / HR Admin) ---
              if (isAuthorized) _buildMonthSelector(context, cubit),

              // --- Action Buttons (Admin / HR Admin) ---
              if (isAuthorized)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(

                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(IconBroken.Plus, size: 20),
                          label: const Text(
                            'Generate',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            navigateTo(
                                context, const GeneratePayrollScreen());
                          },
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(IconBroken.Setting, size: 20),
                          label: const Text('Rules'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: () {
                            navigateTo(
                                context, const PayrollConfigScreen());
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // --- Payroll list ---
              Expanded(
                child: state is PayrollLoadingState ||
                    state is PayrollGeneratingState
                    ? const Center(child: CircularProgressIndicator())
                    : cubit.payrolls.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cubit.payrolls.length,
                  itemBuilder: (context, index) {
                    return _buildPayrollCard(
                      context,
                      cubit.payrolls[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Month Selector
  // ---------------------------------------------------------------------------
  Widget _buildMonthSelector(BuildContext context, PayrollCubit cubit) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(IconBroken.Arrow___Left_2),
            onPressed: () {
              final newMonth = DateTime(
                cubit.selectedMonth.year,
                cubit.selectedMonth.month - 1,
              );
              cubit.changeMonth(newMonth);
              _loadPayrolls();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM yyyy').format(cubit.selectedMonth),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(IconBroken.Arrow___Right_2),
            onPressed: () {
              final newMonth = DateTime(
                cubit.selectedMonth.year,
                cubit.selectedMonth.month + 1,
              );
              cubit.changeMonth(newMonth);
              _loadPayrolls();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconBroken.Wallet, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'No payroll records found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate payroll to see records here',
            style: TextStyle(fontSize: 13, color: AppColors.grey300),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payroll Card
  // ---------------------------------------------------------------------------
  Widget _buildPayrollCard(BuildContext context, PayrollModel payroll) {
    final isFormer = payroll.employeeStatus == 'Former Employee';

    return GestureDetector(
      onTap: () {
        PayrollCubit.get(context).selectPayroll(payroll);
        navigateTo(context, const PayslipDetailScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: kBoxDecoration,
        child: Row(

          children: [
            // --- Avatar / Icon ---
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isFormer
                    ? AppColors.orange500.withAlpha(30)
                    : AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconBroken.Wallet,
                color:
                isFormer ? AppColors.orange500 : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),

            // --- Info ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          payroll.employeeName ?? 'Employee',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isFormer) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.orange500.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Former',
                            style: TextStyle(
                              color: AppColors.orange500,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payroll.month ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),

            // --- Final Salary ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${payroll.finalSalary?.toStringAsFixed(2) ?? '0.00'}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  IconBroken.Arrow___Right_2,
                  size: 16,
                  color: AppColors.grey300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
