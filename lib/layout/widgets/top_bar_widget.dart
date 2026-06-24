import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/modules/leave/apply_leave_screen.dart';
import 'package:pulsera/modules/notification/notifications_screen.dart';
import 'package:pulsera/modules/payroll/payroll_config_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/constants.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

/// Persistent top bar shown on tablet and desktop layouts.
///
/// Replaces per-screen AppBars with a unified bar that shows:
/// - Page title (derived from current tab)
/// - Welcome text (Home tab only)
/// - Notification badge (Home tab only)
/// - Context-specific actions (e.g. payroll config, leave apply, profile upload)
class TopBarWidget extends StatelessWidget {
  final int currentIndex;
  final AppCubit cubit;
  late final currentUser = cubit.userModel;
  late final isManager = currentUser?.userType == "Company Owner";

  TopBarWidget({super.key, required this.currentIndex, required this.cubit});

  String _pageTitle(BuildContext context) {
    switch (currentIndex) {
      case 0:
        return S.of(context).navHome;
      case 1:
        return S.of(context).allLeaves;
      case 2:
        return isManager ? S.of(context).myTeam : S.of(context).teamInfo;
      case 3:
        return S.of(context).payrollHistory;
      case 4:
        return S.of(context).navProfile;
      default:
        return S.of(context).navHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Page title ──
          Text(
            _pageTitle(context),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          // ── Context actions ──
          ..._buildContextActions(context),

          // ── HOME SCREEN ONLY ITEMS ──
          if (currentIndex == 0) ...[
            const SizedBox(width: 8),

            // ── Welcome Text ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns both texts to the right
              children: [
                Text(
                  "${S.of(context).welcomeBack} $hiEmoji",
                  style: const TextStyle(
                    fontSize: 14,
                    color:
                        AppColors.textPrimary, // Primary color for welcome text
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ), // Adds a tiny bit of breathing room between the lines
                Text(
                  "${cubit.userModel?.firstName ?? ''} ${cubit.userModel?.lastName ?? ''}",
                  style: const TextStyle(
                    fontSize: 12, // Smaller font size for username
                    color:
                        AppColors.textSecondary, // Secondary color for username
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // ── Notification bell (Moved to the far right) ──
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
          ],
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
            tooltip: S.of(context).applyLeave,
          ),
        ];
      case 2: // Team Tab: Add the Refresh Button here
        return [
          IconButton(
            onPressed: () {
              final appCubit = AppCubit.get(context);
              final user = appCubit.userModel;
              if (user == null) return;

              final teamCubit = TeamCubit.get(context);

              if (user.userType == 'Company Owner') {
                teamCubit.loadFullTeam(managerId: user.uId ?? '');
              } else {
                teamCubit.loadMyManager(user.managerId);
                teamCubit.loadFullTeam(managerId: user.managerId ?? '');
              }
            },
            icon: const Icon(Icons.refresh, color: AppColors.primary),
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
              tooltip: S.of(context).payrollSettings,
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
                  child: Text(
                    S.of(context).uploadPhoto,
                    style: const TextStyle(
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
                  child: Text(
                    S.of(context).removePhoto,
                    style: const TextStyle(
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
}
