import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

extension AppDateTime on DateTime {
  // Now these are methods that accept the locale string
  String toMMDDYY(String locale) {
    return DateFormat("MMM d, y", locale).format(this);
  }

  String toMMDDYYYY(String locale) {
    return DateFormat("MMM d, yyyy", locale).format(this);
  }

  String toDDMMYYYY(String locale) {
    return DateFormat("dd-MM-yyyy", locale).format(this);
  }

  String toWEEKDAY(String locale) {
    return DateFormat.EEEE(locale).format(this);
  }

  String toDAY(String locale) {
    return DateFormat.E(locale).format(this);
  }

  String toYYYMMDD(String locale) {
    return DateFormat("yyyy-MM-dd", locale).format(this);
  }

  String tohhMMh(String locale) {
    return DateFormat.jm(locale).format(this);
  }

  String toMMOnly(String locale) {
    return DateFormat.MMM(locale).format(this);
  }

  String toHOUR24MINUTESECOND(String locale) {
    return DateFormat.Hms(locale).format(this);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

extension LocalizedNumbers on String {
  /// Converts standard English digits to Eastern Arabic digits.
  String toArabicDigits() {
    // 1. Added the English decimal '.' and the Arabic decimal '٫' to the end of these lists
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٫'];

    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// A smart helper that checks the locale and converts if necessary
  String localizeDigits(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? toArabicDigits() : this;
  }
  /// Converts Eastern Arabic digits back to standard English digits for math/parsing
  String toEnglishDigits() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }
}
extension MoneyFormatting on double? {
  /// Globally formats any nullable double into a localized currency string.
  /// Automatically handles Arabic digits, decimal points, and LE/جم swapping.
  String formatMoney(BuildContext context, {String prefix = ''}) {
    // 1. Check language direction
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final String currency = isArabic ? 'جم' : 'LE';

    // 2. Parse the double (defaults to 0.00 if the variable is null)
    final String value = this?.toStringAsFixed(2) ?? '0.00';

    // 3. Combine everything and instantly localize the digits
    return '$prefix$value $currency'.localizeDigits(context);
  }
}

