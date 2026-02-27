import 'package:flutter/material.dart';
import 'colors.dart';

final borderRadius = BorderRadius.circular(12);

List<BoxShadow> get kBoxShadow => [
      BoxShadow(
        color: AppColors.grey300.withValues(alpha: 0.2),
        offset: const Offset(0, 4),
        blurRadius: 6,
        spreadRadius: 2,
      ),
    ];

BoxDecoration get kBoxDecoration => BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: AppColors.white,
      boxShadow: kBoxShadow,
    );

Size get buttonFixedSize => const Size(double.maxFinite, 50);
TextStyle get btnTextStyle => const TextStyle(
      fontSize: 15,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    );
final appTheme = ThemeData(

  progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.primary,strokeWidth: 6,refreshBackgroundColor: AppColors.grey300),
  primaryColor: AppColors.primary,
  fontFamily: "Jannah",
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.white,
    elevation: 0,
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: AppColors.primary,
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.grey800,
  ),
  // timePickerTheme: TimePickerThemeData(),
  // datePickerTheme: DatePickerThemeData(),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.grey800,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      fixedSize: buttonFixedSize,
      textStyle: btnTextStyle,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.grey300,
      fixedSize: buttonFixedSize,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(
          color: AppColors.grey300,
          width: .7,
        ),
      ),
      side: const BorderSide(
        color: AppColors.grey300,
        width: .7,
      ),
      shadowColor: AppColors.grey300,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3.5),
    ),
  ),
  chipTheme: ChipThemeData(
    checkmarkColor: AppColors.white,
    selectedColor: AppColors.primary,
    backgroundColor: AppColors.primary.withValues(alpha: 0.09),
    side: const BorderSide(
      color: AppColors.grey300,
      width: .7,
    ),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.black900,
  ),
  textTheme: const TextTheme(
    bodySmall: TextStyle(
      fontFamily: "Jannah",
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    bodyMedium: TextStyle(
      fontFamily: "Jannah",
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    bodyLarge: TextStyle(
      fontFamily: "Jannah",
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    labelSmall: TextStyle(
      fontFamily: "Jannah",
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w300,
      color: AppColors.black900,
    ),
    labelMedium: TextStyle(
      fontFamily: "Jannah",
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w300,
      color: AppColors.black900,
    ),
    labelLarge: TextStyle(
      fontFamily: "Jannah",
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w300,
      color: AppColors.black900,
    ),
    titleSmall: TextStyle(
      fontFamily: "Jannah",
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    titleMedium: TextStyle(
      fontFamily: "Jannah",
      fontSize: 15,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    titleLarge: TextStyle(
      fontFamily: "Jannah",
      fontSize: 18,
      height: 28 / 22,
      fontWeight: FontWeight.w500,
      color: AppColors.black900,
    ),
    headlineSmall: TextStyle(
      fontFamily: "Jannah",
      fontSize: 20,
      height: 32 / 24,
      fontWeight: FontWeight.w500,
      color: AppColors.black900,
    ),
    headlineMedium: TextStyle(
      fontFamily: "Jannah",
      fontSize: 24,
      height: 36 / 28,
      fontWeight: FontWeight.w500,
      color: AppColors.black900,
    ),
    headlineLarge: TextStyle(
      fontFamily: "Jannah",
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w500,
      color: AppColors.black900,
    ),
    displaySmall: TextStyle(
      fontFamily: "Jannah",
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    displayMedium: TextStyle(
      fontFamily: "Jannah",
      fontSize: 45,
      height: 52 / 45,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
    displayLarge: TextStyle(
      fontFamily: "Jannah",
      fontSize: 56,
      height: 64 / 56,
      fontWeight: FontWeight.w400,
      color: AppColors.black900,
    ),
  ),
  scaffoldBackgroundColor: AppColors.white,
);
