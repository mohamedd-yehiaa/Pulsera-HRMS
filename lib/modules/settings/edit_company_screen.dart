import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class EditCompanyScreen extends StatefulWidget {
  const EditCompanyScreen({super.key});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCompanyData();
    });
  }

  void _initializeCompanyData() {
    final company = AppCubit.get(context).companyModel;
    final profileCubit = ProfileCubit.get(context);
    final registerCubit = RegisterCubit.get(context);

    if (company != null) {
      profileCubit.organizationTC.text = company.organizationName ?? '';

      if (company.startTime != null) {
        registerCubit.startTime = parseTimeOfDay(company.startTime!);
      }
      if (company.endTime != null) {
        registerCubit.endTime = parseTimeOfDay(company.endTime!);
      }

      if (company.workingDays != null) {
        for (var day in registerCubit.workingDaysList) {
          day.isSelected = company.workingDays!.contains(day.code);
        }
      }
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    CompanyModel? company = AppCubit.get(context).companyModel;
    ProfileCubit profileCubit = ProfileCubit.get(context);
    RegisterCubit registerCubit = RegisterCubit.get(context);

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text("Edit Organization", style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
      ),
      body: company == null
          ? const Center(child: CircularProgressIndicator())
          : MultiBlocListener(
        listeners: [
          BlocListener<ProfileCubit, ProfileStates>(
            listener: (context, state) {
              if (state is UpdateCompanySuccessState) {
                AppCubit.get(context).getCompanyData();
                Fluttertoast.showToast(msg: "Organization Details Updated", backgroundColor: Colors.green);
                Navigator.pop(context); // Go back to view screen
              }
              if (state is UpdateCompanyErrorState) {
                Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
              }
            },
          ),
        ],
        child: BlocBuilder<RegisterCubit, RegisterStates>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DefaultFormField(
                  type: TextInputType.name,
                  label: const Text("Organization Name"),
                  prefix: IconBroken.User1,
                  controller: profileCubit.organizationTC,
                ),
                const SizedBox(height: 16),
                AppButton.appOulineButtonRow(
                  context: context,
                  onPressed: () => registerCubit.openTimePicker(isStart: true, context: context),
                  label: registerCubit.startTime == null ? "Select start time" : formatTimeOfDay(registerCubit.startTime!),
                  suffixIcon: const Icon(size: 22, Icons.access_time_outlined, color: AppColors.blue600),
                ),
                const SizedBox(height: 16),
                AppButton.appOulineButtonRow(
                  context: context,
                  onPressed: () => registerCubit.openTimePicker(isStart: false, context: context),
                  label: registerCubit.endTime == null ? "Select end time" : formatTimeOfDay(registerCubit.endTime!),
                  suffixIcon: const Icon(size: 22, Icons.access_time_outlined, color: AppColors.blue600),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(12)),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 15,
                    children: List.generate(
                      registerCubit.workingDaysList.length,
                          (index) => ChoiceChip(
                        label: Text(
                          registerCubit.workingDaysList[index].label,
                          style: TextStyle(color: registerCubit.workingDaysList[index].isSelected ? Colors.white : Colors.black),
                        ),
                        selected: registerCubit.workingDaysList[index].isSelected,
                        selectedColor: AppColors.blue600,
                        onSelected: (value) => registerCubit.onWorkingDaysChange(index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ProfileCubit, ProfileStates>(
                  builder: (context, profileState) {
                    return ConditionalBuilder(
                      condition: profileState is! ProfileUpdateLoadingState,
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (company.companyId != null) {
                              List<String> selectedCodes = registerCubit.workingDaysList.where((e) => e.isSelected).map((e) => e.code).toList();
                              await profileCubit.updateOrganization(
                                companyId: company.companyId!,
                                orgName: profileCubit.organizationTC.text,
                                startTime: registerCubit.startTime,
                                endTime: registerCubit.endTime,
                                workingDays: selectedCodes,
                              );
                            } else {
                              Fluttertoast.showToast(msg: "Company ID not found");
                            }
                          },
                          child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      fallback: (context) => const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}