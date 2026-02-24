import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import '../models/user_model.dart';
import '../shared/components/components.dart';
import '../shared/components/helper_functions.dart';
import '../shared/cubit/profile_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/network/local/cache_helper.dart';
import '../shared/styles/colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the user model from your global AppCubit
    final UserModel? user = AppCubit.get(context).userModel;
    ProfileCubit cubit = ProfileCubit.get(context);


    // Safety check if user isn't loaded yet
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider(
      create: (context) => ProfileCubit()..initProfileData(user),
      child: BlocConsumer<ProfileCubit, ProfileStates>(
        listener: (context, state) {
          if (state is ProfileSuccessState) {
            Fluttertoast.showToast(
              msg: "Organization Updated Successfully",
              backgroundColor: Colors.green,
            );
          }
          if (state is ProfileErrorState) {
            Fluttertoast.showToast(
              msg: state.error,
              backgroundColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          var cubit = ProfileCubit.get(context);

          if (state is ProfileLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 24),
              title(context, "User Details", Icons.person),
              const SizedBox(height: 24),
              DefaultFormField(
                controller: cubit.userNameTC,
                type: TextInputType.text,
                label: const Text("UserName"),
                prefix: Icons.person,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => showResetPasswordDialog(context, cubit),
                child: const Text("Update Password"),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  CacheHelper.removeData(key: 'uId').then((value) {
                    // Standard Flutter navigation
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                    );
                  });
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Log out"),
              ),

              if (user.userType == 'Company Owner') ...[
                const SizedBox(height: 36),
                organizationDetails(context, cubit, user),
              ],
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget organizationDetails(BuildContext context, ProfileCubit cubit, UserModel user) {
    return Column(
      children: [
        title(context, "Organization Details", Icons.people_alt_outlined),
        const SizedBox(height: 16),
        DefaultFormField(
          type: TextInputType.name,
          label: const Text("Organization Name"),
          prefix: Icons.people_alt_outlined,
          controller: cubit.organizationTC,
        ),
        const SizedBox(height: 16),
        AppButton.appOulineButtonRow(
          context: context,
          onPressed: () => openTimePickerdialog(true, context, cubit),
          label: cubit.startTime == null
              ? "Select start time"
              : formatTimeOfDay(cubit.startTime!),
          suffixIcon: const Icon(Icons.access_time_outlined, color: AppColors.blue600),
        ),
        const SizedBox(height: 16),
        AppButton.appOulineButtonRow(
          context: context,
          onPressed: () => openTimePickerdialog(false, context, cubit),
          label: cubit.endTime == null
              ? "Select end time"
              : formatTimeOfDay(cubit.endTime!),
          suffixIcon: const Icon(Icons.access_time_outlined, color: AppColors.blue600),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 15,
            children: List.generate(
              cubit.workingDays.length,
                  (index) => ChoiceChip(
                label: Text(
                  cubit.workingDays[index].label,
                  style: TextStyle(
                    color: cubit.workingDays[index].isSelected ? Colors.white : Colors.black,
                  ),
                ),
                selected: cubit.workingDays[index].isSelected,
                selectedColor: AppColors.blue600,
                onSelected: (value) => cubit.onWorkingDaysChange(index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => cubit.updateProfile(user.uId),
            child: const Text("Update Organization"),
          ),
        ),
      ],
    );
  }

  Widget title(BuildContext context, String name, IconData iconData) {
    return Row(
      children: [
        Text(name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 10),
        Icon(iconData, size: 20, color: AppColors.blue600)
      ],
    );
  }

  Future<void> openTimePickerdialog(bool isStartTime, BuildContext context, ProfileCubit cubit) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      if (isStartTime) {
        cubit.startTime = selectedTime;
      } else {
        cubit.endTime = selectedTime;
      }
      cubit.emit(ProfileUpdateWorkingDaysState());
    }
  }

  void showResetPasswordDialog(BuildContext context, ProfileCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: const Text("Enter your new password details."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}