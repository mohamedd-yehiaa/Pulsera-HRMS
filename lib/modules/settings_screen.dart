import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import '../models/company_model.dart';
import '../models/user_model.dart';
import '../shared/components/components.dart';
import '../shared/components/helper_functions.dart';
import '../shared/cubit/profile_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/network/local/cache_helper.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/icon_broken.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? user = AppCubit
        .get(context)
        .userModel;
    final CompanyModel? company = AppCubit
        .get(context)
        .companyModel;

    ProfileCubit profileCubit = ProfileCubit.get(context);
    RegisterCubit registerCubit = RegisterCubit.get(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<ProfileCubit, ProfileStates>(
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
          Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
        }
      },
      builder: (context, state) {
        profileCubit.userNameTC.text = '${user.firstName} ${user.lastName}';
        profileCubit.emailTC.text = user.email!;
        profileCubit.phoneTC.text = user.phone?.toString() ?? '';

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 24),
            title(context, "User Details", IconBroken.Profile),
            const SizedBox(height: 24),
            DefaultFormField(
              controller: profileCubit.userNameTC,
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
              controller: profileCubit.emailTC,
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
              controller: profileCubit.phoneTC,
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
              builder: (context) =>
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        profileCubit.updateProfile(user.uId);
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
                  AppCubit
                      .get(context)
                      .userModel = null;
                  AppCubit
                      .get(context)
                      .companyModel = null;
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

            // organizationDetails----------------------------------------------
            if (user.userType == 'Company Owner') ...[
              const SizedBox(height: 36),
              BlocConsumer<RegisterCubit, RegisterStates>(
                listener: (context, state) {

                },
                builder: (context, state) {
                  if (company?.startTime != null) {
                    registerCubit.startTime = parseTimeOfDay(company!.startTime!);
                    registerCubit.startTimeTC.text = company.startTime!;
                  }

                  if (company?.endTime != null) {
                    registerCubit.endTime = parseTimeOfDay(company!.endTime!);
                    registerCubit.endTimeTC.text = company.endTime!;
                  }

                  profileCubit.organizationTC.text = company?.organizationName ?? '';

                  return Expanded(
                    child: Column(
                      children: [
                        title(
                          context,
                          "Organization Details",
                          IconBroken.User1,
                        ),
                        const SizedBox(height: 16),
                        DefaultFormField(
                          type: TextInputType.name,
                          label: const Text("Organization Name"),
                          prefix: IconBroken.User1,
                          controller: registerCubit.organizationTC,
                        ),
                        const SizedBox(height: 16),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () =>
                              registerCubit.openTimePicker(
                                isStart: false,
                                context: context,
                              ),
                          label: registerCubit.startTime == null
                              ? "Select start time"
                              : formatTimeOfDay(registerCubit.startTime!),
                          suffixIcon: const Icon(
                            size: 22,
                            Icons.access_time_outlined,
                            color: AppColors.blue600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () =>
                              registerCubit.openTimePicker(
                                isStart: true,
                                context: context,
                              ),
                          label: registerCubit.endTime == null
                              ? "Select end time"
                              : formatTimeOfDay(registerCubit.endTime!),
                          suffixIcon: const Icon(
                            size: 22,
                            Icons.access_time_outlined,
                            color: AppColors.blue600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 15,
                            children: List.generate(
                              registerCubit.workingDaysList.length,
                                  (index) =>
                                  ChoiceChip(
                                    label: Text(
                                      registerCubit.workingDaysList[index]
                                          .label,
                                      style: TextStyle(
                                        color:
                                        registerCubit
                                            .workingDaysList[index]
                                            .isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    selected: registerCubit
                                        .workingDaysList[index]
                                        .isSelected,
                                    selectedColor: AppColors.blue600,
                                    onSelected: (value) =>
                                        registerCubit.onWorkingDaysChange(
                                            index),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ConditionalBuilder(
                          condition: ProfileStates is! ProfileLoadingState,
                          builder: (context) =>
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    profileCubit.updateProfile(user.uId);
                                  },
                                  child: const Text(
                                    "Update Organization Details",
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
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}