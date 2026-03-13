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
        if (state is CancelLeaveSuccessState) {
          Fluttertoast.showToast(msg: "Leave Cancelled — Days Restored");
        }
        if (state is GetLeavesErrorState) {
          Fluttertoast.showToast(msg: state.error);
        }
        if (state is CancelLeaveErrorState) {
          Fluttertoast.showToast(msg: state.error);
        }
      },
      builder: (context, state) {
        var cubit = LeaveCubit.get(context);

        return Column(
          children: [
            // Header Row
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      navigateTo(
                        context,
                        const ApplyLeaveScreen(),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.blue600, size: 28),
                    tooltip: "Apply Leave",
                  ),
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
                    onPressed: () {
                      cubit.getAllLeaves(
                        uId: user?.uId,
                        companyId: user?.companyId,
                      );
                      cubit.loadVacationBalance(userId: user!.uId!);
                    },
                    icon:
                    const Icon(Icons.refresh, color: AppColors.blue600),
                  ),
                ],
              ),
            ),

            // Vacation Balance + Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Remaining Vacation Days
                  _buildStatItem(
                    context,
                    "Balance",
                    cubit.remainingVacationDays,
                    icon: Icons.beach_access_outlined,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 8),
                  _buildStatItem(
                    context,
                    "Approved",
                    cubit.approvedCount,
                  ),
                  const SizedBox(width: 8),
                  _buildStatItem(
                    context,
                    "Pending",
                    cubit.pendingCount,
                  ),
                  const SizedBox(width: 8),
                  _buildStatItem(
                    context,
                    "Rejected",
                    cubit.rejectedCount,
                    isWarning: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Selection
            _buildTabs(context, cubit, user?.uId),

            const SizedBox(height: 10),

            // Leave List
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
                        if (status == LeaveActivityState.rejected) {
                          _showRejectDialog(
                            context,
                            cubit,
                            cubit.filteredLeaves[index].id!,
                            user!.uId!,
                            user.companyId!,
                            '${user.firstName} ${user.lastName}',
                          );
                        } else {
                          cubit.updateLeaveStatus(
                            leaveId:
                            cubit.filteredLeaves[index].id!,
                            status: status,
                            uId: user!.uId!,
                            companyId: user.companyId!,
                            adminName:
                            '${user.firstName} ${user.lastName}',
                          );
                        }
                      },
                      onCancel: () {
                        cubit.cancelLeave(
                          leaveId:
                          cubit.filteredLeaves[index].id!,
                          uId: user!.uId!,
                          companyId: user.companyId!,
                          employeeName:
                          '${user.firstName} ${user.lastName}',
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

  void _showRejectDialog(
      BuildContext context,
      LeaveCubit cubit,
      String leaveId,
      String uId,
      String companyId,
      String adminName,
      ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Leave"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter reason for rejection (optional)",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.updateLeaveStatus(
                leaveId: leaveId,
                status: LeaveActivityState.rejected,
                rejectReason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : null,
                uId: uId,
                companyId: companyId,
                adminName: adminName,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child:
            const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String label,
      int? count, {
        bool isWarning = false,
        bool isPrimary = false,
        IconData? icon,
      }) {
    final Color baseColor = isPrimary
        ? AppColors.blue600
        : isWarning
        ? Colors.orange
        : AppColors.blue600;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? Border.all(color: baseColor.withOpacity(0.3))
              : null,
        ),
        child: Column(
          children: [
            if (icon != null)
              Icon(icon, color: baseColor, size: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              "${count ?? '-'}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: baseColor,
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
          bool isSelected =
              cubit.selectedTab.toLowerCase() == e.toLowerCase();
          return Expanded(
            child: InkWell(
              onTap: () => cubit.emitTabChange(e.toLowerCase(), uId!),
              child: Container(
                height: 38,
                margin: const EdgeInsets.symmetric(horizontal: 3),
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
                      fontSize: 12,
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
