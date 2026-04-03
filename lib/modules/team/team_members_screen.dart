import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/team/add_team_member_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/modules/team/employee_attendance_screen.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final appCubit = AppCubit.get(context);
    final user = appCubit.userModel;
    if (user == null) return;

    final teamCubit = TeamCubit.get(context);

    if (user.userType == 'Company Owner') {
      // UPDATED: Now calling the unified load function
      teamCubit.loadFullTeam(managerId: user.uId ?? '');
    } else {
      teamCubit.loadMyManager(user.managerId);
      teamCubit.loadFullTeam(managerId: user.managerId ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = AppCubit.get(context);
    final currentUser = appCubit.userModel;
    final isManager = currentUser?.userType == "Company Owner";

    return BlocConsumer<TeamCubit, TeamStates>(
      listener: (context, state) {
        if (state is TeamErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = TeamCubit.get(context);
        bool isLoading = state is TeamLoadingState;

        return Scaffold(
          appBar: AppBar(
            leading:backButton(context),
            title: Text(
              isManager ? "My Team" : "Team Info",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              IconButton(
                onPressed: () => _loadData(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : isManager
              ? _buildManagerView(context, cubit)
              : _buildEmployeeView(context, cubit, currentUser),
        );
      },
    );
  }

  // ===========================================================================
  // Manager View — Now using MembersData
  // ===========================================================================
  Widget _buildManagerView(BuildContext context, TeamCubit cubit) {
    // UPDATED: Accessing list from cubit.teamData?.members
    final membersList = cubit.teamData?.members ?? [];

    final filtered = membersList.where((m) {
      if (_searchQuery.isEmpty) return true;
      return (m.fullName ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          SearchBar(
            hintText: "Search team members",
            leading: const Icon(IconBroken.Search, color: Colors.grey),
            elevation: WidgetStateProperty.all(0.5),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "${filtered.length} Member${filtered.length != 1 ? 's' : ''}",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey[200]),
                    itemBuilder: (context, index) =>
                        _buildMemberTile(context, filtered[index]),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => AddTeamMemberScreen()),
                );
                if (result == true) _loadData();
              },
              icon: const Icon(IconBroken.Add_User, color: Colors.white),
              label: const Text(
                "Add Member",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, MembersData member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(
          (member.fullName ?? 'E')[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        member.fullName ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                member.email ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Spacer(),
              Text(
                member.roleType ?? 'Employee',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildBadge(
                "\$${member.monthlySalary?.toStringAsFixed(0) ?? '0'}/mo",
                AppColors.blue700,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                "${member.remainingVacationDays ?? 0}/${member.monthlyVacationDays ?? 0} days",
                AppColors.green400,
              ),
              const Spacer(),
              member.status != null && member.status != 'Terminated'
                  ? Text(
                      member.status!,
                      style: TextStyle(
                        color: AppColors.green400,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      member.status!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') _showRemoveDialog(context, member);
          if (value == 'attendance') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeAttendanceScreen(
                  employeeId: member.uId ?? '',
                  employeeName: member.fullName ?? 'Employee',
                ),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'attendance',
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                SizedBox(width: 8),
                Text('View Attendance'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.remove_circle_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Remove'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconBroken.User, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            "No team members yet",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap \"Add Member\" to assign employees to your team.",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, MembersData member) {
    final appCubit = AppCubit.get(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text(
          "Are you sure you want to remove ${member.fullName} from your team?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              TeamCubit.get(context).removeEmployeeFromTeam(
                member: member,
                managerId: appCubit.userModel?.uId ?? '',
              );
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Employee View — Manager info + Vacation balance
  // ===========================================================================
  Widget _buildEmployeeView(
    BuildContext context,
    TeamCubit cubit,
    UserModel? currentUser,
  ) {
    final myData = cubit.teamData?.getMemberByUid(currentUser?.uId);
    if (myData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconBroken.User1, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Not assigned to any team yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Manager Section
          Text("My Manager", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (cubit.myManager != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (cubit.myManager?.firstName ?? 'M')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${cubit.myManager?.firstName ?? ''} ${cubit.myManager?.lastName ?? ''}",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cubit.myManager?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "You are not assigned to any manager yet.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 30),

          // Vacation Balance Section
          Text(
            "Vacation Balance",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: "Total",
                  value: "${myData.monthlyVacationDays ?? 0}",
                  subtitle: "days/year",
                  color: AppColors.primary,
                  icon: IconBroken.Calendar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: "Remaining",
                  value: "${myData.remainingVacationDays ?? 0}",
                  subtitle: "days left",
                  color: AppColors.green400,
                  icon: IconBroken.Time_Circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: "Used",
                  value:
                      "${(myData.monthlyVacationDays ?? 0) - (myData.remainingVacationDays ?? 0)}",
                  subtitle: "days",
                  color: AppColors.orange500,
                  icon: IconBroken.Ticket,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Salary Info Section
          Text(
            "Salary Info",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey300.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    IconBroken.Wallet,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Salary",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${myData.monthlySalary?.toStringAsFixed(2) ?? '0.00'}",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.15),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey300,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
