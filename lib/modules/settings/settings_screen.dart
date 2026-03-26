import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../../shared/components/components.dart';
import '../../shared/components/helper_functions.dart';
import '../../shared/cubit/profile_cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/network/local/cache_helper.dart';
import '../../shared/styles/colors.dart';
import '../../shared/styles/icon_broken.dart';
import '../login/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? user = AppCubit.get(context).userModel;
    CompanyModel? company = AppCubit.get(context).companyModel;
    ProfileCubit profileCubit = ProfileCubit.get(context);
    RegisterCubit registerCubit = RegisterCubit.get(context);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profileCubit.userNameTC.text.isEmpty) {
      profileCubit.userNameTC.text = '${user.firstName} ${user.lastName}';
      profileCubit.emailTC.text = user.email ?? '';
      profileCubit.phoneTC.text = user.phone?.toString() ?? '';
    }
    return BlocConsumer<ProfileCubit, ProfileStates>(
      listener: (context, state) {
        if (state is ProfileUpdateLoadingState) {
          Center(child: CircularProgressIndicator());
        }

        if (state is ProfileErrorState) {
          Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
        }
        if (state is ProfileUpdateSuccessState) {
          AppCubit.get(context).getUserData();

          Fluttertoast.showToast(
            msg: "Profile Updated Successfully",
            backgroundColor: Colors.green,
          );
        }
      },
      builder: (context, state) {
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
              builder: (context) => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await profileCubit.updateProfile(user.uId);
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
                  profileCubit.userNameTC.clear();
                  profileCubit.emailTC.clear();
                  profileCubit.phoneTC.clear();
                  registerCubit.endTimeTC.clear();
                  registerCubit.startTimeTC.clear();
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
              const SizedBox(height: 32),
              MultiBlocListener(
                listeners: [
                  BlocListener<ProfileCubit, ProfileStates>(
                    listener: (context, state) {
                      if (state is UpdateCompanySuccessState) {
                        AppCubit.get(
                          context,
                        ).getCompanyData(); // Sync local data
                        Fluttertoast.showToast(
                          msg: "Organization Details Updated",
                          backgroundColor: Colors.green,
                        );
                      }
                      if (state is UpdateCompanyErrorState) {
                        Fluttertoast.showToast(
                          msg: state.error,
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                  ),
                  BlocListener<RegisterCubit, RegisterStates>(
                    listener: (context, state) {},
                  ),
                ],
                child: BlocBuilder<RegisterCubit, RegisterStates>(
                  builder: (context, state) {
                    // Initialization Logic: Only runs if the field is empty to allow typing
                    if (profileCubit.organizationTC.text.isEmpty &&
                        company != null) {
                      profileCubit.organizationTC.text =
                          company.organizationName ?? '';
                      if (company.startTime != null) {
                        registerCubit.startTime = parseTimeOfDay(
                          company.startTime!,
                        );
                      }
                      if (company.endTime != null) {
                        registerCubit.endTime = parseTimeOfDay(
                          company.endTime!,
                        );
                      }
                      if (company.workingDays != null) {
                        for (var day in registerCubit.workingDaysList) {
                          day.isSelected = company.workingDays!.contains(
                            day.code,
                          );
                        }
                      }
                    }
                    return Column(
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
                          controller: profileCubit.organizationTC,
                        ),
                        const SizedBox(height: 16),
                        // Start Time Button
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () => registerCubit.openTimePicker(
                            isStart: true,
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
                        // End Time Button
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () => registerCubit.openTimePicker(
                            isStart: false,
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
                              (index) => ChoiceChip(
                                label: Text(
                                  registerCubit.workingDaysList[index].label,
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
                                    registerCubit.onWorkingDaysChange(index),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // We use another BlocBuilder here to listen to ProfileCubit Loading State
                        BlocBuilder<ProfileCubit, ProfileStates>(
                          builder: (context, profileState) {
                            return ConditionalBuilder(
                              condition:
                                  profileState is! ProfileUpdateLoadingState,
                              builder: (context) => SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async{
                                    if (company?.companyId != null) {
                                      List<String> selectedCodes = registerCubit
                                          .workingDaysList
                                          .where((e) => e.isSelected)
                                          .map((e) => e.code)
                                          .toList();

                                      await profileCubit.updateOrganization(
                                        companyId: company!.companyId!,
                                        orgName:
                                            profileCubit.organizationTC.text,
                                        startTime: registerCubit.startTime,
                                        endTime: registerCubit.endTime,
                                        workingDays: selectedCodes,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Company ID not found",
                                      );
                                    }
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
                              fallback: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}
