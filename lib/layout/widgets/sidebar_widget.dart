import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/profile/profile_details_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

/// Fixed sidebar for desktop / collapsed rail for tablet.
///
/// Maps the same 5 destinations as the mobile BottomNavigationBar,
/// but replaces the empty FAB-placeholder index (2) with the Team item.
class SidebarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserModel? userModel;
  final bool collapsed;

  const SidebarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userModel,
    this.collapsed = false,
  });

  // Desktop sidebar uses its own sequential indices (0-4) which map
  // to the same AppCubit indices used by the mobile bottom nav.
  // Index 2 on mobile is the FAB placeholder (SizedBox); on the sidebar
  // we show Team there instead.
  static List<_SidebarItem> _getItems(BuildContext context) => [
    _SidebarItem(
      icon: IconBroken.Home,
      label: S.of(context).navHome,
      layoutIndex: 0,
    ),
    _SidebarItem(
      icon: IconBroken.Calendar,
      label: S.of(context).navLeave,
      layoutIndex: 1,
    ),
    _SidebarItem(
      icon: IconBroken.User,
      label: S.of(context).navTeam,
      layoutIndex: 2,
    ),
    _SidebarItem(
      icon: IconBroken.Wallet,
      label: S.of(context).navPayroll,
      layoutIndex: 3,
    ),
    _SidebarItem(
      icon: IconBroken.Profile,
      label: S.of(context).navProfile,
      layoutIndex: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = collapsed ? 72.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sideDrawerBg,
        border: Border(
          right: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Brand / logo area ──
          _buildHeader(context),

          const SizedBox(height: 32),

          // ── Nav items ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _getItems(context).length,
              itemBuilder: (context, index) {
                final item = _getItems(context)[index];
                final isSelected = currentIndex == item.layoutIndex;
                return _buildNavTile(context, item, isSelected);
              },
            ),
          ),

          // ── User info footer ──
          if (!collapsed && userModel != null) _buildFooter(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    if (collapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(IconBroken.Activity, color: AppColors.primary, size: 28),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              IconBroken.Activity,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Pulsera',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav tile ────────────────────────────────────────────────────────────────

  Widget _buildNavTile(
    BuildContext context,
    _SidebarItem item,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppColors.sideDrawerSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(item.layoutIndex),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: collapsed ? 0 : 16,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.grey700,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    final name = '${userModel?.firstName ?? ''} ${userModel?.lastName ?? ''}'
        .trim();
    final role = userModel?.userType ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        // We moved the color and border radius to the Material widget
        color: AppColors.sideDrawerSelected,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          // Notice the () added below!
          onTap: () => navigateTo(context, const ProfileDetailsScreen()),
          child: Padding(
            // We moved the padding inside the InkWell so the ripple covers the whole box
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : S.of(context).user,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (role.isNotEmpty)
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── User avatar ─────────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    if (userModel?.image != null && userModel!.image!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(userModel!.image!),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        (userModel?.firstName ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Internal model for sidebar navigation items.
class _SidebarItem {
  final IconData icon;
  final String label;

  /// The index used by [AppCubit.changeIndex].
  final int layoutIndex;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.layoutIndex,
  });
}
