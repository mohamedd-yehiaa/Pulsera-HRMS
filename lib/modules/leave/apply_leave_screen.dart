import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/apply_leave_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../../models/team_members_model.dart';

// class ApplyLeaveScreen extends StatelessWidget {
//   const ApplyLeaveScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Accessing global data from AppCubit to pass to the provider
//     var user = AppCubit.get(context).userModel;
//     var company = AppCubit.get(context).companyModel;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocProvider(
//         create: (context) => ApplyLeaveCubit()..fetchAllAdminMembers(
//           companyId: user?.companyId,
//           uId: user?.uId,
//         ),
//         child: BlocConsumer<ApplyLeaveCubit, AuthStates>(
//           listener: (context, state) {
//             if (state is AuthSuccessState) {
//               Fluttertoast.showToast(msg: "Leave Request Submitted");
//               Navigator.pop(context);
//             }
//             if (state is AuthErrorState) {
//               Fluttertoast.showToast(msg: state.error,);
//             }
//           },
//           builder: (context, state) {
//             var cubit = ApplyLeaveCubit.get(context);
//
//             return SafeArea(
//               child: Column(
//                 children: [
//                   // --- CUSTOM HEADER ---
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     child: Row(
//                       children: [
//                         title(context, "Apply Leave", IconBroken.Edit),
//                         const Spacer(),
//                         IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(Icons.close),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // --- FORM CONTENT ---
//                   Expanded(
//                     child: ListView(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       physics: const BouncingScrollPhysics(),
//                       children: [
//                         const SizedBox(height: 16),
//
//                         // Start Date Selection
//                         AppButton.appOulineButtonRow(
//                           context: context,
//                           onPressed: () => cubit.setDate(context, isStart: true),
//                           label: cubit.leaveStartDate == null
//                               ? "Select start date"
//                               : DateFormat('dd MMM yyyy').format(cubit.leaveStartDate!),
//                           suffixIcon: const Icon(IconBroken.Calendar, color: AppColors.blue600),
//                         ),
//                         const SizedBox(height: 16),
//
//                         // End Date Selection
//                         AppButton.appOulineButtonRow(
//                           context: context,
//                           onPressed: () => cubit.setDate(context, isStart: false),
//                           label: cubit.leaveEndDate == null
//                               ? "Select end date"
//                               : DateFormat('dd MMM yyyy').format(cubit.leaveEndDate!),
//                           suffixIcon: const Icon(IconBroken.Calendar, color: AppColors.blue600),
//                         ),
//
//                         const SizedBox(height: 24),
//
//                         // Reason Field (DefaultFormField inside Material/Scaffold now works)
//                         DefaultFormField(
//                           controller: cubit.leavereasonTC,
//                           type: TextInputType.multiline,
//                           label: const Text("Reason for leave"),
//                           prefix: IconBroken.Document,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) return "Please enter a reason";
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 24),
//
//                         const Text(
//                             "Select Approval Person",
//                             style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Jannah")
//                         ),
//                         const SizedBox(height: 8),
//
//                         // Admin Selection Dropdown (Corrected to use fullName and uId)
//                         if (cubit.isTeamLoading)
//                           const Center(child: CircularProgressIndicator())
//                         else if (cubit.adminMembers.isEmpty)
//                           const Text("No managers found in your company")
//                         else
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             decoration: BoxDecoration(
//                               color: AppColors.grey100,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<MembersData>(
//                                 isExpanded: true,
//                                 value: cubit.selectedAdmin,
//                                 items: cubit.adminMembers.map((e) => DropdownMenuItem(
//                                   value: e,
//                                   child: Text(e.fullName ?? "No Name"),
//                                 )).toList(),
//                                 onChanged: (value) => cubit.changeSelectedAdmin(value),
//                               ),
//                             ),
//                           ),
//
//                         const SizedBox(height: 40),
//
//                         // Submission Button
//                         ConditionalBuilder(
//                           condition: state is! AuthLoadingState,
//                           builder: (context) => SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 cubit.applyLeave(
//                                   uId: user?.uId,
//                                   companyId: user?.companyId,
//                                   userModel: user,
//                                 );
//                               },
//                               child: const Text(
//                                 "Submit Request",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16
//                                 ),
//                               ),
//                             ),
//                           ),
//                           fallback: (context) => const Center(child: CircularProgressIndicator()),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class ApplyLeaveScreen extends StatelessWidget {
  const ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = AppCubit.get(context).userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => ApplyLeaveCubit()..fetchAllAdminMembers(
          companyId: user?.companyId,
          uId: user?.uId,
        ),
        child: BlocConsumer<ApplyLeaveCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthSuccessState) {
              Fluttertoast.showToast(msg: "Leave Request Submitted",);
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            var cubit = ApplyLeaveCubit.get(context);

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        title(context, "Apply Leave", IconBroken.Edit),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 16),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () => cubit.setDate(context, isStart: true),
                          label: cubit.leaveStartDate == null
                              ? "Select start date"
                              : DateFormat('dd MMM yyyy').format(cubit.leaveStartDate!),
                          suffixIcon: const Icon(IconBroken.Calendar, color: AppColors.blue600),
                        ),
                        const SizedBox(height: 16),
                        AppButton.appOulineButtonRow(
                          context: context,
                          onPressed: () => cubit.setDate(context, isStart: false),
                          label: cubit.leaveEndDate == null
                              ? "Select end date"
                              : DateFormat('dd MMM yyyy').format(cubit.leaveEndDate!),
                          suffixIcon: const Icon(IconBroken.Calendar, color: AppColors.blue600),
                        ),
                        const SizedBox(height: 24),
                        DefaultFormField(
                          controller: cubit.leavereasonTC,
                          type: TextInputType.multiline,
                          label: const Text("Reason for leave"),
                          prefix: IconBroken.Document,
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 24),
                        // ... inside your ApplyLeaveScreen build method
                        const Text(
                            "Select Approval Person",
                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Jannah")
                        ),
                        const SizedBox(height: 8),

                        if (cubit.isTeamLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (cubit.adminMembers.isEmpty)
                        // This is what you are currently seeing
                          const Text("No managers found in your company", style: TextStyle(color: Colors.red))
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<MembersData>(
                                isExpanded: true,
                                value: cubit.selectedAdmin,
                                items: cubit.adminMembers.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.fullName ?? "No Name"),
                                )).toList(),
                                onChanged: (value) => cubit.changeSelectedAdmin(value),
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                        ConditionalBuilder(
                          condition: state is! AuthLoadingState,
                          builder: (context) => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => cubit.applyLeave(
                                uId: user?.uId,
                                companyId: user?.companyId,
                                userModel: user,
                              ),
                              child: const Text("Submit Request", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          fallback: (context) => const Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}