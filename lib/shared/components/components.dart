import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../app_extension.dart';
import '../styles/colors.dart';
import '../styles/theme.dart';

class DefaultFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final Widget label;
  final IconData prefix;
  final IconData? suffix;
  final bool isPassword;
  final VoidCallback? suffixPressed;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const DefaultFormField({
    super.key,
    required this.controller,
    required this.type,
    required this.label,
    required this.prefix,
    this.suffix,
    this.isPassword = false,
    this.suffixPressed,
    this.validator,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10.0,
        ),
        label: label,
        filled: true,
        fillColor: AppColors.grey100,
        prefixIcon: Icon(prefix, color: AppColors.blue500),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(suffix),
                color: AppColors.blue500,
              )
            : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final IconData iconData;
  final String title;
  final DateTime dateTime;
  final String description;

  const ActivityCard({
    super.key,
    required this.iconData,
    required this.title,
    required this.dateTime,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Container(
      decoration: boxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Icon Section
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary,
              ),
              child: Icon(iconData, size: 24, color: AppColors.white),
            ),
            const SizedBox(width: 12),

            // 2. Title and Date Section
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // FIX: Chain localizeDigits here to catch the date numbers!
                    dateTime.toMMDDYY(locale).localizeDigits(context),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey300),
                  ),
                ],
              ),
            ),

            // 3. Time and Description Section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    // FIX: Chain localizeDigits here to catch the time numbers!
                    dateTime.tohhMMh(locale).localizeDigits(context),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey300),
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalDate extends StatelessWidget {
  final DateTime fromDate, toDate, selectedDate;
  final void Function(DateTime newDate)? onTap;

  const HorizontalDate({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Row(
      children: List.generate(fromDate.difference(toDate).inDays, (index) {
        DateTime currentDate = fromDate.subtract(Duration(days: index));
        bool isSelected =
            currentDate.year == selectedDate.year &&
            currentDate.month == selectedDate.month &&
            currentDate.day == selectedDate.day;

        return Align(
          alignment: Alignment.center,
          child: Padding(
            // FIX: Use EdgeInsetsDirectional so the 16px padding is always on the reading-start side!
            padding: EdgeInsetsDirectional.only(
              start: index == 0 ? 16 : 8,
              end: 8,
            ),
            child: InkWell(
              borderRadius: borderRadius,
              onTap: isSelected ? null : () => onTap!(currentDate),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  boxShadow: boxShadow,
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: borderRadius,
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern(
                        locale,
                      ).format(currentDate.day).localizeDigits(context),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.black900,
                          ),
                    ),
                    Text(
                      currentDate.toDAY(locale),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.black900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class AppButton {
  static Widget appButton({
    required void Function()? onPressed,
    required String label,
    Widget? child,
  }) {
    return ElevatedButton(onPressed: onPressed, child: child ?? Text(label));
  }

  static Widget appOulineButtonRow({
    required void Function()? onPressed,
    required String label,
    required BuildContext context,
    String? value,
    EdgeInsetsGeometry? padding,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          // Ensures the button doesn't shrink smaller than the text field
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide.none,
          backgroundColor: AppColors.grey100,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (prefixIcon != null) ...{prefixIcon},
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
            if (suffixIcon != null) ...{suffixIcon},
          ],
        ),
      ),
    );
  }
}

void navigateTo(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => widget),
  (route) {
    return false;
  },
);

Widget title(BuildContext context, String name, IconData iconData) {
  return Row(
    children: [
      Text(
        name,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontSize: 19,
        ),
      ),
      const SizedBox(width: 10),
      Icon(iconData, size: 24, color: AppColors.blue600),
    ],
  );
}

Widget backButton(BuildContext context) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Icon(
      // Swap the icon based on the direction
      isRtl ? IconBroken.Arrow___Right_2 : IconBroken.Arrow___Left_2,
      size: 28,
    ),
  );
}
