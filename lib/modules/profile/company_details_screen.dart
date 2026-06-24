import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/profile/edit_company_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:pulsera/shared/app_extension.dart';

class CompanyDetailsScreen extends StatelessWidget {
  const CompanyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      builder: (context, state) {
        CompanyModel? company = AppCubit.get(context).companyModel;
        UserModel? user = AppCubit.get(context).userModel;

        if (company == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: backButton(context),
            title: Text(
              S.of(context).organizationDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            elevation: 0,
            actions: [
              if (user?.userType == "Company Owner")
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      IconBroken.Edit,
                      color: AppColors.primary,
                      size: 25,
                    ),
                    tooltip: S.of(context).editOrganizationDetails,
                    onPressed: () {
                      navigateTo(context, const EditCompanyScreen());
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
                icon: IconBroken.User1,
                title: S.of(context).organizationName,
                value: company.organizationName ?? S.of(context).notProvided,
              ),
              const Divider(height: 32),
              _buildInfoTile(
                icon: Icons.access_time_outlined,
                title: S.of(context).workingHours,
                value:
                    '${company.startTime ?? "00:00"} → ${company.endTime ?? "00:00"}'
                        .localizeDigits(context),
              ),
              const Divider(height: 32),
              Text(
                S.of(context).workingDays,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (company.workingDays ?? []).map((dayCode) {
                  final String localizedDay = getLocalizedDay(context, dayCode);
                  return Chip(
                    label: Text(localizedDay),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
