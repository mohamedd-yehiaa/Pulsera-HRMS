import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(IconBroken.Arrow___Left_2),
            ),
            title: Text(
              "Add Team Member",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
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
                    label: const Text('Employee UserID'),
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
                        isLoading ? "Validating..." : "Validate",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                      "Contract Details",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Define the employee's salary and vacation allowance.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: cubit.selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Role Type",
                        prefixIcon: Icon(IconBroken.Shield_Done),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Employee',
                          child: Text("Employee"),
                        ),
                        DropdownMenuItem(
                          value: 'Hr admin',
                          child: Text("HR Admin"),
                        ),
                      ],
                      onChanged: (val) => cubit.selectedRole = val!,
                    ),
                    const SizedBox(height: 15),
                    DefaultFormField(
                      controller: cubit.salaryController,
                      type: TextInputType.numberWithOptions(decimal: true),
                      label: const Text('Monthly Salary'),
                      prefix: IconBroken.Wallet,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the monthly salary';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null || salary <= 0) {
                          return 'Please enter a valid salary amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DefaultFormField(
                      controller: cubit.vacationDaysController,
                      type: TextInputType.number,
                      label: const Text('Monthly Vacation Days'),
                      prefix: IconBroken.Calendar,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter vacation days';
                        }
                        final days = int.tryParse(value);
                        if (days == null || days < 0) {
                          return 'Please enter a valid number of days';
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
                            cubit.addEmployeeToTeam(
                              managerId: appCubit.userModel!.uId!,
                              companyId: appCubit.userModel!.companyId!,
                              roleType: cubit.selectedRole,
                            );
                          }
                        },
                        child: const Text("Add to Team"),
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
