import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/modules/register_company_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import '../models/user_model.dart';
import '../shared/components/swipe_button.dart';
import '../shared/components/user_activity_view.dart';
import '../shared/cubit/app_cubit.dart';
import '../shared/cubit/attendance_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/icon_broken.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = AppCubit.get(context).userModel;

    return BlocConsumer<AttendanceCubit, AttendanceStates>(
      listener: (context, state) {
        if (state is AttendanceErrorState) {
          Fluttertoast.showToast(msg: state.error);
        }
        if (state is AttendanceLoadingState) {
          Center(child: CircularProgressIndicator());
        }
      },

      builder: (context, state) {
        AttendanceCubit cubit = AttendanceCubit.get(context);
        if (user?.companyId == null && user?.userType == "Company Owner") {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Plaese Register your Company Details!",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(fontFamily: "Jannah"),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () =>
                        navigateTo(context, RegisterCompanyScreen()),
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Text(
                      "Create Company",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (user?.companyId == null && user?.userType == "Employee") {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please join a company to continue!",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontFamily: "Jannah",
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        "Give your Id to the company",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontFamily: "Jannah",
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          SelectableText(
                            "${user?.uId}",
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontFamily: "Jannah",
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 17,
                                ),
                          ),
                          SizedBox(width: 2),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                new ClipboardData(text: "${user?.uId}"),
                              ).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied to your clipboard !'),
                                  ),
                                );
                              });
                            },
                            icon: Icon(IconBroken.Paper,size: 22,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildDatePicker(cubit, user?.uId),
              const SizedBox(height: 28),

              _buildSectionHeader("Today Attendance", state),
              const SizedBox(height: 16),
              _buildCheckInOutGrid(cubit),
              const SizedBox(height: 12),
              _buildStatsGrid(cubit),

              if (cubit.workingTime != "00:00:00") _buildWorkingTimeCard(cubit),

              const SizedBox(height: 28),
              _buildSectionHeader("Your Activity", null),
              const SizedBox(height: 16),

              _buildSwipeButton(cubit, user?.uId),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: UserActivityView(userActivityModel: cubit.activity),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Date Picker Section ---
Widget _buildDatePicker(AttendanceCubit cubit, String? uid) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: HorizontalDate(
      fromDate: DateTime.now(),
      toDate: DateTime.now().subtract(const Duration(days: 10)),
      selectedDate: cubit.selectedDate,
      onTap: (newDate) {
        if (uid != null) cubit.changeDate(newDate, uid);
      },
    ),
  );
}

// --- Grids & Cards ---
Widget _buildCheckInOutGrid(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Check In",
            cubit.activity?.checkIn?.inTime ?? "--:--",
            IconBroken.Login,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            "Check Out",
            cubit.activity?.outTime?.outTime ?? "--:--",
            IconBroken.Logout,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatsGrid(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _buildInfoCard("Break Time", "00:00", Icons.coffee_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard("Total Days", "21", IconBroken.Calendar),
        ),
      ],
    ),
  );
}

Widget _buildWorkingTimeCard(AttendanceCubit cubit) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: _buildInfoCard(
      "Working Hours",
      cubit.workingTime,
      Icons.timer_outlined,
    ),
  );
}

// --- Swipe Button Logic ---
Widget _buildSwipeButton(AttendanceCubit cubit, String? uid) {
  final isToday = DateUtils.isSameDay(cubit.selectedDate, DateTime.now());

  if (!isToday || cubit.activity?.outTime != null) return const SizedBox();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SwipeButton.expand(
      thumb: const Icon(
        IconBroken.Arrow___Right_2,
        size: 35,
        color: AppColors.white,
      ),
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withAlpha(430),
      inactiveThumbColor: AppColors.grey300,
      onSwipe: () {
        if (uid != null) cubit.performSwipeAction(uid, "COMPANY_ID_HERE");
      },
      child: Text(
        cubit.activity?.nextAction.label ?? "Check In",
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}

// --- Helper Methods ---
Widget _buildSectionHeader(String title, AttendanceStates? state) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (state is AttendanceChangeDateState)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
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
        Text(title, style: TextStyle(color: AppColors.grey700, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
