import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/modules/register/register_company_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import '../../models/user_model.dart';
import '../../shared/components/swipe_button.dart';
import '../../shared/components/user_activity_view.dart';
import '../../shared/cubit/app_cubit.dart';
import '../../shared/cubit/attendance_cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/icon_broken.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocBuilder<AppCubit> so the screen rebuilds when
    // userModel changes (e.g. companyId becomes non-null after registration).
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, appState) {
        final UserModel? user = AppCubit.get(context).userModel;

        return BlocConsumer<AttendanceCubit, AttendanceStates>(
          listener: (context, state) {
            if (state is AttendanceErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
          },

          builder: (context, state) {
            AttendanceCubit cubit = AttendanceCubit.get(context);
            if (user?.companyId == null && user?.userType == "Company Owner") {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Plaese Register your Company Details!",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(fontFamily: "Jannah"),
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () =>
                            navigateTo(context, RegisterCompanyScreen()),
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(
                          "Create Company",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (user?.companyId == null && user?.userType == "Employee") {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Please join a company to continue!",
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontFamily: "Jannah",
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            "Give your Id to the company",
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontFamily: "Jannah",
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 50),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                "${user?.uId}",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontFamily: "Jannah",
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: "${user?.uId}"),
                                  ).then((_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Copied to your clipboard !'),
                                      ),
                                    );
                                  });
                                },
                                icon: Icon(
                                  Icons.copy_outlined,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDatePicker(cubit, user?.uId),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Today Attendance", state, context),
                  const SizedBox(height: 16),
                  _buildCheckInOutGrid(cubit),
                  const SizedBox(height: 12),
                  _buildStatsGrid(cubit),

                  if (cubit.workingTime != "00:00:00") _buildWorkingTimeCard(cubit),

                  const SizedBox(height: 28),
                  _buildSectionHeader("Your Activity", null, context),
                  const SizedBox(height: 16),

                  _buildSwipeButton(cubit, user?.uId, context),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: UserActivityView(userActivityModel: cubit.activity),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- Date Picker Section ---
Widget _buildDatePicker(AttendanceCubit cubit, String? uid) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: HorizontalDate(
      fromDate: DateTime.now(),
      toDate: DateTime.now().subtract(const Duration(days: 10)),
      selectedDate: cubit.selectedDate,
      onTap: (newDate) {
        if (uid != null) cubit.changeDate(newDate, uid);
      },
    ),
  );
}

// --- Grids & Cards ---
Widget _buildCheckInOutGrid(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Check In",
            cubit.activity?.checkIn?.inTime ?? "--:--",
            IconBroken.Login,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            "Check Out",
            cubit.activity?.outTime?.outTime ?? "--:--",
            IconBroken.Logout,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatsGrid(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Break Time",
            cubit.breakTime,
            Icons.coffee_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            "Total Days",
            "${cubit.monthWorkedDays}",
            IconBroken.Calendar,
          ),
        ),
      ],
    ),
  );
}

Widget _buildWorkingTimeCard(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: _buildInfoCard(
      "Working Hours",
      cubit.workingTime,
      Icons.timer_outlined,
    ),
  );
}

// --- Swipe Button Logic ---
Widget _buildSwipeButton(
  AttendanceCubit cubit,
  String? uid,
  BuildContext context,
) {
  final isToday = DateUtils.isSameDay(cubit.selectedDate, DateTime.now());

  if (!isToday || cubit.activity?.outTime != null) return const SizedBox();

  // Disable swipe while action is in progress
  if (cubit.isPerformingAction) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  final appCubit = AppCubit.get(context);
  final companyId = appCubit.userModel?.companyId ?? '';
  final teamId = appCubit.userModel?.managerId;
  final companyStartTime = appCubit.companyModel?.startTime;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        // Primary swipe slider (Check-in / Check-out / End Break)
        SwipeButton.expand(
          thumb: const Icon(
            IconBroken.Arrow___Right_2,
            size: 35,
            color: AppColors.white,
          ),
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withAlpha(430),
          inactiveThumbColor: AppColors.grey300,
          onSwipe: () {
            if (uid != null) {
              final user = appCubit.userModel;
              final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
              cubit.performSwipeAction(
                uid,
                companyId,
                teamId: teamId,
                companyStartTime: companyStartTime,
                userName: fullName.isNotEmpty ? fullName : null,
              );
            }
          },
          child: Text(
            cubit.activity?.nextAction.label ?? "Check In",
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // "Take a Break" button — shown only when checked in, not on break
        if (cubit.activity?.canTakeBreak == true) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (uid != null) {
                  final user = appCubit.userModel;
                  final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
                  cubit.performBreakAction(
                    uid,
                    companyId,
                    teamId: teamId,
                    userName: fullName.isNotEmpty ? fullName : null,
                  );
                }
              },
              icon: const Icon(Icons.coffee_outlined),
              label: const Text(
                "Take a Break",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// --- Helper Methods ---
Widget _buildSectionHeader(String title, AttendanceStates? state,BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontFamily: "Jannah",
                fontWeight: FontWeight.bold,
        ),
        ),
        const Spacer(),
        if (state is AttendanceChangeDateState)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    ),
  );
}

Widget _buildInfoCard(String title, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: AppColors.grey300,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 6.0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: AppColors.grey700, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
