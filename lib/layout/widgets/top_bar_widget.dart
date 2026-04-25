import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/modules/leave/apply_leave_screen.dart';
import 'package:pulsera/modules/notification/notifications_screen.dart';
import 'package:pulsera/modules/payroll/payroll_config_screen.dart';
import 'package:pulsera/modules/settings/profile_details_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/constants.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

/// Persistent top bar shown on tablet and desktop layouts.
///
/// Replaces per-screen AppBars with a unified bar that shows:
/// - Page title (derived from current tab)
/// - Welcome text + user avatar
/// - Notification badge
/// - Context-specific actions (e.g. payroll config, leave apply, profile upload)
class TopBarWidget extends StatelessWidget {
  final int currentIndex;
  final AppCubit cubit;

  const TopBarWidget({
    super.key,
    required this.currentIndex,
    required this.cubit,
  });

  String get _pageTitle {
    switch (currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'All Leaves';
      case 2:
        return 'Team';
      case 3:
        return 'Payroll History';
      case 4:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Page title ──
          Text(
            _pageTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const Spacer(),

          // ── Context actions ──
          ..._buildContextActions(context),

          const SizedBox(width: 8),

          // ── Notification bell ──
          BlocBuilder<NotificationCubit, NotificationStates>(
            builder: (notifContext, notifState) {
              final notifCubit = NotificationCubit.get(notifContext);
              return Stack(
                children: [
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(IconBroken.Notification),
                    onPressed: () {
                      navigateTo(context, const NotificationsScreen());
                    },
                  ),
                  if (notifCubit.unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${notifCubit.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(width: 8),

          // ── User avatar ──
          GestureDetector(
            onTap: () => navigateTo(context, const ProfileDetailsScreen()),
            child: Row(
              children: [
                Text(
                  "Welcome $hiEmoji ${cubit.userModel?.firstName ?? ''}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                _buildAvatar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Context-specific actions per tab ────────────────────────────────────────

  List<Widget> _buildContextActions(BuildContext context) {
    switch (currentIndex) {
      case 1: // Leave → Add leave button
        return [
          IconButton(
            onPressed: () => navigateTo(context, const ApplyLeaveScreen()),
            icon: const Icon(IconBroken.Plus, color: AppColors.primary),
            tooltip: 'Apply Leave',
          ),
        ];
      case 3: // Payroll → Config for Company Owner
        if (cubit.userModel?.userType == 'Company Owner') {
          return [
            IconButton(
              onPressed: () => navigateTo(context, PayrollConfigScreen()),
              icon: const Icon(
                IconBroken.Setting,
                color: AppColors.primary,
                size: 22,
              ),
              tooltip: 'Payroll Settings',
            ),
          ];
        }
        return [];
      case 4: // Settings → Profile image actions
        return [
          BlocBuilder<ProfileCubit, ProfileStates>(
            builder: (context, state) {
              final profileCubit = ProfileCubit.get(context);
              final user = cubit.userModel;

              if (state is ProfileUpdateLoadingState) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                );
              }

              if (profileCubit.profileImage != null) {
                return TextButton(
                  onPressed: () {
                    profileCubit.uploadProfileImage(uId: user!.uId!);
                  },
                  child: const Text(
                    'Save Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (user?.image != null && user!.image!.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    profileCubit.removeProfileImage(uId: user.uId!);
                  },
                  child: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ];
      default:
        return [];
    }
  }

  // ── User avatar ─────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    if (cubit.userModel?.image != null && cubit.userModel!.image!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(cubit.userModel!.image!),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        (cubit.userModel?.firstName ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
