// import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:pulsera/models/user_model.dart';
// import 'package:pulsera/shared/components/components.dart';
// import 'package:pulsera/shared/cubit/app_cubit.dart';
// import 'package:pulsera/shared/cubit/profile_cubit.dart';
// import 'package:pulsera/shared/cubit/states.dart';
// import 'package:pulsera/shared/styles/icon_broken.dart';
//
// class ProfileDetailsScreen extends StatefulWidget {
//   const ProfileDetailsScreen({super.key});
//
//   @override
//   State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
// }
//
// class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeUserData();
//     });
//   }
//
//   void _initializeUserData() {
//     final user = AppCubit.get(context).userModel;
//     final profileCubit = ProfileCubit.get(context);
//
//     if (user != null) {
//       profileCubit.userNameTC.text = '${user.firstName} ${user.lastName}';
//       profileCubit.emailTC.text = user.email ?? '';
//       profileCubit.phoneTC.text = user.phone?.toString() ?? '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     UserModel? user = AppCubit.get(context).userModel;
//     ProfileCubit profileCubit = ProfileCubit.get(context);
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
//           "My Profile",
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         elevation: 0,
//       ),
//       body: user == null
//           ? const Center(child: CircularProgressIndicator())
//           : BlocConsumer<ProfileCubit, ProfileStates>(
//               listener: (context, state) {
//                 if (state is ProfileErrorState) {
//                   Fluttertoast.showToast(
//                     msg: state.error,
//                     backgroundColor: Colors.red,
//                   );
//                 }
//                 if (state is ProfileUpdateSuccessState) {
//                   AppCubit.get(context).getUserData(); // Sync local data
//                   Fluttertoast.showToast(
//                     msg: "Profile Updated Successfully",
//                     backgroundColor: Colors.green,
//                   );
//                   Navigator.pop(context); // Go back to settings menu
//                 }
//               },
//               builder: (context, state) {
//                 return ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     DefaultFormField(
//                       controller: profileCubit.userNameTC,
//                       type: TextInputType.text,
//                       label: const Text("UserName"),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return "This field can't be empty";
//                         }
//                         return null;
//                       },
//                       prefix: IconBroken.User,
//                     ),
//                     const SizedBox(height: 16),
//                     DefaultFormField(
//                       controller: profileCubit.emailTC,
//                       type: TextInputType.text,
//                       label: const Text("Email"),
//                       prefix: IconBroken.Message,
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return "This field can't be empty";
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     DefaultFormField(
//                       controller: profileCubit.phoneTC,
//                       type: TextInputType.text,
//                       label: const Text("Phone Number"),
//                       validator: (String? value) {
//                         if (value == null || value.isEmpty) {
//                           return "This field can't be empty";
//                         }
//                         return null;
//                       },
//                       prefix: IconBroken.Call,
//                     ),
//                     const SizedBox(height: 32),
//                     ConditionalBuilder(
//                       condition: state is! ProfileLoadingState,
//                       builder: (context) => SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await profileCubit.updateProfile(user.uId);
//                           },
//                           child: const Text(
//                             "Update Profile",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       fallback: (context) =>
//                           const Center(child: CircularProgressIndicator()),
//                     ),
//                   ],
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

// Import your new edit screen here
import 'edit_profile_screen.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        UserModel? user = AppCubit.get(context).userModel;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: backButton(context),
            title: Text(
              "Personal Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8.0),
                child: IconButton(
                  icon: const Icon(
                    IconBroken.Edit,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  tooltip: "Edit Profile",
                  onPressed: () {
                    navigateTo(context, const EditProfileScreen());
                  },
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              _buildInfoTile(
                icon: IconBroken.User,
                title: "Full Name",
                value: '${user.firstName} ${user.lastName}',
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: IconBroken.Message,
                title: "Email Address",
                value: user.email ?? 'Not provided',
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: IconBroken.Call,
                title: "Phone Number",
                value: user.phone?.toString() ?? 'Not provided',
              ),
            ],
          ),
        );
      },
    );
  }

  // A helper widget to make the read-only view look clean
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
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
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
