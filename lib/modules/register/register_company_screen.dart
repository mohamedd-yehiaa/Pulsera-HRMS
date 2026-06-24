import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/app_extension.dart';

class RegisterCompanyScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  // Controllers for HR details
  final organizationTC = TextEditingController();
  final paidLeaveTC = TextEditingController();
  final casualSickTC = TextEditingController();
  final wfhTC = TextEditingController();
  final startTimeTC = TextEditingController();
  final endTimeTC = TextEditingController();
  final gracePeriodTC = TextEditingController(text: '15');
  final earlyAllowanceTC = TextEditingController(text: '30');
  final lateCutoffTC = TextEditingController(text: '120');
  final minimumWorkHoursTC = TextEditingController(text: '6');

  RegisterCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterStates>(
      listener: (context, state) {
        if (state is CreateCompanySuccessState) {
          AppCubit.get(context).userModel?.companyId = state.companyId;
          AppCubit.get(context).getUserData();

          Fluttertoast.showToast(
            msg: S.of(context).companyRegisteredSuccessfully,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
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
        RegisterCubit registerCubit = RegisterCubit.get(context);
        ProfileCubit profileCubit = ProfileCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              S.of(context).organizationSetup,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Used your RTL-aware backButton helper instead of a hardcoded left arrow
            leading: backButton(context),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          S.of(context).organizationDetails,
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
                    const SizedBox(height: 20.0),

                    // Organization Name
                    DefaultFormField(
                      controller: organizationTC,
                      type: TextInputType.text,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return S.of(context).fieldCantBeEmpty;
                        }
                        return null;
                      },
                      label: Text(S.of(context).organizationName),
                      prefix: IconBroken.Work,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Paid Leave
                    DefaultFormField(
                      controller: paidLeaveTC,
                      type: TextInputType.number,
                      // FIX: Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).perMonthPaidLeave),
                      prefix: IconBroken.Document,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Sick/Casual Leave
                    DefaultFormField(
                      controller: casualSickTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).perMonthSickCasualLeave),
                      prefix: IconBroken.Info_Square,
                    ),
                    const SizedBox(height: 16.0),

                    // Per Month Work From Home
                    DefaultFormField(
                      controller: wfhTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).perMonthWorkFromHome),
                      prefix: IconBroken.Home,
                    ),
                    const SizedBox(height: 16.0),

                    // Start Time Picker Button
                    AppButton.appOulineButtonRow(
                      context: context,
                      onPressed: () => registerCubit.openTimePicker(
                        isStart: true,
                        context: context,
                      ),
                      // Chained .localizeDigits() to safely translate time strings
                      label: registerCubit.startTime == null
                          ? S.of(context).selectStartTime
                          : formatTimeOfDay(
                              registerCubit.startTime!,
                            ).localizeDigits(context),
                      suffixIcon: const Icon(
                        IconBroken.Time_Circle,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      value: profileCubit.startTimeTC.text,
                    ),
                    const SizedBox(height: 16.0),

                    // End Time Picker Button
                    AppButton.appOulineButtonRow(
                      onPressed: () => registerCubit.openTimePicker(
                        isStart: false,
                        context: context,
                      ),
                      // Chained .localizeDigits() to safely translate time strings
                      label: registerCubit.endTime == null
                          ? S.of(context).selectEndTime
                          : formatTimeOfDay(
                              registerCubit.endTime!,
                            ).localizeDigits(context),
                      suffixIcon: const Icon(
                        IconBroken.Time_Circle,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      context: context,
                      value: profileCubit.endTimeTC.text,
                    ),
                    const SizedBox(height: 20.0),
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
                              getLocalizedDay(context, registerCubit.workingDaysList[index].code),
                              style: TextStyle(
                                color:
                                    registerCubit
                                        .workingDaysList[index]
                                        .isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected:
                                registerCubit.workingDaysList[index].isSelected,
                            selectedColor: AppColors.blue600,
                            onSelected: (selected) {
                              registerCubit.onWorkingDaysChange(index);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Attendance Rules Section
                    Row(
                      children: [
                        Text(
                          S.of(context).attendanceRules,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.rule_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    DefaultFormField(
                      controller: gracePeriodTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).gracePeriodMinutes),
                      prefix: IconBroken.Time_Circle,
                    ),
                    const SizedBox(height: 16.0),

                    DefaultFormField(
                      controller: earlyAllowanceTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).earlyCheckInAllowance),
                      prefix: IconBroken.Time_Circle,
                    ),
                    const SizedBox(height: 16.0),

                    DefaultFormField(
                      controller: lateCutoffTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).lateCutoffMinutes),
                      prefix: IconBroken.Time_Circle,
                    ),
                    const SizedBox(height: 16.0),

                    DefaultFormField(
                      controller: minimumWorkHoursTC,
                      type: TextInputType.number,
                      // Allowed Arabic digits
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      label: Text(S.of(context).minimumWorkHours),
                      prefix: IconBroken.Time_Circle,
                    ),
                    const SizedBox(height: 16.0),

                    // Final Registration Button
                    ConditionalBuilder(
                      condition: state is! CreateCompanyLoadingState,
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (registerCubit.startTime == null ||
                                  registerCubit.endTime == null) {
                                Fluttertoast.showToast(
                                  msg: S.of(context).pleaseSelectWorkingHours,
                                );
                                return;
                              }
                              registerCubit.registerCompany(
                                orgName: organizationTC.text,
                                // Sanitized all fields to strictly English digits before sending to backend
                                paidLeave: paidLeaveTC.text.toEnglishDigits(),
                                sickLeave: casualSickTC.text.toEnglishDigits(),
                                wfhDays: wfhTC.text.toEnglishDigits(),
                                startTime: registerCubit.startTime,
                                endTime: registerCubit.endTime,
                                workingDaysList: registerCubit.workingDaysList,
                                ownerId: FirebaseAuth.instance.currentUser!.uid,
                                gracePeriodMinutes:
                                    int.tryParse(
                                      gracePeriodTC.text.toEnglishDigits(),
                                    ) ??
                                    15,
                                earlyAllowanceMinutes:
                                    int.tryParse(
                                      earlyAllowanceTC.text.toEnglishDigits(),
                                    ) ??
                                    30,
                                lateCutoffMinutes:
                                    int.tryParse(
                                      lateCutoffTC.text.toEnglishDigits(),
                                    ) ??
                                    120,
                                minimumWorkHours:
                                    int.tryParse(
                                      minimumWorkHoursTC.text.toEnglishDigits(),
                                    ) ??
                                    6,
                              );
                            }
                          },
                          child: Text(
                            S.of(context).registerOrganization,
                            style: const TextStyle(
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
