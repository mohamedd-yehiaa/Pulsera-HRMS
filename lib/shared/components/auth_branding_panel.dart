import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/colors.dart';

/// The left-side branding panel shown on desktop split-screen auth layouts.
///
/// Displays the app logo, a headline, and a subtitle on top of a
/// gradient background with decorative floating shapes.
class AuthBrandingPanel extends StatelessWidget {
  final String? headline;
  final String? subtitle;

  const AuthBrandingPanel({
    super.key,
    this.headline,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final displayHeadline = headline ?? S.of(context).welcomeToPulsera;
    final displaySubtitle = subtitle ?? S.of(context).managePulseraSubtitle;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blue700,
            AppColors.blue500,
            Color(0xFF1565C0),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative circles ──
          Positioned(
            top: -60,
            left: -60,
            child: _circle(200, 0.07),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: _circle(160, 0.08),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _circle(80, 0.10),
          ),
          Positioned(
            bottom: 180,
            left: 30,
            child: _circle(60, 0.06),
          ),
          Positioned(
            top: 300,
            left: 100,
            child: _circle(40, 0.12),
          ),

          // ── Main content (centered) ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Headline
                  Text(
                    displayHeadline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Jannah',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    displaySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Jannah',
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Decorative dots row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: i == 1 ? 32 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == 1 ? 0.9 : 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a translucent decorative circle.
  static Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
