import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';

class LeaveActivityCard extends StatelessWidget {
  final LeaveActivityModel item;
  final void Function(LeaveActivityState state)? approveRejectTap;
  final VoidCallback? onCancel;

  const LeaveActivityCard({
    super.key,
    required this.item,
    this.approveRejectTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    var user = AppCubit.get(context).userModel;

    // Use totalDays from model, fallback to calculation
    int days = item.totalDays ?? 0;
    if (days == 0 && item.fromdate != null && item.todate != null) {
      days = item.todate!.difference(item.fromdate!).inDays + 1;
    }

    final bool isAdmin = user?.uId == item.approvalTo?.uId;
    final bool isOwner = user?.uId == item.userID;
    final bool isPending = item.leaveStatus == LeaveActivityState.pending;
    final bool isApproved = item.leaveStatus == LeaveActivityState.approved;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Date range + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formatDate(item.fromdate)} - ${formatDate(item.todate)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: item.leaveStatus?.getColor.withOpacity(.1) ??
                      Colors.grey.withOpacity(.1),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  item.leaveStatus?.getName ?? "-",
                  style: TextStyle(
                    color: item.leaveStatus?.getColor ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.grey100, height: 1),
          const SizedBox(height: 12),

          // Info Row: Days, Employee Name, Approval
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleAndSubTitle("Total Days", "$days Days"),
              _buildTitleAndSubTitle(
                "Employee",
                item.user?.fullName ?? "-",
              ),
              _buildTitleAndSubTitle(
                "Approval",
                item.approvalTo?.fullName ?? "-",
              ),
            ],
          ),

          // Leave Reason
          if (item.leaveReason != null && item.leaveReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.grey100, height: 1),
            const SizedBox(height: 12),
            _buildTitleAndSubTitle("Reason", item.leaveReason!),
          ],

          // Approve/Reject Buttons (Admin only, pending only)
          if (isAdmin && isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => approveRejectTap
                        ?.call(LeaveActivityState.approved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green500,
                      side: const BorderSide(color: AppColors.green500),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => approveRejectTap
                        ?.call(LeaveActivityState.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],

          // Cancel Button (Employee only, pending or approved)
          if (isOwner && (isPending || isApproved)) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelConfirmation(context, isApproved),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text("Cancel Leave"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange500,
                  side: const BorderSide(color: AppColors.orange500),
                ),
              ),
            ),
          ],

          // Show rejection reason if it exists
          if (item.leaveStatus == LeaveActivityState.rejected &&
              item.rejectedReason != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.grey100, height: 1),
            const SizedBox(height: 12),
            _buildTitleAndSubTitle(
              "Rejected Reason",
              item.rejectedReason!,
            ),
          ]
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, bool isApproved) {
    final message = isApproved
        ? "Are you sure you want to cancel this approved leave? Your vacation days will be restored."
        : "Are you sure you want to cancel this pending leave request?";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Leave"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
            ),
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndSubTitle(String label, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(subTitle,
            style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '.';
    return DateFormat('dd MMM yyyy').format(date);
  }
}