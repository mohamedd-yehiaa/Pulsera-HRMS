import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/components/leave_activity_card.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';

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
        if (state is LeaveStreamErrorState) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Spacer(),
                  // My/Other Switch for Managers/Owners
                  if (user?.userType == 'Company Owner' ||
                      user?.roleType == 'Hr admin')
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
                          activeThumbColor: AppColors.blue600,
                          onChanged: (value) =>
                              cubit.changeMyData(value, user!.uId!),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // STATS GRID
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Top Row
                  Row(
                    children: [
                      _buildStatCard(
                        label: "Leave\nBalance",
                        value: "${cubit.remainingVacationDays ?? '-'}",
                        color: AppColors.blue500,
                        bgColor: AppColors.blue500.withAlpha(20),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        label: "Leave\nApproved",
                        value: "${cubit.approvedCount}",
                        color: AppColors.green500,
                        bgColor: AppColors.green500.withAlpha(20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bottom Row
                  Row(
                    children: [
                      _buildStatCard(
                        label: "Leave\nPending",
                        value: "${cubit.pendingCount}",
                        color: AppColors.green400,
                        bgColor: AppColors.green400.withAlpha(20),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        label: "Leave\nRejected",
                        value: "${cubit.rejectedCount}",
                        color: AppColors.red500,
                        bgColor: AppColors.red500.withAlpha(20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // -----------------------------------------------------------------

            const SizedBox(height: 24),

            // Tab Selection
            _buildTabs(context, cubit, user?.uId),

            const SizedBox(height: 10),

            // Leave List — wrapped in RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blue600,
                onRefresh: () => cubit.refreshLeaves(),
                child: ConditionalBuilder(
                  condition: state is! GetLeavesLoadingState,
                  builder: (context) => cubit.filteredLeaves.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text("No Data found.")),
                          ],
                        )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                              leaveId: cubit.filteredLeaves[index].id!,
                              status: status,
                              uId: user!.uId!,
                              companyId: user.companyId!,
                              adminName: '${user.firstName} ${user.lastName}',
                            );
                          }
                        },
                        onCancel: () {
                          cubit.cancelLeave(
                            leaveId: cubit.filteredLeaves[index].id!,
                            uId: user!.uId!,
                            companyId: user.companyId!,
                            employeeName: '${user.firstName} ${user.lastName}',
                          );
                        },
                      );
                    },
                  ),
                  fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
                ),
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
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // UPDATED STAT CARD WIDGET
  // -----------------------------------------------------------------
  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2, // Tighter line spacing for the title
              ),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // -----------------------------------------------------------------

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
                height: 50,
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
                      letterSpacing: 0.5,
                      fontFamily: 'Jannah',
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