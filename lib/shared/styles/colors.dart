import 'package:flutter/material.dart';

class AppColors {
  // ===========================================================================
  // 1. PALETTE
  // ===========================================================================

  // Blacks & Whites
  static const Color white = Color(0xffFFFFFF);
  static const Color black = Color(0xff000000);
  static const Color black900 = Color(0xff1F1F25);

  // Greys
  static const Color grey50 = Color(0xffF9F9F9);
  static const Color grey100 = Color(0xffF1F1F1);
  static const Color grey200 = Color(0xffF5F5F5);
  static const Color grey300 = Color(0xffB2B2B2);
  static const Color grey500 = Color(0xff646464);
  static const Color grey700 = Color(0xff444F5B);
  static const Color grey800 = Color(0xff353F4A);
  static const Color grey900 = Color(0xFF2B2B2B);

  // Primary Blues
  static const Color blue500 = Color(0xFF1976D2);
  static const Color blue600 = Color(0xff1C74DA);
  static const Color blue700 = Color(0xff0B72E7);
  static const Color blue900 = Color(0xff236DC5);

  // Purples
  static const Color purple50 = Color(0xffEFECFC);
  static const Color purple100 = Color(0xffDFCCFB);
  static const Color purple200 = Color(0xffD2B2FF);
  static const Color purple300 = Color(0xffB78AF7);
  static const Color purple500 = Color(0xff9654F4);
  static const Color purple700 = Color(0xff8133F1);
  static const Color purple800 = Color(0xff360083);
  static const Color purple900 = Color(0xff4600A9);

  // Status Colors (Green, Red, Orange)
  static const Color green400 = Color(0xFF06C5AC);
  static const Color green500 = Color(0xff0A7D00);
  static const Color red500 = Color(0xffD74425);
  static const Color red600 = Color(0xFFea435d);
  static const Color orange500 = Color(0xffE96D14);

  // ===========================================================================
  // 2. SEMANTICS
  // ===========================================================================

  // Main App Colors
  static const Color primary = blue500;
  static const Color background = white;
  static const Color surface = grey50;

  // Text Colors
  static const Color textPrimary = black900;
  static const Color textSecondary = grey500;
  static const Color textWhite = white;

  // States
  static const Color success = green500;
  static const Color error = red500;
  static const Color warning = orange500;

  // Specific Components
  static const Color sideDrawerBg = Color(0xffFCFBFF);
  static const Color sideDrawerSelected = Color(0xffF6F4FD);
  static const Color borderColor = Color(0xffEAE6FF);
  static const Color dividerColor = grey100; // Color(0xffF1F1F1);
}