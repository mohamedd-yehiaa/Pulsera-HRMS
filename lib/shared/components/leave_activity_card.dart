import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/app_extension.dart';
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
            color: Colors.black.withValues(alpha: 0.05),
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
                    Text(
                      S.of(context).date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formatDate(item.fromdate, context)} - ${formatDate(item.todate, context)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      item.leaveStatus?.getColor.withValues(alpha: 0.1) ??
                      Colors.grey.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  // Replaced .getName with .getLocalizedName(context)
                  item.leaveStatus?.getLocalizedName(context) ?? "-",
                  style: TextStyle(
                    color: item.leaveStatus?.getColor ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.grey100, height: 1),
          const SizedBox(height: 12),

          // Info Row: Days, Employee Name, Approval
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: _buildTitleAndSubTitle(
                  S.of(context).totalDaysLabel,
                  S.of(context).nDays(days),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTitleAndSubTitle(
                  S.of(context).employee,
                  item.user?.fullName ?? "-",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTitleAndSubTitle(
                  S.of(context).approval,
                  item.approvalTo?.fullName ?? "-",
                ),
              ),
            ],
          ),

          // Leave Reason
          if (item.leaveReason != null && item.leaveReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.grey100, height: 1),
            const SizedBox(height: 12),
            _buildTitleAndSubTitle(S.of(context).reason, item.leaveReason!),
          ],

          // Approve/Reject Buttons (Admin only, pending only)
          if (isAdmin && isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        approveRejectTap?.call(LeaveActivityState.approved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green500,
                      side: const BorderSide(color: AppColors.green500),
                    ),
                    child: Text(S.of(context).approve),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        approveRejectTap?.call(LeaveActivityState.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: Text(S.of(context).reject),
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
                label: Text(S.of(context).cancelLeave),
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
              S.of(context).rejectedReason,
              item.rejectedReason!,
              maxLines: null,
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, bool isApproved) {
    final message = isApproved
        ? S.of(context).cancelApprovedLeaveMessage
        : S.of(context).cancelPendingLeaveMessage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).cancelLeave),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).no),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
            ),
            child: Text(
              S.of(context).yesCancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndSubTitle(
    String label,
    String subTitle, {
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          subTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  String formatDate(DateTime? date, BuildContext context) {
    if (date == null) return '-';

    // 1. Grab the locale
    final locale = Localizations.localeOf(context).toString();

    // 2. Format with locale (so 'Jun' becomes 'يونيو') and localize the digits
    return DateFormat(
      'dd MMM yyyy',
      locale,
    ).format(date).localizeDigits(context);
  }
}
