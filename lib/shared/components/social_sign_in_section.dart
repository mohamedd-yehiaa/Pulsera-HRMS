import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import '../styles/colors.dart';

/// Reusable social sign-in section with divider and Google button.
///
/// Used identically on both Login and Register screens.
class SocialSignInSection extends StatelessWidget {
  final VoidCallback onGooglePressed;

  const SocialSignInSection({
    super.key,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Divider ──
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                S.of(context).orContinueWithSocial,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),

        const SizedBox(height: 24),

        // ── Google button ──
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onGooglePressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[200]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/google.png'),
                  height: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).google,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
