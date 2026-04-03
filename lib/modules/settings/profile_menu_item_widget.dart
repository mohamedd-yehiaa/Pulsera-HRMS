import 'package:flutter/material.dart';
import 'package:pulsera/shared/styles/colors.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItemWidget({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? AppColors.red500.withValues(alpha: 0.1) 
              : AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          leadingIcon,
          color: isDestructive ? AppColors.red500 : AppColors.textPrimary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDestructive ? AppColors.red500 : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
