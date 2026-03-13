import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/apply_leave_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class ApplyLeaveScreen extends StatelessWidget {
  const ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = AppCubit.get(context).userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => ApplyLeaveCubit()
          ..fetchTeamData(userId: user?.uId),
        child: BlocConsumer<ApplyLeaveCubit, ApplyLeaveStates>(
          listener: (context, state) {
            if (state is ApplyLeaveSuccessState) {
              Fluttertoast.showToast(msg: "Leave Request Submitted");
              Navigator.pop(context);
            }
            if (state is ApplyLeaveErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
            if (state is ApplyLeaveValidationErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
            if (state is ApplyLeaveOverlapErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
          },
          builder: (context, state) {
            var cubit = ApplyLeaveCubit.get(context);

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        title(context, "Apply Leave", IconBroken.Edit),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Vacation Balance Card
                        if (cubit.remainingVacationDays != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.blue600,
                                  AppColors.blue700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  IconBroken.Calendar,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Remaining Vacation Days",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${cubit.remainingVacationDays} days",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Assigned To Card (auto-resolved team admin)
                        if (cubit.isTeamLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (cubit.teamAdmin != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.green500.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.green500.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconBroken.User,
                                  color: AppColors.green500,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Assigned To",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      cubit.teamAdmin?.fullName ?? "Team Admin",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.green500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "You are not assigned to any team. Contact your manager.",
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),

                        // Date Pickers
                        const SizedBox(height: 8),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () =>
                              cubit.setDate(context, isStart: true),
                          label: cubit.leaveStartDate == null
                              ? "Select start date"
                              : DateFormat('dd MMM yyyy')
                              .format(cubit.leaveStartDate!),
                          suffixIcon: const Icon(IconBroken.Calendar,
                              color: AppColors.blue600),
                        ),
                        const SizedBox(height: 16),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () =>
                              cubit.setDate(context, isStart: false),
                          label: cubit.leaveEndDate == null
                              ? "Select end date"
                              : DateFormat('dd MMM yyyy')
                              .format(cubit.leaveEndDate!),
                          suffixIcon: const Icon(IconBroken.Calendar,
                              color: AppColors.blue600),
                        ),

                        // Total Days Preview
                        if (cubit.totalDays != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.blue600.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(IconBroken.Time_Circle,
                                    color: AppColors.blue600, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Total: ${cubit.totalDays} day${cubit.totalDays! > 1 ? 's' : ''}",
                                  style: const TextStyle(
                                    color: AppColors.blue600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        DefaultFormField(
                          controller: cubit.leavereasonTC,
                          type: TextInputType.multiline,
                          label: const Text("Reason for leave"),
                          prefix: IconBroken.Document,
                          validator: (value) =>
                          value!.isEmpty ? "Required" : null,
                        ),

                        const SizedBox(height: 40),
                        ConditionalBuilder(
                          condition: state is! ApplyLeaveLoadingState,
                          builder: (context) => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: cubit.teamAdmin == null
                                  ? null
                                  : () => cubit.applyLeave(
                                uId: user?.uId,
                                companyId: user?.companyId,
                                userModel: user,
                              ),
                              child: const Text("Submit Request",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          fallback: (context) =>
                          const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}