import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/layout/widgets/bottom_nav_widget.dart';
import 'package:pulsera/layout/widgets/home_app_bars.dart';
import 'package:pulsera/layout/widgets/home_bloc_listeners.dart';
import 'package:pulsera/layout/widgets/sidebar_widget.dart';
import 'package:pulsera/layout/widgets/top_bar_widget.dart';
import 'package:pulsera/modules/home/home_screen.dart';
import 'package:pulsera/modules/leave/leave_screen.dart';
import 'package:pulsera/modules/payroll/payroll_screen.dart';
import 'package:pulsera/modules/settings/settings_screen.dart';
import 'package:pulsera/modules/team/team_members_screen.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/utils/responsive_breakpoints.dart';

/// Root layout of the authenticated app.
///
/// Responsibilities (and nothing more):
/// - Scaffold with responsive navigation (bottom nav / sidebar / top bar)
/// - Switching between screens via [IndexedStack]
///
/// All business-logic reactions live in [HomeBlocListeners].
/// All per-tab AppBars live in [HomeAppBars].
class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  /// The screens displayed in the body — order matches AppCubit.currentIndex.
  /// Index 2 is the Team screen (on desktop/tablet) or a no-op placeholder
  /// (on mobile, where the FAB navigates to TeamMembersScreen via push).
  static const List<Widget> _screens = [
    HomeScreen(), // 0
    LeaveScreen(), // 1
    TeamMembersScreen(), // 2  (sidebar only — mobile uses FAB push)
    PayrollScreen(), // 3
    SettingsScreen(), // 4
  ];

  @override
  Widget build(BuildContext context) {
    return HomeBlocListeners(
      child: BlocBuilder<AppCubit, AppStates>(
        builder: (BuildContext context, AppStates state) {
          final AppCubit cubit = AppCubit.get(context);

          return ConditionalBuilder(
            condition: cubit.userModel != null,
            builder: (BuildContext context) {
              final isMobile = Breakpoints.isMobile(context);
              final isDesktop = Breakpoints.isDesktop(context);
              final isTablet = Breakpoints.isTablet(context);

              return Scaffold(
                // AppBar only on mobile — desktop/tablet use TopBarWidget
                appBar: isMobile
                    ? HomeAppBars.forIndex(
                        cubit.currentIndex,
                        context,
                        cubit,
                      )
                    : null,

                body: Row(
                  children: [
                    // ── Sidebar (desktop = expanded, tablet = collapsed) ──
                    if (!isMobile)
                      SidebarWidget(
                        currentIndex: cubit.currentIndex,
                        onTap: (index) => cubit.changeIndex(index),
                        userModel: cubit.userModel,
                        collapsed: isTablet,
                      ),

                    // ── Main content area ──
                    Expanded(
                      child: Column(
                        children: [
                          // Top bar on tablet / desktop
                          if (!isMobile)
                            TopBarWidget(
                              currentIndex: cubit.currentIndex,
                              cubit: cubit,
                            ),

                          // Body with consistent padding
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 8.0 : 0.0,
                              ),
                              child: IndexedStack(
                                index: cubit.currentIndex,
                                children: _screens,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── FAB (mobile only) ──
                floatingActionButton: isMobile
                    ? BottomNavWidget.buildFab(context)
                    : null,
                floatingActionButtonLocation: isMobile
                    ? FloatingActionButtonLocation.centerDocked
                    : null,

                // ── Bottom nav (mobile only) ──
                bottomNavigationBar: isMobile
                    ? BottomNavWidget(
                        currentIndex: cubit.currentIndex,
                        onTap: (index) => cubit.changeIndex(index),
                      )
                    : null,
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
