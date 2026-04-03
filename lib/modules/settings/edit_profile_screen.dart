import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  void _initializeUserData() {
    final user = AppCubit.get(context).userModel;
    final profileCubit = ProfileCubit.get(context);

    if (user != null) {
      profileCubit.userNameTC.text = '${user.firstName} ${user.lastName}';
      profileCubit.emailTC.text = user.email ?? '';
      profileCubit.phoneTC.text = user.phone?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = AppCubit.get(context).userModel;
    ProfileCubit profileCubit = ProfileCubit.get(context);

    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text("Edit Profile",style: Theme.of(context).textTheme.titleLarge,),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : BlocConsumer<ProfileCubit, ProfileStates>(
        listener: (context, state) {
          if (state is ProfileErrorState) {
            Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
          }
          if (state is ProfileUpdateSuccessState) {
            AppCubit.get(context).getUserData();
            Fluttertoast.showToast(
              msg: "Profile Updated Successfully",
              backgroundColor: Colors.green,
            );
            Navigator.pop(context); // Go back to view screen
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DefaultFormField(
                controller: profileCubit.userNameTC,
                type: TextInputType.text,
                label: const Text("UserName"),
                validator: (String? value) {
                  if (value == null || value.isEmpty) return "This field can't be empty";
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
                  if (value == null || value.isEmpty) return "This field can't be empty";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DefaultFormField(
                controller: profileCubit.phoneTC,
                type: TextInputType.text,
                label: const Text("Phone Number"),
                validator: (String? value) {
                  if (value == null || value.isEmpty) return "This field can't be empty";
                  return null;
                },
                prefix: IconBroken.Call,
              ),
              const SizedBox(height: 32),
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
                      "Save Changes",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                fallback: (context) => const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        },
      ),
    );
  }
}