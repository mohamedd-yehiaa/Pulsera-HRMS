import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/modules/profile/company_details_screen.dart';
import 'package:pulsera/modules/profile/edit_profile_screen.dart';
import 'package:pulsera/modules/profile/generate_qr_code_screen.dart';
import 'package:pulsera/modules/profile/kiosk_account_section.dart';
import 'package:pulsera/modules/profile/profile_details_screen.dart';
import 'package:pulsera/modules/profile/profile_header_widget.dart';
import 'package:pulsera/modules/profile/profile_menu_item_widget.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/localization_cubit.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      profileCubit.getProfileImage(context);
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // --- Menu Items Section ---
              ProfileMenuItemWidget(
                title: S.of(context).myProfile,
                leadingIcon: IconBroken.Profile,
                onTap: () => navigateTo(context, const ProfileDetailsScreen()),
              ),

              if (user.companyId != null) ...[
                const SizedBox(height: 16),
                ProfileMenuItemWidget(
                  title: S.of(context).myCompany,
                  leadingIcon: IconBroken.Work,
                  onTap: () =>
                      navigateTo(context, const CompanyDetailsScreen()),
                ),
              ],
              const SizedBox(height: 16),
              BlocBuilder<LocalizationCubit, LocalizationStates>(
                builder: (context, localeState) {
                  final locale = LocalizationCubit.get(
                    context,
                  ).locale.languageCode;
                  return ProfileMenuItemWidget(
                    title: S.of(context).language,
                    subtitle: locale == 'ar' ? 'العربية' : 'English',
                    leadingIcon: Icons.language_outlined,
                    onTap: () {
                      _showLanguageSelector(context);
                    },
                  );
                },
              ),

              if (user.userType == 'Company Owner' ||
                  user.roleType == 'Hr admin') ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    S.of(context).businessTools,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItemWidget(
                  title: S.of(context).generateQrCode,
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
                  companyId:
                      appCubit.companyModel?.companyId ?? user.companyId ?? '',
                  companyName: appCubit.companyModel?.organizationName,
                ),
              ],

              const SizedBox(height: 16),

              ProfileMenuItemWidget(
                title: S.of(context).logout,
                leadingIcon: IconBroken.Logout,
                isDestructive: true,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return BlocBuilder<LocalizationCubit, LocalizationStates>(
          builder: (context, state) {
            final cubit = LocalizationCubit.get(context);
            final currentLang = cubit.locale.languageCode;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).selectLanguage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: const Text("English"),
                      trailing: currentLang == 'en'
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        cubit.changeLanguage('en');
                        Navigator.pop(bottomSheetContext);
                      },
                    ),
                    ListTile(
                      title: const Text("العربية"),
                      trailing: currentLang == 'ar'
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        cubit.changeLanguage('ar');
                        Navigator.pop(bottomSheetContext);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).logout),
        content: Text(S.of(context).logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
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
            child: Text(
              S.of(context).logout,
              style: const TextStyle(color: Colors.red),
            ),
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
    NotificationCubit.get(context).clearStream();

    // 4. Navigate back to Login and clear stack
    navigateAndFinish(context, LoginScreen());
  } catch (e) {
    debugPrint('Error during logout: $e');
  }
}
