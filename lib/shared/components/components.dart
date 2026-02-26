import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // 3. Move your UI code here
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius, // Ensure this variable is accessible
        color: AppColors.white,
        boxShadow: kBoxShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary,
              ),
              child: Icon(iconData, size: 24, color: AppColors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  dateTime.toMMDDYY,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.grey300),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateTime.tohhMMh,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.grey300),
                ),
              ],
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
            padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
            child: InkWell(
              borderRadius: borderRadius,
              onTap: isSelected ? null : () => onTap!(currentDate),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: borderRadius,
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentDate.day.toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.black900,
                          ),
                    ),
                    Text(
                      currentDate.toMMOnly,
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
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
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
// UI Implementation snippet
void showForgotPasswordSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true, // Allows keyboard to push the sheet up
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(
      bottom:
          MediaQuery.of(context).viewInsets.bottom +
          20, // Avoids keyboard overlap
      left: 20,
      right: 20,
      top: 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forgot Password?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Enter your email address and we'll send you a link to reset your password.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),
        DefaultFormField(
          controller: TextEditingController(),
          type: TextInputType.emailAddress,
          label: Text(
            'Email Address',),
          prefix: IconBroken.Message,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'please enter your email address';
            }
            return null;
          },

        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.sendPasswordResetEmail(
                email: TextEditingController().text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Send Reset Link"),
          ),
        ),
      ],
    ),
  ),
);

Widget title(BuildContext context, String name, IconData iconData) {
  return Row(
    children: [
      Text(name, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(width: 10),
      Icon(iconData, size: 20, color: AppColors.blue600),
    ],
  );
}


