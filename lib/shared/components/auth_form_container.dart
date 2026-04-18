import 'package:flutter/material.dart';
import '../styles/colors.dart';

/// Device category for styling decisions.
enum DeviceType { mobile, tablet, desktop }

/// A container that wraps auth form content with device-appropriate styling.
///
/// * **Mobile** – full-width, minimal padding, no card.
/// * **Tablet** – centred with max width 480, subtle shadow.
/// * **Desktop** – centred vertically, max width 440, elevated card with
///   rounded corners and shadow.
class AuthFormContainer extends StatelessWidget {
  final Widget child;
  final DeviceType deviceType;

  const AuthFormContainer({
    super.key,
    required this.child,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    switch (deviceType) {
      case DeviceType.mobile:
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: child,
          ),
        );

      case DeviceType.tablet:
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey300.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );

      case DeviceType.desktop:
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
    }
  }
}
