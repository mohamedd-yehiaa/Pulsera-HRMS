import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_extension.dart';
import '../styles/colors.dart';
import '../styles/icon_broken.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onFieldSubmitted,
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

void showForgotPasswordSheet(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the modal to move up with the keyboard
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        // This padding prevents the keyboard from covering the text field
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Takes up only half the screen
            children: [
              // Grey Handle Bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 25),

              Text(
                "Forgot Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Enter your email to receive a reset link",
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 25),
              DefaultFormField(
                controller: emailController,
                type: TextInputType.emailAddress,
                label: Text(
                  "Email Address",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'please enter your email address';
                  }
                  return null;
                },
                prefix: IconBroken.Message,
              ),

              SizedBox(height: 25),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                    onPressed: () async {
                      try {
                        // 1. Send the email
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );

                        // 2. Close the current "Email Input" BottomSheet
                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message ?? "An error occurred"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  child: Text(
                    "Confirm",
                    style: Theme.of(context).textTheme.titleLarge!
                      .copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


