import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/leave_activity_card.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import '../../shared/cubit/apply_leave_cubit.dart';
import 'apply_leave_screen.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user and company data from AppCubit
    var user = AppCubit.get(context).userModel;

    return BlocConsumer<LeaveCubit, LeaveStates>(
      listener: (context, state) {
        if (state is UpdateLeaveSuccessState) {
          Fluttertoast.showToast(msg: "Leave Status Updated");
        }
        if (state is GetLeavesErrorState) {
          Fluttertoast.showToast(msg: state.error,);
        }
      },
      builder: (context, state) {
        var cubit = LeaveCubit.get(context);

        return Column(
          children: [
            // Custom Layout Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.blue600),
                      onPressed: () {
                        cubit.generateMockLeave(user!.uId!, user.companyId!);

                  }),
                  IconButton(
                    onPressed: () {
                      navigateTo(
                        context,
                        // We wrap it here so the ApplyLeavePageView has its own Cubit
                        BlocProvider(
                          create: (context) => ApplyLeaveCubit()..fetchAllAdminMembers(
                            companyId: AppCubit.get(context).userModel?.companyId,
                            uId: AppCubit.get(context).userModel?.uId,
                          ),
                          child: const ApplyLeaveScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: AppColors.blue600),
                  ),
                  // title(context, "All Leaves", IconBroken.Paper),
                  const Spacer(),
                  // My/Other Switch for Managers/Owners
                  if (user?.userType == 'Company Owner' ||
                      user?.userType == 'Manager')
                    Row(
                      children: [
                        Text(
                          cubit.myData ? "My" : "Other",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: cubit.myData,
                          activeColor: AppColors.blue600,
                          onChanged: (value) =>
                              cubit.changeMyData(value, user!.uId!),
                        ),
                      ],
                    ),
                  IconButton(
                    onPressed: () => cubit.getAllLeaves(
                      uId: user?.uId,
                      companyId: user?.companyId,
                    ),
                    icon: const Icon(Icons.refresh, color: AppColors.blue600),
                  ),
                ],
              ),
            ),

            // Statistics Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatItem(
                    context,
                    "Paid",
                    15,
                  ), // Replace with model balance
                  const SizedBox(width: 8),
                  _buildStatItem(
                    context,
                    "Casual",
                    10,
                  ), // Replace with model balance
                  const SizedBox(width: 8),
                  _buildStatItem(context, "WFH", 5, isWarning: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Selection using your LeaveActivityState.list
            _buildTabs(context, cubit, user?.uId),

            const SizedBox(height: 10),

            // Leave List with Conditional Loading
            Expanded(
              child: ConditionalBuilder(
                condition: state is! GetLeavesLoadingState,
                builder: (context) => cubit.filteredLeaves.isEmpty
                    ? const Center(child: Text("No Data found."))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: cubit.filteredLeaves.length,
                        itemBuilder: (context, index) {
                          return LeaveActivityCard(
                            item: cubit.filteredLeaves[index],
                            approveRejectTap: (status) {
                              // If Reject, you might want to show a dialog first
                              cubit.updateLeaveStatus(
                                leaveId: cubit.filteredLeaves[index].id!,
                                status: status,
                                uId: user!.uId!,
                                companyId: user.companyId!,
                              );
                            },
                          );
                        },
                      ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int? count, {
    bool isWarning = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWarning
              ? Colors.orange.withOpacity(0.1)
              : AppColors.blue600.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "${count ?? 0}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isWarning ? Colors.orange : AppColors.blue600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context, LeaveCubit cubit, String? uId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: LeaveActivityState.list.map((e) {
          bool isSelected = cubit.selectedTab.toLowerCase() == e.toLowerCase();
          return Expanded(
            child: InkWell(
              onTap: () => cubit.emitTabChange(e.toLowerCase(), uId!),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue600 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    e,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
