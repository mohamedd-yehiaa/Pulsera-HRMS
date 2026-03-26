import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/modules/home/home_screen.dart';
import 'package:pulsera/modules/leave/apply_leave_screen.dart';
import 'package:pulsera/modules/leave/leave_screen.dart';
import 'package:pulsera/modules/notification/notifications_screen.dart';
import 'package:pulsera/modules/payroll/payroll_config_screen.dart';
import 'package:pulsera/modules/payroll/payroll_screen.dart';
import 'package:pulsera/modules/settings/settings_screen.dart';
import 'package:pulsera/modules/team/team_members_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/constants.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
        BlocListener<AuthCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
            }
          },
        ),
        // Auto-initialize attendance stream when user data loads with a company.
        BlocListener<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is GetUserSuccessState) {
              final user = AppCubit.get(context).userModel;
              if (user != null && user.companyId != null && user.uId != null) {
                // Start (or restart) the attendance stream for today.
                AttendanceCubit.get(context).init(user.uId!);
                // Start the notification stream.
                NotificationCubit.get(context).init(user.uId!);
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
              }
            }
          },
        ),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);

          final List<Widget> screens = [
            const HomeScreen(),
            const LeaveScreen(),
            const SizedBox(),
            const PayrollScreen(),
            const SettingsScreen(),
          ];

          final List<PreferredSizeWidget> appBars = [
            // Home AppBar
            AppBar(
              elevation: 0,
              leadingWidth: 70,
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0),
                child: GestureDetector(
                  onTap: () {},
                  child: cubit.userModel?.image != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            cubit.userModel!.image!,
                          ),
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
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              (cubit.userModel?.firstName ?? 'E')[0]
                                  .toUpperCase(),
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
            ),

            // Leave AppBar
            AppBar(
              title: Text(
                "All Leaves",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Context works perfectly here now
                          navigateTo(context, const ApplyLeaveScreen());
                        },
                        icon: const Icon(
                          IconBroken.Plus,
                          color: Colors.black,
                          size: 30,
                        ),
                        tooltip: "Apply Leave",
                      ),

                      IconButton(
                        onPressed: () {
                          // Context works perfectly here now
                          navigateTo(context, const ApplyLeaveScreen());
                        },
                        icon: const Icon(
                          IconBroken.Filter,
                          color: Colors.black,
                          size: 30,
                        ),
                        tooltip: "Apply Leave",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Empty AppBar for FAB space (keeps index aligned)
            AppBar(backgroundColor: Colors.white, elevation: 0),

            // Payroll AppBar
            AppBar(
              title: Text(
                "Payroll History",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          navigateTo(context, PayrollConfigScreen());
                        },
                        icon: const Icon(
                          IconBroken.Setting,
                          color: Colors.black,
                          size: 30,
                        ),
                        tooltip: "Payroll Settings",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Settings AppBar
            AppBar(
              title: Text(
                "Settings",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ];

          return ConditionalBuilder(
            condition: cubit.userModel != null,
            builder: (BuildContext context) {
              return Scaffold(
                // 3. Call the lists you defined above
                appBar: appBars[cubit.currentIndex],
                body: screens[cubit.currentIndex],

                floatingActionButton: SizedBox(
                  width: 60,
                  height: 60,
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    onPressed: () =>
                        navigateTo(context, const TeamMembersScreen()),
                    child: const Icon(IconBroken.User, color: AppColors.white),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 10.0,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.zero,
                  color: Colors.transparent,
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    currentIndex: cubit.currentIndex,
                    onTap: (index) {
                      if (index != 2) cubit.changeIndex(index);
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Calendar),
                        label: 'Leave',
                      ),
                      BottomNavigationBarItem(
                        icon: SizedBox(width: 5),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Wallet),
                        label: 'Payroll',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Setting),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              );
            },
            fallback: (BuildContext context) =>
                const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
