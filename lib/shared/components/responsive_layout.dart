import 'package:flutter/material.dart';

/// Breakpoints for responsive layout switching.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// A reusable layout widget that picks the correct child based on screen width.
///
/// Uses [LayoutBuilder] so it reacts to the actual available width (not just
/// the device class), which means it also works correctly when a desktop
/// window is resized.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Helper to check screen category from any [BuildContext].
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.mobile && w <= Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > Breakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width > Breakpoints.tablet) {
          return desktop;
        } else if (width >= Breakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
