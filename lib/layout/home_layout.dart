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
import 'package:pulsera/modules/profile/profile_screen.dart';
import 'package:pulsera/modules/team/team_members_screen.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/utils/responsive_breakpoints.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

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

              // 1. Move _screens inside the builder so we can dynamically wrap the ProfileScreen
              final List<Widget> screens = [
                const HomeScreen(), // 0
                const LeaveScreen(), // 1
                const TeamMembersScreen(), // 2
                const PayrollScreen(), // 3

                // 4. We wrap ONLY the Profile screen in a NestedScrollView
                //    so its AppBar scrolls without touching ProfileScreen.dart
                isMobile
                    ? SafeArea( // SafeArea ensures it doesn't hide under the battery icon
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: HomeAppBars.forIndex(4, context, cubit),
                      ),
                    ],
                    body: const ProfileScreen(),
                  ),
                )
                    : const ProfileScreen(),
              ];

              return Scaffold(
                // 2. Show the normal, fixed AppBar for tabs 0, 1, 2, and 3.
                //    But hide it for tab 4, because our NestedScrollView is handling it above.
                appBar: (isMobile && cubit.currentIndex != 4)
                    ? HomeAppBars.forIndex(cubit.currentIndex, context, cubit)
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
                                children: screens, // 3. Use the dynamic screens list here
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