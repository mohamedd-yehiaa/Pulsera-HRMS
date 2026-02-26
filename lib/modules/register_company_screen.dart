import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import '../shared/components/components.dart';
import '../shared/cubit/app_cubit.dart';
import '../shared/cubit/settings_cubit.dart';
import '../shared/cubit/register_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/icon_broken.dart';

class RegisterCompanyScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  // Controllers for HR details
  final organizationTC = TextEditingController();
  final paidLeaveTC = TextEditingController();
  final casualSickTC = TextEditingController();
  final wfhTC = TextEditingController();
  final startTimeTC = TextEditingController();
  final endTimeTC = TextEditingController();

  RegisterCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterStates>(
      listener: (context, state) {
        if (state is CreateCompanySuccessState) {
          AppCubit.get(context).getUserData();

          Fluttertoast.showToast(
            msg: 'Company Registered Successfully',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // 2. Navigate and clear the stack to prevent going back to registration
          navigateAndFinish(context, HomeLayout());
        }

        if (state is CreateCompanyErrorState) {
          Fluttertoast.showToast(
            msg: state.error,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        RegisterCubit cubit = RegisterCubit.get(context);
        ProfileCubit profileCubit = ProfileCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Organization Setup'),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                IconBroken.Arrow___Left,
                color: AppColors.primary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Organization Details",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.business_center_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),

                    // Organization Name
                    DefaultFormField(
                      controller: organizationTC,
                      type: TextInputType.text,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "This field can't be empty";
                        }
                        return null;
                      },
                      label: const Text('Organization Name'),
                      prefix: IconBroken.Work,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Paid Leave
                    DefaultFormField(
                      controller: paidLeaveTC,
                      type: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      label: const Text('Per Month Paid Leave'),
                      prefix: IconBroken.Document,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Sick/Casual Leave
                    DefaultFormField(
                      controller: casualSickTC,
                      type: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      label: const Text('Per Month Sick/Casual Leave'),
                      prefix: IconBroken.Info_Square,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Work From Home
                    DefaultFormField(
                      controller: wfhTC,
                      type: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      label: const Text('Per Month Work From Home'),
                      prefix: IconBroken.Home,
                    ),
                    const SizedBox(height: 16.0),

                    // Start Time Picker Button
                    AppButton.appOulineButtonRow(
                      context: context,
                      onPressed: () => profileCubit.openTimePicker(
                        isStart: true,
                        context: context,
                      ),

                      label: profileCubit.startTime == null
                          ? "Select start time"
                          : formatTimeOfDay(profileCubit.startTime!),
                      suffixIcon: const Icon(
                        IconBroken.Time_Circle,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      value: startTimeTC.text,
                    ),
                    const SizedBox(height: 16.0),

                    // End Time Picker Button
                    AppButton.appOulineButtonRow(
                      onPressed: () => profileCubit.openTimePicker(
                        isStart: false,
                        context: context,
                      ),
                      label: profileCubit.endTime == null
                          ? "Select end time"
                          : formatTimeOfDay(profileCubit.endTime!),
                      suffixIcon: const Icon(
                        IconBroken.Time_Circle,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      context: context,
                      value: endTimeTC.text,
                    ),
                    const SizedBox(height: 30.0),
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
                          workingDaysList.length,
                          (index) => ChoiceChip(
                            label: Text(
                              workingDaysList[index].label,
                              style: TextStyle(
                                color: workingDaysList[index].isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: workingDaysList[index].isSelected,
                            selectedColor: AppColors
                                .blue600, // Ensure this color exists in your theme
                            onSelected: (selected) {
                              ProfileCubit.get(
                                context,
                              ).onWorkingDaysChange(index);
                            },
                          ),
                        ),
                      ),
                    ),

                    // Final Registration Button
                    ConditionalBuilder(
                      condition: state is! CreateCompanyLoadingState,
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (profileCubit.startTime == null ||
                                  profileCubit.endTime == null) {
                                Fluttertoast.showToast(
                                  msg: "Please select working hours",
                                );
                                return;
                              }
                              cubit.registerCompany(
                                orgName: organizationTC.text,
                                paidLeave: paidLeaveTC.text,
                                sickLeave: casualSickTC.text,
                                wfhDays: wfhTC.text,
                                startTime: profileCubit.startTime,
                                endTime: profileCubit.endTime,
                                ownerId: FirebaseAuth.instance.currentUser!.uid,
                              );
                            }
                          },
                          child: const Text(
                            "Register Organization",
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
              ),
            ),
          ),
        );
      },
    );
  }
}
