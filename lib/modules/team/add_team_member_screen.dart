import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/app_extension.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class AddTeamMemberScreen extends StatelessWidget {
  AddTeamMemberScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamCubit, TeamStates>(
      listener: (context, state) {
        if (state is TeamMemberAddedState) Navigator.pop(context, true);
        if (state is TeamUserValidationErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = TeamCubit.get(context);
        var appCubit = AppCubit.get(context);
        bool isLoading = state is TeamLoadingState;

        return Scaffold(
          appBar: AppBar(
            leading: backButton(context),
            title: Text(
              S.of(context).addTeamMember,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DefaultFormField(
                    controller: cubit.userIdController,
                    type: TextInputType.text,
                    label: Text(S.of(context).employeeUserId),
                    prefix: IconBroken.User,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => cubit.validateEmployee(
                        userId: cubit.userIdController.text,
                        currentManagerId: appCubit.userModel!.uId!,
                      ),
                      child: Text(
                        isLoading
                            ? S.of(context).validating
                            : S.of(context).validateButton,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (cubit.validatedUser != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green400.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.green400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.green400,
                            child: Text(
                              (cubit.validatedUser?.firstName ?? 'E')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${cubit.validatedUser?.firstName ?? ''} ${cubit.validatedUser?.lastName ?? ''}",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cubit.validatedUser?.email ?? '',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.grey500),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.green400,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contract Details Section
                    Text(
                      S.of(context).contractDetails,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).contractDetailsDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: cubit.selectedRole,
                      decoration: InputDecoration(
                        labelText: S.of(context).roleType,
                        prefixIcon: Icon(
                          IconBroken.Shield_Done,
                          color: AppColors.blue500,
                        ),
                        fillColor: AppColors.grey100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge!
                            .copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Employee',
                          child: Text(S.of(context).employeeRoleLabel),
                        ),
                        DropdownMenuItem(
                          value: 'Hr admin',
                          child: Text(S.of(context).hrAdminRoleLabel),
                        ),
                      ],
                      onChanged: (val) => cubit.selectedRole = val!,
                    ),
                    const SizedBox(height: 15),
                    DefaultFormField(
                      controller: cubit.salaryController,
                      type: TextInputType.numberWithOptions(decimal: true),
                      label: Text(S.of(context).monthlySalary),
                      prefix: IconBroken.Wallet,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9٠-٩]+\.?[0-9٠-٩]{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return S.of(context).pleaseEnterMonthlySalary;
                        }
                        final salary = double.tryParse(value.toEnglishDigits());
                        if (salary == null || salary <= 0) {
                          return S.of(context).pleaseEnterValidSalary;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DefaultFormField(
                      controller: cubit.vacationDaysController,
                      type: TextInputType.number,
                      label: Text(S.of(context).monthlyVacationDays),
                      prefix: IconBroken.Calendar,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return S.of(context).pleaseEnterVacationDays;
                        }
                        final days = int.tryParse(value.toEnglishDigits());
                        if (days == null || days < 0) {
                          return S.of(context).pleaseEnterValidDays;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            //  Clean the text fields directly before submission so the Cubit's backend request model parses correctly
                            cubit.salaryController.text = cubit
                                .salaryController
                                .text
                                .toEnglishDigits();
                            cubit.vacationDaysController.text = cubit
                                .vacationDaysController
                                .text
                                .toEnglishDigits();
                            cubit.addEmployeeToTeam(
                              managerId: appCubit.userModel!.uId!,
                              companyId: appCubit.userModel!.companyId!,
                              roleType: cubit.selectedRole,
                            );
                          }
                        },
                        child: Text(S.of(context).addToTeam),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
