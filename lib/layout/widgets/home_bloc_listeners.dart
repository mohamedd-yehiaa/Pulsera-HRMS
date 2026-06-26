import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/modules/kiosk/kiosk_qr_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/services/push_notification_service.dart';
import 'package:pulsera/modules/notification/notifications_screen.dart';

/// Wraps its [child] in the MultiBlocListener that orchestrates all
/// business-logic reactions needed at the layout level.
///
/// This keeps the HomeLayout file free of initialization / guard logic.
class HomeBlocListeners extends StatelessWidget {
  final Widget child;

  const HomeBlocListeners({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ── Register: refresh user/company after creation ──
        BlocListener<RegisterCubit, RegisterStates>(
          listener: (context, state) {
            if (state is CreateUserSuccessState) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
            }
            // After company creation, refresh user data so companyId is picked up.
            if (state is CreateCompanySuccessState) {
              AppCubit.get(context).getUserData();
            }
          },
        ),

        // ── Auth: refresh user/company after login ──
        BlocListener<AuthCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
            }
          },
        ),

        // ── App: kiosk guard + stream initialization ──
        BlocListener<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is GetUserSuccessState) {
              final user = AppCubit.get(context).userModel;

              // ── Navigation Guard: KIOSK users must NOT access HomeLayout ──
              if (user?.userType == 'KIOSK') {
                CacheHelper.saveData(key: 'isKiosk', value: true);
                navigateAndFinish(
                  context,
                  KioskQrScreen(companyId: user!.companyId ?? ''),
                );
                return;
              }

              if (user != null && user.companyId != null && user.uId != null) {
                // Start (or restart) the attendance stream for today.
                AttendanceCubit.get(context).init(user.uId!);
                // Start the notification stream.
                NotificationCubit.get(context).init(user.uId!);
                // Start the push notification service (FCM).
                PushNotificationService.instance.initialize(
                  user.uId!,
                  onNotificationTap: () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    }
                  },
                );
                // Start the leave requests stream.
                final isAdmin =
                    user.userType == 'Company Owner' ||
                    user.roleType == 'Hr admin';
                LeaveCubit.get(
                  context,
                ).init(user.uId!, user.companyId!, isAdmin: isAdmin);
                // Also fetch company data if not already loaded.
                if (AppCubit.get(context).companyModel == null) {
                  AppCubit.get(context).getCompanyData();
                }

                // Load monthly summary for total days counter
                final company = AppCubit.get(context).companyModel;
                if (company != null) {
                  final yearMonth = DateFormat(
                    'yyyy-MM',
                  ).format(DateTime.now());
                  AttendanceCubit.get(context).loadMonthlySummary(
                    userId: user.uId!,
                    yearMonth: yearMonth,
                    companyWorkingDays: company.workingDays ?? [],
                    companyStartTime: company.startTime ?? '09:00',
                    lateGracePeriodMinutes: company.gracePeriodMinutes ?? 15,
                  );
                }
              }
            }

            // Also load monthly summary once company data arrives
            if (state is GetCompanySuccessState) {
              final user = AppCubit.get(context).userModel;
              final company = AppCubit.get(context).companyModel;
              if (user != null && user.uId != null && company != null) {
                final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
                AttendanceCubit.get(context).loadMonthlySummary(
                  userId: user.uId!,
                  yearMonth: yearMonth,
                  companyWorkingDays: company.workingDays ?? [],
                  companyStartTime: company.startTime ?? '09:00',
                  lateGracePeriodMinutes: company.gracePeriodMinutes ?? 15,
                );
              }
            }
          },
        ),

        // ── Profile: refresh user on image upload / removal ──
        BlocListener<ProfileCubit, ProfileStates>(
          listener: (context, state) {
            // If image is removed OR uploaded successfully
            if (state is ProfileRemoveImageSuccessState ||
                state is ProfileUpdateSuccessState) {
              AppCubit.get(context).getUserData();
            }

            if (state is ProfileRemoveImageErrorState) {
              Fluttertoast.showToast(
                msg: state.error,
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.black87,
              );
            }
          },
        ),
      ],
      child: child,
    );
  }
}
