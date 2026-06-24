import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/app_extension.dart';
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
              S.of(context).personalDetails,
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
                  tooltip: S.of(context).editProfile,
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
                title: S.of(context).fullName,
                value: '${user.firstName} ${user.lastName}',
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: IconBroken.Message,
                title: S.of(context).emailAddress,
                value: user.email ?? S.of(context).notProvided,
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: IconBroken.Call,
                title: S.of(context).phoneNumber,
                value: user.phone?.toString().localizeDigits(context) ?? S.of(context).notProvided,
                forceLtr: true,
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
    bool forceLtr = false,
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
                textDirection: forceLtr ? TextDirection.ltr : null,
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
