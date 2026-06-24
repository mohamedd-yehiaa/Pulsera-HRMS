import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pulsera/shared/app_extension.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/styles/theme.dart';

/// Admin screen to view and edit a specific employee's attendance.
class EmployeeAttendanceScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeAttendanceScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    AttendanceCubit.get(context).init(widget.employeeId);
  }

  void _changeDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    AttendanceCubit.get(context).changeDate(newDate, widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          S.of(context).employeeAttendanceTitle(widget.employeeName),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceStates>(
        listener: (context, state) {
          if (state is AttendanceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = AttendanceCubit.get(context);
          final activity = cubit.activity;

          if (state is AttendanceLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Date picker
              _buildDateSelector(context),
              const SizedBox(height: 24),

              // Status badges row
              if (activity?.checkInStatus != null ||
                  activity?.checkOutStatus != null) ...[
                _buildStatusBadgesRow(activity!),
                const SizedBox(height: 16),
              ] else if (activity?.status != null) ...[
                _buildLegacyStatusBadge(activity!.status!),
                const SizedBox(height: 16),
              ],

              // Check-in / Check-out cards
              Row(
                children: [
                  Expanded(
                    child: _buildTimeCard(
                      context,
                      title: S.of(context).checkIn,
                      time: activity?.checkIn?.inTime ?? "--:--",
                      icon: IconBroken.Login,
                      onEdit: activity?.checkIn != null
                          ? () => _showEditTimeDialog(
                              context,
                              cubit,
                              'checkIn',
                              activity!.checkIn!.inTime ?? '',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeCard(
                      context,
                      title: S.of(context).checkOut,
                      time: activity?.outTime?.outTime ?? "--:--",
                      icon: IconBroken.Logout,
                      onEdit: activity?.outTime != null
                          ? () => _showEditTimeDialog(
                              context,
                              cubit,
                              'outTime',
                              activity!.outTime!.outTime ?? '',
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Break time & Worked hours
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      S.of(context).breakTime,
                      cubit.breakTime,
                      Icons.coffee_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      S.of(context).workedHours,
                      cubit.workingTime,
                      Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time-rule details
              _buildTimeRuleCards(context, activity),
              // Worked minutes (persisted)
              if (activity?.workedMinutes != null)
                _buildInfoCard(
                  context,
                  S.of(context).persistedWorkedMinutes,
                  S.of(context).nMin('${activity!.workedMinutes}'),
                  IconBroken.Time_Circle,
                ),

              const SizedBox(height: 24),

              // Break details
              if ((activity?.breakInTime?.isNotEmpty ?? false)) ...[
                Text(
                  S.of(context).breakDetails,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBreakList(context, activity!),
              ],

              const SizedBox(height: 24),

              // Edit status button
              if (activity != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditStatusDialog(context, cubit),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(S.of(context).editAttendanceStatus),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Status badges row (new time-rule based)
  // ===========================================================================
  Widget _buildStatusBadgesRow(dynamic activity) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (activity.checkInStatus != null)
          _buildStatusBadge(
            _checkInStatusLabel(activity.checkInStatus!),
            _statusColor(activity.checkInStatus!),
            _statusIcon(activity.checkInStatus!),
          ),
        if (activity.checkOutStatus != null)
          _buildStatusBadge(
            _checkOutStatusLabel(activity.checkOutStatus!),
            _statusColor(activity.checkOutStatus!),
            _statusIcon(activity.checkOutStatus!),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color, IconData icon) {
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

  Widget _buildLegacyStatusBadge(String status) {
    final color = status == 'late' ? AppColors.orange500 : AppColors.green400;
    // FIX: Using switch to localize the legacy status from the backend
    final String localizedStatus = switch (status) {
      'present' => S.of(context).present,
      'late' => S.of(context).lateLabel,
      'absent' => S.of(context).absent,
      _ => status.toUpperCase(),
    };

    return _buildStatusBadge(
      localizedStatus,
      color,
      status == 'late' ? Icons.warning_amber_rounded : Icons.check_circle,
    );
  }

  // Time-rule detail cards
  Widget _buildTimeRuleCards(BuildContext context, dynamic activity) {
    if (activity == null) return const SizedBox();

    final List<Widget> cards = [];

    if (activity.lateMinutes != null && activity.lateMinutes > 0) {
      cards.add(
        _buildDetailCard(
          context,
          Icons.warning_amber_rounded,
          AppColors.orange500,
          S.of(context).lateLabel,
          S.of(context).nMin('${activity.lateMinutes}'),
        ),
      );
    }
    if (activity.earlyLeaveMinutes != null && activity.earlyLeaveMinutes > 0) {
      cards.add(
        _buildDetailCard(
          context,
          Icons.exit_to_app,
          AppColors.orange500,
          S.of(context).earlyLeaveLabel,
          S.of(context).nMin('${activity.earlyLeaveMinutes}'),
        ),
      );
    }
    if (activity.overtimeMinutes != null && activity.overtimeMinutes > 0) {
      cards.add(
        _buildDetailCard(
          context,
          Icons.trending_up,
          AppColors.primary,
          S.of(context).overtimeLabel,
          S.of(context).nMin('${activity.overtimeMinutes}'),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox();

    return Column(children: [const SizedBox(height: 12), ...cards]);
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              // Catching numbers passed into detail cards
              value.localizeDigits(context),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _checkInStatusLabel(String status) {
    return switch (status) {
      'early' => S.of(context).earlyCheckInLabel,
      'on_time' => S.of(context).statusOnTime,
      'late' => S.of(context).lateLabel,
      'very_late' => S.of(context).statusVeryLate,
      _ => status.toUpperCase(),
    };
  }

  String _checkOutStatusLabel(String status) {
    return switch (status) {
      'early_leave' => S.of(context).earlyLeaveLabel,
      'completed' => S.of(context).statusCompleted,
      'overtime' => S.of(context).overtimeLabel,
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

  // ===========================================================================
  // Date selector
  // ===========================================================================
  Widget _buildDateSelector(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    // Retrieve the locale from context
    final locale = Localizations.localeOf(context).toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () =>
              _changeDate(_selectedDate.subtract(const Duration(days: 1))),
          icon: Icon(
            isRtl ? IconBroken.Arrow___Right_2 : IconBroken.Arrow___Left_2,
          ),
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) _changeDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              // Inject locale into DateFormat and localize the digits
              DateFormat(
                'EEE, MMM d, yyyy',
                locale,
              ).format(_selectedDate).localizeDigits(context),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        IconButton(
          onPressed:
              _selectedDate.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              )
              ? () => _changeDate(_selectedDate.add(const Duration(days: 1)))
              : null,
          icon: Icon(
            isRtl ? IconBroken.Arrow___Left_2 : IconBroken.Arrow___Right_2,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Time card with optional edit
  // ===========================================================================
  Widget _buildTimeCard(
    BuildContext context, {
    required String title,
    required String time,
    required IconData icon,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: AppColors.grey700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            // FIX: Localize time formatting
            time.localizeDigits(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
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
            // FIX: Catch raw minute strings
            value.localizeDigits(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Break list
  // ===========================================================================
  Widget _buildBreakList(BuildContext context, dynamic activity) {
    final breakIns = activity.breakInTime as List<String>? ?? [];
    final breakOuts = activity.breakOutTime as List<String>? ?? [];
    final pairCount = breakIns.length < breakOuts.length
        ? breakIns.length
        : breakOuts.length;

    return Column(
      children: List.generate(pairCount, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: boxDecoration,
            child: Row(
              children: [
                const Icon(
                  Icons.coffee_outlined,
                  size: 18,
                  color: Colors.brown,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).breakN(i + 1).localizeDigits(context),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                // Added textDirection LTR so the arrow direction makes logical sense regardless of language
                Text(
                  "${breakIns[i]} → ${breakOuts[i]}".localizeDigits(context),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // Edit dialogs
  // ===========================================================================
  void _showEditTimeDialog(
    BuildContext context,
    AttendanceCubit cubit,
    String field, // 'checkIn' or 'outTime'
    String currentTime,
  ) {
    final controller = TextEditingController(text: currentTime);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          field == 'checkIn'
              ? S.of(context).editCheckInTime
              : S.of(context).editCheckOutTime,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: S.of(context).timeFormatHint,
            hintText: "09:00:00",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Convert arabic keyboard entry to native english strings before saving to database
              final newTime = controller.text.toEnglishDigits().trim();
              if (newTime.isEmpty) return;

              Map<String, dynamic> updates = {};
              if (field == 'checkIn') {
                updates['checkIn'] = {
                  'inTime': newTime,
                  'msg': 'Modified by admin',
                };
              } else {
                updates['outTime'] = {
                  'outTime': newTime,
                  'msg': 'Modified by admin',
                };
              }

              // This uses a fixed format explicitly for the API Call
              cubit.updateEmployeeAttendance(
                userId: widget.employeeId,
                date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                updates: updates,
              );

              // Reload to show updated data
              Future.delayed(
                const Duration(milliseconds: 500),
                () => _loadAttendance(),
              );
            },
            child: Text(
              S.of(context).save,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStatusDialog(BuildContext context, AttendanceCubit cubit) {
    String? selectedStatus = cubit.activity?.status;

    // Helper to get translated labels for the edit dialog
    String _getLocalizedStatus(String status) {
      switch (status) {
        case 'present':
          return S.of(context).present;
        case 'late':
          return S.of(context).lateLabel;
        case 'absent':
          return S.of(context).absent;
        default:
          return status;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(S.of(context).editAttendanceStatus),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in ['present', 'late', 'absent'])
                RadioListTile<String>(
                  value: status,
                  groupValue: selectedStatus,
                  // FIX: Applied localized string instead of toUpperCase() English hack
                  title: Text(_getLocalizedStatus(status)),
                  onChanged: (v) => setDialogState(() => selectedStatus = v),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (selectedStatus != null) {
                  // This explicit string is safe as it is what the API expects
                  cubit.updateEmployeeAttendance(
                    userId: widget.employeeId,
                    date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    updates: {'status': selectedStatus},
                  );
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    () => _loadAttendance(),
                  );
                }
              },
              child: Text(
                S.of(context).save,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
