import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/modules/settings/company_details_screen.dart';
import 'package:pulsera/modules/settings/edit_profile_screen.dart';
import 'package:pulsera/modules/settings/generate_qr_code_screen.dart';
import 'package:pulsera/modules/settings/kiosk_account_section.dart';
import 'package:pulsera/modules/settings/profile_details_screen.dart';
import 'package:pulsera/modules/settings/profile_header_widget.dart';
import 'package:pulsera/modules/settings/profile_menu_item_widget.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to AppCubit for User Data changes
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, appState) {
        var appCubit = AppCubit.get(context);
        UserModel? user = appCubit.userModel;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Listen to ProfileCubit for local Image Picking states
              BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, profileState) {
                  var profileCubit = ProfileCubit.get(context);

                  return ProfileHeaderWidget(
                    userModel: user,
                    // Pass the locally picked file for instant preview
                    pickedImage: profileCubit.profileImage,
                    onEditProfile: () {
                      navigateTo(context, const EditProfileScreen());
                    },
                    onUploadImage: () {
                      profileCubit.getProfileImage();
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // --- Menu Items Section ---
              ProfileMenuItemWidget(
                title: "My Profile",
                leadingIcon: IconBroken.Profile,
                onTap: () => navigateTo(context, const ProfileDetailsScreen()),
              ),

              if (user.companyId != null) ...[
                const SizedBox(height: 16),
                ProfileMenuItemWidget(
                  title: "My Company",
                  leadingIcon: IconBroken.Work,
                  onTap: () =>
                      navigateTo(context, const CompanyDetailsScreen()),
                ),
              ],

              if (user.userType == 'Company Owner' ||
                  user.roleType == 'Hr admin') ...[
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    "Business Tools",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItemWidget(
                  title: "Generate QR Code",
                  leadingIcon: IconBroken.Scan,

                  onTap: () {
                    final company = appCubit.companyModel;
                    navigateTo(
                      context,
                      GenerateQrCodeScreen(
                        companyId: company?.companyId ?? user.companyId ?? '',
                        sharedSecret: company?.sharedSecret,
                      ),
                    );
                  },
                ),
              ],

              // --- Kiosk Account Section (Company Owner only) ---
              if ((user.userType == 'Company Owner' ||
                      user.roleType == 'Hr admin') &&
                  user.companyId != null) ...[
                const SizedBox(height: 24),
                KioskAccountSection(
                  companyId: appCubit.companyModel?.companyId ??
                      user.companyId ?? '',
                  companyName: appCubit.companyModel?.organizationName,
                ),
              ],

              const SizedBox(height: 16),

              ProfileMenuItemWidget(
                title: "Log out",
                leadingIcon: IconBroken.Logout,
                isDestructive: true,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              performLogout(
                context,
                profileCubit: ProfileCubit.get(context),
                registerCubit: RegisterCubit.get(context),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Helper function to handle the logout sequence
Future<void> performLogout(
  BuildContext context, {
  required ProfileCubit profileCubit,
  required RegisterCubit registerCubit,
}) async {
  try {
    // 1. Clear local cache
    await Future.wait([
      CacheHelper.removeData(key: 'uId'),
      CacheHelper.removeData(key: 'companyId'),
      CacheHelper.removeData(key: 'isKiosk'),
    ]);

    if (!context.mounted) return;

    // 2. Reset App-wide state
    final appCubit = AppCubit.get(context);

    // It's better to have a reset method in AppCubit, but for now:
    appCubit.userModel = null;
    appCubit.companyModel = null;
    appCubit.changeIndex(0);

    // 3. Clean up specific cubits
    profileCubit.resetProfileData();
    registerCubit.resetRegistrationData();

    // 4. Navigate back to Login and clear stack
    navigateAndFinish(context, LoginScreen());
  } catch (e) {
    debugPrint('Error during logout: $e');
  }
}
