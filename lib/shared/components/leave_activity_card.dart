import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';

class LeaveActivityCard extends StatelessWidget {
  final LeaveActivityModel item;
  final void Function(LeaveActivityState state)? approveRejectTap;

  const LeaveActivityCard({
    super.key,
    required this.item,
    this.approveRejectTap,
  });

  @override
  Widget build(BuildContext context) {
    var user = AppCubit.get(context).userModel;

    // Calculate duration using your model's DateTime fields
    int days = 0;
    if (item.fromdate != null && item.todate != null) {
      days = item.todate!.difference(item.fromdate!).inDays + 1;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${formatDate(item.fromdate)} - ${formatDate(item.todate)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              // Using your enum's getColor and getName
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: item.leaveStatus?.getColor.withOpacity(.1) ?? Colors.grey.withOpacity(.1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleAndSubTitle("Apply Days", "$days Days"),
              _buildTitleAndSubTitle("Approval", item.approvalTo?.fullName ?? "-"),
            ],
          ),

          // Role-based Action Buttons for Managers
          if (user?.uId == item.approvalTo?.uId && item.leaveStatus == LeaveActivityState.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => approveRejectTap?.call(LeaveActivityState.approved),
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
                    onPressed: () => approveRejectTap?.call(LeaveActivityState.rejected),
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

          // Show rejection reason if it exists
          if (item.leaveStatus == LeaveActivityState.rejected && item.rejectedReason != null) ...[
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

  Widget _buildTitleAndSubTitle(String label, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(subTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '.';
    return DateFormat('dd MMM yyyy').format(date);
  }
}