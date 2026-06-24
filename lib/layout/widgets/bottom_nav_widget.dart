import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/modules/team/team_members_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

/// Mobile-only bottom navigation bar with the center-docked Team FAB notch.
///
/// Extracted from HomeLayout to keep the layout file lean.
class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1A1D72F2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        color: AppColors.grey50,
        child: BottomNavigationBar(
          backgroundColor: AppColors.grey50,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index != 2) onTap(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(IconBroken.Home),
              label: S.of(context).navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(IconBroken.Calendar),
              label: S.of(context).navLeave,
            ),
            const BottomNavigationBarItem(icon: SizedBox(width: 5), label: ''),
            BottomNavigationBarItem(
              icon: const Icon(IconBroken.Wallet),
              label: S.of(context).navPayroll,
            ),
            BottomNavigationBarItem(
              icon: const Icon(IconBroken.Profile),
              label: S.of(context).navProfile,
            ),
          ],
        ),
      ),
    );
  }

  /// The center-docked FAB that sits above the bottom nav notch.
  ///
  /// Call this from the Scaffold's `floatingActionButton` parameter.
  static Widget buildFab(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF60A5FA), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4D1D72F2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => navigateTo(context, const TeamMembersScreen()),
        child: const Icon(IconBroken.User, color: AppColors.white),
      ),
    );
  }
}
