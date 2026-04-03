// import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:pulsera/models/company_model.dart';
// import 'package:pulsera/shared/components/components.dart';
// import 'package:pulsera/shared/components/helper_functions.dart';
// import 'package:pulsera/shared/cubit/app_cubit.dart';
// import 'package:pulsera/shared/cubit/profile_cubit.dart';
// import 'package:pulsera/shared/cubit/register_cubit.dart';
// import 'package:pulsera/shared/cubit/states.dart';
// import 'package:pulsera/shared/styles/colors.dart';
// import 'package:pulsera/shared/styles/icon_broken.dart';
//
// class CompanyDetailsScreen extends StatefulWidget {
//   const CompanyDetailsScreen({super.key});
//
//   @override
//   State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
// }
//
// class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeCompanyData();
//     });
//   }
//
//   void _initializeCompanyData() {
//     final company = AppCubit.get(context).companyModel;
//     final profileCubit = ProfileCubit.get(context);
//     final registerCubit = RegisterCubit.get(context);
//
//     if (company != null) {
//       profileCubit.organizationTC.text = company.organizationName ?? '';
//
//       if (company.startTime != null) {
//         registerCubit.startTime = parseTimeOfDay(company.startTime!);
//       }
//       if (company.endTime != null) {
//         registerCubit.endTime = parseTimeOfDay(company.endTime!);
//       }
//
//       if (company.workingDays != null) {
//         for (var day in registerCubit.workingDaysList) {
//           day.isSelected = company.workingDays!.contains(day.code);
//         }
//       }
//       if (mounted) setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CompanyModel? company = AppCubit.get(context).companyModel;
//     ProfileCubit profileCubit = ProfileCubit.get(context);
//     RegisterCubit registerCubit = RegisterCubit.get(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(IconBroken.Arrow___Left_2),
//         ),
//         title: Text(
//           "Organization Details",
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         elevation: 0,
//       ),
//       body: company == null
//           ? const Center(child: CircularProgressIndicator())
//           : MultiBlocListener(
//               listeners: [
//                 BlocListener<ProfileCubit, ProfileStates>(
//                   listener: (context, state) {
//                     if (state is UpdateCompanySuccessState) {
//                       AppCubit.get(context).getCompanyData(); // Sync local data
//                       Fluttertoast.showToast(
//                         msg: "Organization Details Updated",
//                         backgroundColor: Colors.green,
//                       );
//                       Navigator.pop(context); // Go back to settings menu
//                     }
//                     if (state is UpdateCompanyErrorState) {
//                       Fluttertoast.showToast(
//                         msg: state.error,
//                         backgroundColor: Colors.red,
//                       );
//                     }
//                   },
//                 ),
//               ],
//               child: BlocBuilder<RegisterCubit, RegisterStates>(
//                 builder: (context, state) {
//                   return ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       DefaultFormField(
//                         type: TextInputType.name,
//                         label: const Text("Organization Name"),
//                         prefix: IconBroken.User1,
//                         controller: profileCubit.organizationTC,
//                       ),
//                       const SizedBox(height: 16),
//                       // Start Time Button
//                       AppButton.appOulineButtonRow(
//                         context: context,
//                         onPressed: () => registerCubit.openTimePicker(
//                           isStart: true,
//                           context: context,
//                         ),
//                         label: registerCubit.startTime == null
//                             ? "Select start time"
//                             : formatTimeOfDay(registerCubit.startTime!),
//                         suffixIcon: const Icon(
//                           size: 22,
//                           Icons.access_time_outlined,
//                           color: AppColors.blue600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // End Time Button
//                       AppButton.appOulineButtonRow(
//                         context: context,
//                         onPressed: () => registerCubit.openTimePicker(
//                           isStart: false,
//                           context: context,
//                         ),
//                         label: registerCubit.endTime == null
//                             ? "Select end time"
//                             : formatTimeOfDay(registerCubit.endTime!),
//                         suffixIcon: const Icon(
//                           size: 22,
//                           Icons.access_time_outlined,
//                           color: AppColors.blue600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         width: double.maxFinite,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: AppColors.grey100,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Wrap(
//                           spacing: 10,
//                           runSpacing: 15,
//                           children: List.generate(
//                             registerCubit.workingDaysList.length,
//                             (index) => ChoiceChip(
//                               label: Text(
//                                 registerCubit.workingDaysList[index].label,
//                                 style: TextStyle(
//                                   color:
//                                       registerCubit
//                                           .workingDaysList[index]
//                                           .isSelected
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                               selected: registerCubit
//                                   .workingDaysList[index]
//                                   .isSelected,
//                               selectedColor: AppColors.blue600,
//                               onSelected: (value) =>
//                                   registerCubit.onWorkingDaysChange(index),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       BlocBuilder<ProfileCubit, ProfileStates>(
//                         builder: (context, profileState) {
//                           return ConditionalBuilder(
//                             condition:
//                                 profileState is! ProfileUpdateLoadingState,
//                             builder: (context) => SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   if (company.companyId != null) {
//                                     List<String> selectedCodes = registerCubit
//                                         .workingDaysList
//                                         .where((e) => e.isSelected)
//                                         .map((e) => e.code)
//                                         .toList();
//
//                                     await profileCubit.updateOrganization(
//                                       companyId: company.companyId!,
//                                       orgName: profileCubit.organizationTC.text,
//                                       startTime: registerCubit.startTime,
//                                       endTime: registerCubit.endTime,
//                                       workingDays: selectedCodes,
//                                     );
//                                   } else {
//                                     Fluttertoast.showToast(
//                                       msg: "Company ID not found",
//                                     );
//                                   }
//                                 },
//                                 child: const Text(
//                                   "Update Organization Details",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             fallback: (context) => const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/settings/edit_company_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';


class CompanyDetailsScreen extends StatelessWidget {
  const CompanyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        CompanyModel? company = AppCubit.get(context).companyModel;
        UserModel? user = AppCubit.get(context).userModel;

        if (company == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            leading: backButton(context),
            title: Text("Organization Details",style: Theme.of(context).textTheme.titleLarge,),
            elevation: 0,
            actions: [
              if(user?.userType == "Company Owner")
              Padding(
                padding: const EdgeInsetsDirectional.only(end:8.0),
                child: IconButton(
                  icon: const Icon(IconBroken.Edit,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  tooltip: "Edit Organization Details",
                  onPressed: () {
                    navigateTo(context, const EditCompanyScreen());
                  },
                ),
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              _buildInfoTile(
                icon: IconBroken.User1,
                title: "Organization Name",
                value: company.organizationName ?? 'Not provided',
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: Icons.access_time_outlined,
                title: "Working Hours",
                value: '${company.startTime ?? "00:00"}  to  ${company.endTime ?? "00:00"}',
              ),
              const Divider(height: 32),
              const Text(
                "Working Days",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (company.workingDays ?? []).map((dayCode) {
                  return Chip(
                    label: Text(dayCode),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}