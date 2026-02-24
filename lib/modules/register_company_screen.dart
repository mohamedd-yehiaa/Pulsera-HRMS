import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/login_screen.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import '../shared/components/components.dart';
import '../shared/components/helper_functions.dart';
import '../shared/cubit/profile_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    ProfileCubit profileCubit = ProfileCubit.get(context);
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is CreateCompanyErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is CreateCompanySuccessState) {
            navigateAndFinish(context, HomeLayout());
          }
        },
        builder: (context, state) {
          RegisterCubit cubit = RegisterCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Organization Setup'),
              leading: IconButton(
                onPressed: () => Navigator.pop(context) ,
                icon: const Icon(IconBroken.Arrow___Left, color: AppColors.primary),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title using your helper function
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Organization Details",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.people_alt_outlined,
                              size: 20,
                              color: AppColors.blue600,
                            )
                          ],
                        ),
                        const SizedBox(height: 16.0),

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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          label: const Text('Per Month Paid Leave'),
                          prefix: IconBroken.Document,
                        ),
                        const SizedBox(height: 16.0),

                        // Per Month Sick/Casual Leave
                        DefaultFormField(
                          controller: casualSickTC,
                          type: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          label: const Text('Per Month Sick/Casual Leave'),
                          prefix: IconBroken.Info_Square,
                        ),
                        const SizedBox(height: 16.0),

                        // Per Month Work From Home
                        DefaultFormField(
                          controller: wfhTC,
                          type: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          label: const Text('Per Month Work From Home'),
                          prefix: IconBroken.Home,
                        ),
                        const SizedBox(height: 16.0),

                        // Start Time Picker Button
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () => profileCubit.openTimePickerdialog(isStart: true, context: context),
                          label: profileCubit.startTime == null
                              ? "Select start time"
                              : formatTimeOfDay(profileCubit.startTime!),
                          suffixIcon: const Icon(
                            Icons.access_time_outlined,
                            color: AppColors.blue500,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // End Time Picker Button
                        AppButton.appOulineButtonRow(
                          onPressed: () => profileCubit.openTimePickerdialog(isStart: false, context: context),
                          label: profileCubit.endTime == null
                              ? "Select end time"
                              : formatTimeOfDay(profileCubit.endTime!),
                          suffixIcon: const Icon(
                            Icons.access_time_outlined,
                            color: AppColors.blue500,
                          ), context: context,
                        ),
                        const SizedBox(height: 30.0),

                        // Final Registration Button
                        ConditionalBuilder(
                          condition: state is! RegisterLoadingState,
                          builder: (context) => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
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
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          fallback: (context) => const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
