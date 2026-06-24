import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/notification_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          S.of(context).notifications,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          BlocBuilder<NotificationCubit, NotificationStates>(
            builder: (context, state) {
              var cubit = NotificationCubit.get(context);
              if (cubit.notifications.isEmpty) return const SizedBox.shrink();

              return Row(
                children: [
                  if (cubit.unreadCount > 0)
                    IconButton(
                      icon: const Icon(IconBroken.Tick_Square, color: AppColors.blue600),
                      tooltip: S.of(context).markAllAsRead,
                      onPressed: () => cubit.markAllRead(),
                    ),
                  IconButton(
                    icon: const Icon(IconBroken.Delete, color: Colors.red),
                    tooltip: S.of(context).clearAllNotifications,
                    onPressed: () => cubit.clearAll(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = NotificationCubit.get(context);
          var notifications = cubit.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    IconBroken.Notification,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).noNotifications,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification.isRead;

              IconData typeIcon;
              Color typeColor;
              switch (notification.type) {
                case 'leave_submitted':
                  typeIcon = IconBroken.Paper;
                  typeColor = AppColors.blue600;
                  break;
                case 'leave_approved':
                  typeIcon = Icons.check_circle_outline;
                  typeColor = AppColors.green500;
                  break;
                case 'leave_rejected':
                  typeIcon = Icons.cancel_outlined;
                  typeColor = AppColors.error;
                  break;
                case 'leave_cancelled':
                  typeIcon = Icons.undo;
                  typeColor = AppColors.orange500;
                  break;
                case 'attendance_checkin':
                  typeIcon = IconBroken.Login;
                  typeColor = AppColors.green500;
                  break;
                case 'attendance_checkout':
                  typeIcon = IconBroken.Logout;
                  typeColor = AppColors.blue600;
                  break;
                default:
                  typeIcon = IconBroken.Notification;
                  typeColor = AppColors.blue600;
              }

              return GestureDetector(
                onTap: () {
                  if (!isRead && notification.id != null) {
                    cubit.markRead(notification.id!);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Colors.white
                        : AppColors.blue600.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? AppColors.grey100
                          : AppColors.blue600.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.fromUserName ?? "",
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLocalizedMessage(context, notification),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            if (notification.createdAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(notification.createdAt!),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.blue600,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getLocalizedMessage(BuildContext context, NotificationModel notification) {
    if (notification.messageKey == null) {
      return notification.message ?? "";
    }

    final key = notification.messageKey;
    final params = notification.messageParams ?? {};
    final s = S.of(context);
    final name = params['name']?.toString() ?? '';

    switch (key) {
      case 'notifLeaveSubmitted':
        return s.notifLeaveSubmitted(name, params['days']?.toString() ?? '');
      case 'notifLeaveApproved':
        return s.notifLeaveApproved(name);
      case 'notifLeaveRejected':
        return s.notifLeaveRejected(name);
      case 'notifLeaveRejectedWithReason':
        return s.notifLeaveRejectedWithReason(name, params['reason']?.toString() ?? '');
      case 'notifLeaveCancelled':
        return s.notifLeaveCancelled(name, params['status']?.toString() ?? '');
      case 'notifCheckIn':
        return s.notifCheckIn(name);
      case 'notifCheckOut':
        return s.notifCheckOut(name);
      case 'notifBreakIn':
        return s.notifBreakIn(name);
      default:
        return notification.message ?? "";
    }
  }
}
