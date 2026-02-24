import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../shared/cubit/app_cubit.dart';
import '../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);

        return ConditionalBuilder(
          condition: cubit.userModel != null,
          builder: (BuildContext context) {
            return Scaffold(
              appBar: cubit.appBars[cubit.currentIndex],
              body: cubit.screens[cubit.currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
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
                    icon: Icon(IconBroken.Wallet),
                    label: 'Payroll',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(IconBroken.Setting),
                    label: 'Settings',
                  ),
                ],
              ),
            );
          },
          fallback: (BuildContext context) =>
              Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
