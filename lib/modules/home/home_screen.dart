import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pulsera/models/work_schedule_config.dart';
import 'package:pulsera/modules/home/qr_scanner_screen.dart';
import 'package:pulsera/modules/register/register_company_screen.dart';
import 'package:pulsera/shared/app_extension.dart';
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
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, appState) {
        final UserModel? user = AppCubit.get(context).userModel;

        return BlocConsumer<AttendanceCubit, AttendanceStates>(
          listener: (context, state) {
            if (state is AttendanceErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
            // QR validation failed
            if (state is LocationValidationFailedState) {
              Fluttertoast.showToast(
                msg: state.error,
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: AppColors.error,
                textColor: Colors.white,
              );
            }
            // QR validation succeeded
            if (state is LocationVerifiedState) {
              Fluttertoast.showToast(
                msg: S.of(context).locationVerified,
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: AppColors.green400,
                textColor: Colors.white,
              );
            }
            // Show time-rule feedback message after check-in/out (fires ONCE)
            if (state is AttendanceActionCompletedState) {
              final msg = state.message;
              if (msg != null && msg.isNotEmpty) {
                Fluttertoast.showToast(
                  msg: msg,
                  toastLength: Toast.LENGTH_SHORT,
                  backgroundColor: Colors.black87,
                );
              }
              // Reload monthly summary so total days counter updates
              final appCubit = AppCubit.get(context);
              final u = appCubit.userModel;
              final company = appCubit.companyModel;
              if (u != null && u.uId != null && company != null) {
                final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
                AttendanceCubit.get(context).loadMonthlySummary(
                  userId: u.uId!,
                  yearMonth: yearMonth,
                  companyWorkingDays: company.workingDays ?? [],
                  companyStartTime: company.startTime ?? '09:00',
                  lateGracePeriodMinutes: company.gracePeriodMinutes ?? 15,
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
            if (user.companyId == null && user.userType == "Company Owner") {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).registerCompanyPrompt,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () =>
                            navigateTo(context, RegisterCompanyScreen()),
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(
                          S.of(context).createCompany,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (user.companyId == null && user.userType == "Employee") {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).joinCompanyPrompt,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context).giveIdToCompany,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 32),
                        // Your existing Copy ID Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                "${user.uId}",
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(color: AppColors.primary),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                              const SizedBox(width: 0.5),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: "${user.uId}"),
                                  ).then((_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).copiedToClipboard,
                                        ),
                                      ),
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
                          label: Text(
                            S.of(context).refreshStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
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
                  _buildDatePicker(cubit, user.uId),
                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    S.of(context).todayAttendance,
                    state,
                    context,
                  ),
                  const SizedBox(height: 16),

                  // Status badge row
                  _buildAttendanceStatusRow(cubit, context),

                  _buildCheckInOutGrid(cubit, context),
                  const SizedBox(height: 12),
                  _buildStatsGrid(cubit, context),

                  if (cubit.workingTime != "00:00:00")
                    _buildWorkingTimeCard(cubit, context),

                  // Time-rule details (late minutes, early leave, overtime)
                  _buildTimeRuleDetails(cubit, context),

                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    S.of(context).yourActivity,
                    null,
                    context,
                  ),
                  const SizedBox(height: 16),

                  _buildSwipeButton(cubit, user.uId, context),
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
      toDate: DateTime.now().subtract(const Duration(days: 13)),
      selectedDate: cubit.selectedDate,
      onTap: (newDate) {
        if (uid != null) cubit.changeDate(newDate, uid);
      },
    ),
  );
}

// --- Attendance Status Row ---
Widget _buildAttendanceStatusRow(AttendanceCubit cubit, BuildContext context) {
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
          _buildStatusChip(
            checkInStatus,
            _checkInStatusLabel(checkInStatus, context),
          ),
        if (checkOutStatus != null)
          _buildStatusChip(
            checkOutStatus,
            _checkOutStatusLabel(checkOutStatus, context),
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

String _checkInStatusLabel(String status, BuildContext context) {
  return switch (status) {
    'early' => S.of(context).statusEarly,
    'on_time' => S.of(context).statusOnTime,
    'late' => S.of(context).statusLate,
    'very_late' => S.of(context).statusVeryLate,
    _ => status.toUpperCase(),
  };
}

String _checkOutStatusLabel(String status, BuildContext context) {
  return switch (status) {
    'early_leave' => S.of(context).statusEarlyLeave,
    'completed' => S.of(context).statusCompleted,
    'overtime' => S.of(context).statusOvertime,
    'insufficient_hours' => S.of(context).statusInsufficientHours,
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
Widget _buildTimeRuleDetails(AttendanceCubit cubit, BuildContext context) {
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
          Text(
            S.of(context).timeDetails,
            style: const TextStyle(
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
              S.of(context).lateByMinutes(activity.lateMinutes!),
              context,
            ),
          if (activity.earlyLeaveMinutes != null &&
              activity.earlyLeaveMinutes! > 0)
            _buildDetailRow(
              Icons.exit_to_app,
              AppColors.orange500,
              S.of(context).leftEarlyMinutes(activity.earlyLeaveMinutes!),
              context,
            ),
          if (activity.overtimeMinutes != null && activity.overtimeMinutes! > 0)
            _buildDetailRow(
              Icons.trending_up,
              AppColors.primary,
              S.of(context).overtimeMinutes(activity.overtimeMinutes!),
              context,
            ),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(IconData icon, Color color, String text, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text.localizeDigits(context),
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
Widget _buildCheckInOutGrid(AttendanceCubit cubit, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            S.of(context).checkIn,
            cubit.activity?.checkIn?.inTime ?? "--:--",
            IconBroken.Login,
            context,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            S.of(context).checkOut,
            cubit.activity?.outTime?.outTime ?? "--:--",
            IconBroken.Logout,
            context,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatsGrid(AttendanceCubit cubit, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            S.of(context).breakTime,
            cubit.breakTime,
            Icons.coffee_outlined,
            context,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            S.of(context).totalDaysLabel,
            "${cubit.monthWorkedDays}",
            IconBroken.Calendar,
            context,
          ),
        ),
      ],
    ),
  );
}

Widget _buildWorkingTimeCard(AttendanceCubit cubit, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: _buildInfoCard(
      S.of(context).workingHours,
      cubit.workingTime,
      Icons.timer_outlined,
      context,
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
  final bool isRtl = Directionality.of(context) == TextDirection.rtl;

  if (!isToday || cubit.activity?.outTime != null || uid == null)
    return const SizedBox();

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
  final sharedSecret = appCubit.companyModel?.sharedSecret;
  final user = appCubit.userModel;
  final rawName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
  final String? parsedUserName = rawName.isNotEmpty ? rawName : null;

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
        SwipeButton.expand(
          thumb: Icon(
            isRtl ? IconBroken.Arrow___Left_2 : IconBroken.Arrow___Right_2,
            size: 35,
            color: AppColors.white,
          ),
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withAlpha(430),
          inactiveThumbColor: AppColors.grey300,
          onSwipe: () {
            _openScannerAndValidate(
              context: context,
              cubit: cubit,
              sharedSecret: sharedSecret,
              scheduleConfig: scheduleConfig,
              onSuccess: () {
                cubit.performSwipeAction(
                  uid,
                  companyId,
                  teamId: teamId,
                  companyStartTime: companyStartTime,
                  userName: parsedUserName,
                  scheduleConfig: scheduleConfig,
                );
              },
            );
          },
          child: Text(
            cubit.activity?.nextAction.label ?? S.of(context).checkIn,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        if (cubit.activity?.canTakeBreak == true) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _openScannerAndValidate(
                  context: context,
                  cubit: cubit,
                  sharedSecret: sharedSecret,
                  onSuccess: () {
                    cubit.performBreakAction(
                      uid,
                      companyId,
                      teamId: teamId,
                      userName: parsedUserName,
                    );
                  },
                );
              },
              icon: const Icon(Icons.coffee_outlined),
              label: Text(
                S.of(context).takeABreak,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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

/// Opens the QR scanner screen and passes the result to the cubit.
///
/// Flow: UI opens scanner → scanner returns raw hash → cubit validates
/// → If early/late, show confirmation dialog → onSuccess
void _openScannerAndValidate({
  required BuildContext context,
  required AttendanceCubit cubit,
  required String? sharedSecret,
  required VoidCallback onSuccess,
  WorkScheduleConfig? scheduleConfig,
}) async {
  // Navigate to QR scanner and await the scanned hash
  final scannedHash = await Navigator.push<String?>(
    context,
    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
  );

  // User dismissed scanner without scanning
  if (scannedHash == null || !context.mounted) return;

  // Pre-validate to check if early/late — show confirmation dialog if needed
  if (scheduleConfig != null) {
    final preview = cubit.preValidateAction(scheduleConfig: scheduleConfig);
    if (preview != null && _isEarlyOrLateStatus(preview.status)) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(
                _isLateStatus(preview.status)
                    ? Icons.warning_amber_rounded
                    : Icons.access_time,
                color: _isLateStatus(preview.status)
                    ? AppColors.orange500
                    : AppColors.blue600,
              ),
              const SizedBox(width: 8),
              Text(S.of(context).confirmAction),
            ],
          ),
          content: Text(preview.message, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(S.of(context).confirm),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;
    }
  }

  // Pass to cubit — single source of truth for validation
  cubit.validateAndExecute(
    scannedHash: scannedHash,
    sharedSecret: sharedSecret,
    onSuccess: onSuccess,
  );
}

/// Returns true if the status represents an early or late condition
/// that warrants a confirmation dialog.
bool _isEarlyOrLateStatus(String status) {
  return const {
    'early',
    'late',
    'very_late',
    'early_leave',
    'insufficient_hours',
  }.contains(status);
}

/// Returns true if the status represents a late/warning condition.
bool _isLateStatus(String status) {
  return const {
    'late',
    'very_late',
    'early_leave',
    'insufficient_hours',
  }.contains(status);
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

// Updated with Context to access .localizeDigits()
Widget _buildInfoCard(String title, String value, IconData icon, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: AppColors.grey700, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value.localizeDigits(context), // Magic applied here!
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
