import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/modules/team/team_members_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';


class HomeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterCubit, RegisterStates>(
          listener: (context, state) {
            if (state is CreateUserSuccessState) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
            }
          },
        ),
        BlocListener<AuthCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
            }
          },
        ),
      ],

      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);

          return ConditionalBuilder(
            condition: cubit.userModel != null,
            builder: (BuildContext context) {
              return Scaffold(
                appBar: cubit.appBars[cubit.currentIndex],
                body: cubit.screens[cubit.currentIndex],
                floatingActionButton: SizedBox(
                      width: 60, // Increase this for a larger button (Default is 56)
                      height: 60,
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    onPressed: () => navigateTo(context, TeamMembersScreen()),
                    child: const Icon(IconBroken.User, color:AppColors.white,),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar:
                BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 10.0,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.zero,
                  color: Colors.transparent,
                  child:
                  BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    currentIndex: cubit.currentIndex,
                    onTap: (index) {
                      if (index != 2) cubit.changeIndex(index);
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Calendar),
                        label: 'Leave',
                      ),
                      BottomNavigationBarItem(
                          icon: SizedBox(width: 5),
                          label: ''),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Wallet),
                        label: 'Payroll',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(IconBroken.Setting),
                        label: 'Settings',
                      ),
                    ],
                  ),
                )
              );
            },
            fallback: (BuildContext context) =>
                Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
