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

/// Provides all per-tab AppBars used by the mobile layout.
///
/// Each static method returns the exact same AppBar that was previously
/// defined inline inside HomeLayout.
class HomeAppBars {
  HomeAppBars._();

  /// Returns the correct AppBar for the given tab [index].
  static PreferredSizeWidget forIndex(
    int index,
    BuildContext context,
    AppCubit cubit,
  ) {
    switch (index) {
      case 0:
        return home(context, cubit);
      case 1:
        return leave(context);
      case 2:
        return empty();
      case 3:
        return payroll(context, cubit);
      case 4:
        return settings(context);
      default:
        return home(context, cubit);
    }
  }

  // ── Home ────────────────────────────────────────────────────────────────────

  static PreferredSizeWidget home(BuildContext context, AppCubit cubit) {
    return AppBar(
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 15.0),
        child: GestureDetector(
          onTap: () {
            navigateTo(context, const ProfileDetailsScreen());
          },
          child: (cubit.userModel?.image != null &&
                  cubit.userModel!.image!.isNotEmpty)
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(cubit.userModel!.image!),
                )
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary,
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      (cubit.userModel?.firstName ?? 'E')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back $hiEmoji",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${cubit.userModel?.firstName ?? ''} ${cubit.userModel?.lastName ?? ''}",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: BlocBuilder<NotificationCubit, NotificationStates>(
            builder: (notifContext, notifState) {
              final notifCubit = NotificationCubit.get(notifContext);
              return Stack(
                children: [
                  IconButton.outlined(
                    iconSize: 28,
                    icon: const Icon(IconBroken.Notification),
                    onPressed: () {
                      navigateTo(context, const NotificationsScreen());
                    },
                  ),
                  if (notifCubit.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
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
        ),
      ],
    );
  }

  // ── Leave ───────────────────────────────────────────────────────────────────

  static PreferredSizeWidget leave(BuildContext context) {
    return AppBar(
      title: Text(
        "All Leaves",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: IconButton(
            onPressed: () {
              navigateTo(context, const ApplyLeaveScreen());
            },
            icon: const Icon(
              IconBroken.Plus,
              color: AppColors.primary,
              size: 28,
            ),
            tooltip: "Apply Leave",
          ),
        ),
      ],
    );
  }

  // ── Empty (FAB placeholder index) ──────────────────────────────────────────

  static PreferredSizeWidget empty() {
    return AppBar(backgroundColor: Colors.white, elevation: 0);
  }

  // ── Payroll ─────────────────────────────────────────────────────────────────

  static PreferredSizeWidget payroll(BuildContext context, AppCubit cubit) {
    return AppBar(
      title: Text(
        "Payroll History",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (cubit.userModel?.userType == 'Company Owner')
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: IconButton(
              onPressed: () {
                navigateTo(context, PayrollConfigScreen());
              },
              icon: const Icon(
                IconBroken.Setting,
                color: AppColors.primary,
                size: 25,
              ),
              tooltip: "Payroll Settings",
            ),
          ),
      ],
    );
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  static PreferredSizeWidget settings(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          var profileCubit = ProfileCubit.get(context);
          var user = AppCubit.get(context).userModel;

          return AppBar(
            backgroundColor: AppColors.grey50,
            actions: [
              if (state is ProfileUpdateLoadingState)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else ...[
                // SHOW UPLOAD BUTTON IF NEW IMAGE PICKED
                if (profileCubit.profileImage != null)
                  TextButton(
                    onPressed: () {
                      profileCubit.uploadProfileImage(uId: user!.uId!);
                    },
                    child: const Text(
                      "Upload Photo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                // SHOW REMOVE BUTTON IF NETWORK IMAGE EXISTS
                else if (user?.image != null && user!.image!.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      profileCubit.removeProfileImage(uId: user.uId!);
                    },
                    child: const Text(
                      "Remove Photo",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
              const SizedBox(width: 10),
            ],
          );
        },
      ),
    );
  }
}
