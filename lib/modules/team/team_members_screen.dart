import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/team/add_team_member_screen.dart';
import 'package:pulsera/shared/app_extension.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/modules/team/employee_attendance_screen.dart';
import 'package:pulsera/shared/utils/responsive_breakpoints.dart';

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
    Directionality.of(context);
    Localizations.localeOf(context);
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
          // ── CONDITIONALLY RENDER APPBAR FOR MOBILE ONLY ──
          appBar: Breakpoints.isMobile(context)
              ? AppBar(
                  leading: backButton(context),
                  title: Text(
                    isManager ? S.of(context).myTeam : S.of(context).teamInfo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _loadData(),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              : null, // On Tablet/Desktop, this hides so the global TopBarWidget takes over completely
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
            hintText: S.of(context).searchTeamMembers,
            leading: const Icon(IconBroken.Search, color: Colors.grey),
            elevation: WidgetStateProperty.all(0.5),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                S
                    .of(context)
                    .nMembersCount(filtered.length)
                    .localizeDigits(context),
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
              label: Text(
                S.of(context).addMemberButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, MembersData member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: (member.image != null && member.image!.isNotEmpty)
          ? CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(member.image!),
            )
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSecondary, width: 1),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  (member.fullName ?? 'E')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
              Expanded(
                child: Text(
                  member.email ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4), // Replaced Spacer to keep elements tidy
              Text(
                member.roleType ?? S.of(context).employeeRoleLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Changed Row to Wrap so badges drop to a new line if they run out of room
          Wrap(
            spacing: 2,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _buildBadge(
                "${member.monthlySalary.formatMoney(context)} / ${S.of(context).month}",
                AppColors.blue700,
              ),
              _buildBadge(
                "${member.remainingVacationDays ?? 0}/${member.monthlyVacationDays ?? 0} ${S.of(context).daysLabel}"
                    .localizeDigits(context),
                AppColors.green400,
              ),
              member.status != null && member.status != 'Terminated'
                  ? Text(
                      member.status!,
                      style: const TextStyle(
                        color: AppColors.green400,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      member.status ?? '',
                      style: const TextStyle(
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
          PopupMenuItem(
            value: 'attendance',
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(S.of(context).viewAttendance),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Text(S.of(context).remove),
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
            S.of(context).noTeamMembers,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).tapAddMemberHint,
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
        title: Text(S.of(context).removeMember),
        content: Text(
          S.of(context).removeMemberConfirmationName(member.fullName ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              TeamCubit.get(context).removeEmployeeFromTeam(
                member: member,
                managerId: appCubit.userModel?.uId ?? '',
              );
            },
            child: Text(
              S.of(context).remove,
              style: const TextStyle(color: AppColors.error),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(IconBroken.User1, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).notAssignedToTeamYet,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
          Text(
            S.of(context).myManager,
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                S.of(context).notAssignedToManager,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 30),

          // Vacation Balance Section
          Text(
            S.of(context).vacationBalance,
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
                  title: S.of(context).total,
                  value: "${myData.monthlyVacationDays ?? 0}",
                  subtitle: S.of(context).daysPerMonthShort,
                  color: AppColors.primary,
                  icon: IconBroken.Calendar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: S.of(context).remaining,
                  value: "${myData.remainingVacationDays ?? 0}",
                  subtitle: S.of(context).daysLeft,
                  color: AppColors.green400,
                  icon: IconBroken.Time_Circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: S.of(context).usedLabel,
                  value:
                      "${(myData.monthlyVacationDays ?? 0) - (myData.remainingVacationDays ?? 0)}",
                  subtitle: S.of(context).daysLabel,
                  color: AppColors.orange500,
                  icon: IconBroken.Ticket,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Salary Info Section
          Text(
            S.of(context).salaryInfo,
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
                      S.of(context).monthlySalary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      myData.monthlySalary.formatMoney(context),
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
            value.localizeDigits(context),
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
