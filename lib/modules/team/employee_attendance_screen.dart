import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

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
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(IconBroken.Arrow___Left_2)),
        title: Text(
          "${widget.employeeName}'s Attendance",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

              // Status badge
              if (activity?.status != null) ...[
                _buildStatusBadge(activity!.status!),
                const SizedBox(height: 16),
              ],

              // Check-in / Check-out cards
              Row(
                children: [
                  Expanded(
                    child: _buildTimeCard(
                      context,
                      title: "Check In",
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
                      title: "Check Out",
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
                      "Break Time",
                      cubit.breakTime,
                      Icons.coffee_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      "Worked Hours",
                      cubit.workingTime,
                      Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Worked minutes (persisted)
              if (activity?.workedMinutes != null)
                _buildInfoCard(
                  "Persisted Worked Minutes",
                  "${activity!.workedMinutes} min",
                  IconBroken.Time_Circle,
                ),

              const SizedBox(height: 24),

              // Break details
              if ((activity?.breakInTime?.isNotEmpty ?? false)) ...[
                const Text(
                  "Break Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBreakList(activity!),
              ],

              const SizedBox(height: 24),

              // Edit status button
              if (activity != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditStatusDialog(context, cubit),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit Attendance Status"),
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
  // Date selector
  // ===========================================================================
  Widget _buildDateSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _changeDate(
            _selectedDate.subtract(const Duration(days: 1)),
          ),
          icon: const Icon(IconBroken.Arrow___Left_2),
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
              DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _selectedDate.isBefore(
            DateTime.now().subtract(const Duration(days: 1)),
          )
              ? () => _changeDate(
                    _selectedDate.add(const Duration(days: 1)),
                  )
              : null,
          icon: const Icon(IconBroken.Arrow___Right_2),
        ),
      ],
    );
  }

  // ===========================================================================
  // Status badge
  // ===========================================================================
  Widget _buildStatusBadge(String status) {
    final color = status == 'late' ? AppColors.orange500 : AppColors.green400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'late' ? Icons.warning_amber_rounded : Icons.check_circle,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
          Text(title,
              style: TextStyle(color: AppColors.grey700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(color: AppColors.grey700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Break list
  // ===========================================================================
  Widget _buildBreakList(dynamic activity) {
    final breakIns = activity.breakInTime as List<String>? ?? [];
    final breakOuts = activity.breakOutTime as List<String>? ?? [];
    final pairCount =
        breakIns.length < breakOuts.length ? breakIns.length : breakOuts.length;

    return Column(
      children: List.generate(pairCount, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.coffee_outlined, size: 18, color: Colors.brown),
                const SizedBox(width: 8),
                Text("Break ${i + 1}:",
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text("${breakIns[i]} → ${breakOuts[i]}"),
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
        title: Text("Edit ${field == 'checkIn' ? 'Check-In' : 'Check-Out'} Time"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Time (HH:mm:ss)",
            hintText: "09:00:00",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final newTime = controller.text.trim();
              if (newTime.isEmpty) return;

              Map<String, dynamic> updates = {};
              if (field == 'checkIn') {
                updates['checkIn'] = {'inTime': newTime, 'msg': 'Modified by admin'};
              } else {
                updates['outTime'] = {'outTime': newTime, 'msg': 'Modified by admin'};
              }

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
            child: const Text("Save", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showEditStatusDialog(BuildContext context, AttendanceCubit cubit) {
    String? selectedStatus = cubit.activity?.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Edit Attendance Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in ['present', 'late', 'absent'])
                RadioListTile<String>(
                  value: status,
                  groupValue: selectedStatus,
                  title: Text(status[0].toUpperCase() + status.substring(1)),
                  onChanged: (v) => setDialogState(() => selectedStatus = v),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (selectedStatus != null) {
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
              child: const Text("Save",
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
