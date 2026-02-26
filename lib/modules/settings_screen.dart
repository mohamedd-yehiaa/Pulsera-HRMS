import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import '../models/company_model.dart';
import '../models/user_model.dart';
import '../shared/components/components.dart';
import '../shared/components/helper_functions.dart';
import '../shared/cubit/settings_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/network/local/cache_helper.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/icon_broken.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? user = AppCubit.get(context).userModel;
    final CompanyModel? company = AppCubit.get(context).companyModel;
    ProfileCubit cubit = ProfileCubit.get(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider(
      create: (context) => ProfileCubit()..initProfileData(user),
      child: BlocConsumer<ProfileCubit, ProfileStates>(
        listener: (context, state) {
          if (state is ProfileUpdateLoadingState) {
            Center(child: CircularProgressIndicator());
          }
          if (state is ProfileUpdateSuccessState) {
            AppCubit.get(context).getUserData();
            AppCubit.get(context).getCompanyData();
            Fluttertoast.showToast(
              msg: "Profile Updated Successfully",
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
          cubit.userNameTC.text = '${user.firstName} ${user.lastName}';
          cubit.emailTC.text = user.email!;
          cubit.phoneTC.text = user.phone?.toString() ?? '';

          cubit.startTime = company?.startTime as TimeOfDay?;
          cubit.endTime = company?.endTime as TimeOfDay?;
          // if (company?.organizationName!=null) {
          //   cubit.organizationTC.text= company?.organizationName!!!!;
          // } else {
          //   cubit.organizationTC.text = '';
          // }

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
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This field can't be empty";
                  }
                  return null;
                },
                prefix: IconBroken.User,
              ),
              const SizedBox(height: 16),
              DefaultFormField(
                controller: cubit.emailTC,
                type: TextInputType.text,
                label: const Text("Email"),
                prefix: IconBroken.Message,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This field can't be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DefaultFormField(
                controller: cubit.phoneTC,
                type: TextInputType.text,
                label: const Text("Phone Number"),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "This field can't be empty";
                  }
                  return null;
                },
                prefix: IconBroken.Call,
              ),
              const SizedBox(height: 16),
              ConditionalBuilder(
                condition: state is! ProfileLoadingState,
                builder: (context) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.updateProfile(user.uId);
                    },
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),

              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  CacheHelper.removeData(key: 'uId').then((value) {
                    AppCubit.get(context).userModel = null;
                    AppCubit.get(context).companyModel = null;
                    AppCubit.get(context).changeIndex(0);
                  });
                  navigateAndFinish(context, LoginScreen());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Log out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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

  Widget organizationDetails(
    BuildContext context,
    ProfileCubit cubit,
    UserModel user,
  ) {
    return Expanded(
      child: Column(
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
            onPressed: () =>
                cubit.openTimePicker(isStart: false, context: context),
            label: cubit.startTime == null
                ? "Select start time"
                : formatTimeOfDay(cubit.startTime!),
            suffixIcon: const Icon(
              Icons.access_time_outlined,
              color: AppColors.blue600,
            ),
          ),
          const SizedBox(height: 16),
          AppButton.appOulineButtonRow(
            context: context,
            onPressed: () =>
                cubit.openTimePicker(isStart: true, context: context),
            label: cubit.endTime == null
                ? "Select end time"
                : formatTimeOfDay(cubit.endTime!),
            suffixIcon: const Icon(
              Icons.access_time_outlined,
              color: AppColors.blue600,
            ),
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
                      color: cubit.workingDays[index].isSelected
                          ? Colors.white
                          : Colors.black,
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
      ),
    );
  }
}
