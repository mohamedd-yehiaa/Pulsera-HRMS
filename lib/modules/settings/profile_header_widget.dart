import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel? userModel;
  final VoidCallback onEditProfile;
  final VoidCallback onUploadImage;
  final File? pickedImage; // Changed to File? and renamed for clarity

  const ProfileHeaderWidget({
    super.key,
    required this.userModel,
    required this.onEditProfile,
    required this.onUploadImage,
    this.pickedImage, // Pass the picked file from the parent/cubit
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildAvatar(),
            // Camera Icon Button
            GestureDetector(
              onTap: onUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  IconBroken.Camera,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userModel != null
              ? '${userModel!.firstName} ${userModel!.lastName}'.trim()
              : '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to keep the build method clean
  Widget _buildAvatar() {
    if (pickedImage != null) {
      return CircleAvatar(radius: 55, backgroundImage: FileImage(pickedImage!));
    } else if (userModel?.image != null && userModel!.image!.isNotEmpty) {
      return CircleAvatar(
        radius: 55,
        backgroundImage: NetworkImage(userModel!.image!),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textSecondary, width: 2),
        ),
        child: CircleAvatar(
          radius: 55,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            (userModel?.firstName ?? 'E')[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
        ),
      );
    }
  }
}
