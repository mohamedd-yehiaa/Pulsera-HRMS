import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/work_schedule_config.dart';
import 'package:pulsera/modules/register/register_company_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/styles/theme.dart';
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
            // Show time-rule feedback message after check-in/out
            if (state is AttendanceSuccessState) {
              final msg = AttendanceCubit.get(context).lastActionMessage;
              if (msg != null && msg.isNotEmpty) {
                Fluttertoast.showToast(
                  msg: msg,
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.black87,
                );
              }
            }
          },

          builder: (context, state) {
            AttendanceCubit cubit = AttendanceCubit.get(context);
            if (user == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (user?.companyId == null && user?.userType == "Company Owner") {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Plaese Register your Company Details!",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () =>
                            navigateTo(context, RegisterCompanyScreen()),
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(
                          "Create Company",
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
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
                    child: Column( // Note: Removed the Expanded() you had here, it causes layout errors inside Center
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Please join a company to continue!",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "Give your Id to the company",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 50),

                        // Your existing Copy ID Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                "${user?.uId}",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(color: AppColors.primary),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: "${user?.uId}"),
                                  ).then((_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied to your clipboard !')),
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.copy_outlined,
                                  color: AppColors.grey900,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // === NEW REFRESH BUTTON ===
                        // This forces the Cubit to check the database again to see
                        // if the owner has updated this employee's companyId
                        OutlinedButton.icon(
                          onPressed: () {
                            // Call whatever function in AppCubit fetches the user data from your DB.
                            // It is usually called getUserData() or fetchProfile()
                            AppCubit.get(context).getUserData();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            "Refresh Status",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ],
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

                  // Status badge row
                  _buildAttendanceStatusRow(cubit),

                  _buildCheckInOutGrid(cubit),
                  const SizedBox(height: 12),
                  _buildStatsGrid(cubit),

                  if (cubit.workingTime != "00:00:00")
                    _buildWorkingTimeCard(cubit),

                  // Time-rule details (late minutes, early leave, overtime)
                  _buildTimeRuleDetails(cubit),

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

// --- Attendance Status Row ---
Widget _buildAttendanceStatusRow(AttendanceCubit cubit) {
  final activity = cubit.activity;
  if (activity == null) return const SizedBox();

  final checkInStatus = activity.checkInStatus;
  final checkOutStatus = activity.checkOutStatus;

  if (checkInStatus == null && checkOutStatus == null) return const SizedBox();

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (checkInStatus != null)
          _buildStatusChip(checkInStatus, _checkInStatusLabel(checkInStatus)),
        if (checkOutStatus != null)
          _buildStatusChip(
            checkOutStatus,
            _checkOutStatusLabel(checkOutStatus),
          ),
      ],
    ),
  );
}

Widget _buildStatusChip(String status, String label) {
  final color = _statusColor(status);
  final icon = _statusIcon(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(80)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

String _checkInStatusLabel(String status) {
  return switch (status) {
    'early' => 'Early',
    'on_time' => 'On Time',
    'late' => 'Late',
    'very_late' => 'Very Late',
    _ => status.toUpperCase(),
  };
}

String _checkOutStatusLabel(String status) {
  return switch (status) {
    'early_leave' => 'Early Leave',
    'completed' => 'Completed',
    'overtime' => 'Overtime',
    'insufficient_hours' => 'Insufficient Hours',
    _ => status.toUpperCase(),
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'on_time' || 'completed' => AppColors.green400,
    'early' => AppColors.blue600,
    'late' || 'early_leave' => AppColors.orange500,
    'very_late' || 'insufficient_hours' => AppColors.error,
    'overtime' => AppColors.primary,
    _ => AppColors.grey700,
  };
}

IconData _statusIcon(String status) {
  return switch (status) {
    'on_time' || 'completed' => Icons.check_circle,
    'early' => Icons.access_time,
    'late' || 'very_late' => Icons.warning_amber_rounded,
    'early_leave' => Icons.exit_to_app,
    'overtime' => Icons.trending_up,
    'insufficient_hours' => Icons.error_outline,
    _ => Icons.info_outline,
  };
}

// --- Time Rule Details ---
Widget _buildTimeRuleDetails(AttendanceCubit cubit) {
  final activity = cubit.activity;
  if (activity == null) return const SizedBox();

  final hasDetails =
      (activity.lateMinutes != null && activity.lateMinutes! > 0) ||
      (activity.earlyLeaveMinutes != null && activity.earlyLeaveMinutes! > 0) ||
      (activity.overtimeMinutes != null && activity.overtimeMinutes! > 0);

  if (!hasDetails) return const SizedBox();

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Time Details",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          if (activity.lateMinutes != null && activity.lateMinutes! > 0)
            _buildDetailRow(
              Icons.warning_amber_rounded,
              AppColors.orange500,
              "Late by ${activity.lateMinutes} min",
            ),
          if (activity.earlyLeaveMinutes != null &&
              activity.earlyLeaveMinutes! > 0)
            _buildDetailRow(
              Icons.exit_to_app,
              AppColors.orange500,
              "Left ${activity.earlyLeaveMinutes} min early",
            ),
          if (activity.overtimeMinutes != null && activity.overtimeMinutes! > 0)
            _buildDetailRow(
              Icons.trending_up,
              AppColors.primary,
              "Overtime: ${activity.overtimeMinutes} min",
            ),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(IconData icon, Color color, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  // Build schedule config from company model
  WorkScheduleConfig? scheduleConfig;
  if (appCubit.companyModel != null) {
    scheduleConfig = WorkScheduleConfig.fromCompanyModel(
      appCubit.companyModel!,
    );
  }

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
              final fullName =
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
              cubit.performSwipeAction(
                uid,
                companyId,
                teamId: teamId,
                companyStartTime: companyStartTime,
                userName: fullName.isNotEmpty ? fullName : null,
                scheduleConfig: scheduleConfig,
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
                  final fullName =
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
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
Widget _buildSectionHeader(
  String title,
  AttendanceStates? state,
  BuildContext context,
) {
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
    decoration: boxDecoration,
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
