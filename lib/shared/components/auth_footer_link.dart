import 'package:flutter/material.dart';
import '../styles/colors.dart';

/// Reusable "Don't have an account? Sign Up" / "Already have an account? Login"
/// footer link row used on auth screens.
class AuthFooterLink extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const AuthFooterLink({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              actionLabel,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.blue500,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
