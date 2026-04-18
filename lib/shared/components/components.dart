import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
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

              // 2. Title and Date Section (Flex 2 gives it priority)
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
                      dateTime.toMMDDYY,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey300,
                      ),
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
                      dateTime.tohhMMh,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey300,
                      ),
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
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),

          // 2. Ensures the button doesn't shrink smaller than the text field
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
// ── Forgot Password Bottom Sheet ──
void showForgotPasswordSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => const _ForgotPasswordSheet(),
);

/// A stateful bottom sheet for the forgot password flow.
///
/// Uses [BlocConsumer] to react to [AuthCubit] states and manages a
/// 60-second cooldown timer to prevent rapid repeated requests.
class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _emailSent = false;

  // Simple email regex for client-side validation.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60;
      _emailSent = true;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          _startCooldown();
        }
      },
      buildWhen: (_, current) =>
          current is ResetPasswordLoadingState ||
          current is ResetPasswordSuccessState ||
          current is ResetPasswordErrorState ||
          current is AuthInitialState,
      builder: (context, state) {
        final isLoading = state is ResetPasswordLoadingState;
        final isError = state is ResetPasswordErrorState;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Header icon ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      IconBroken.Lock,
                      color: AppColors.blue500,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // ── Subtitle ──
                  Text(
                    "Enter your email address and we'll send you a link to reset your password.",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // ── Success banner ──
                  if (_emailSent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.green400.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.green400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.green400, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset link sent!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.green500,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Check your email inbox. If you don\'t see it, check your spam/junk folder.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: AppColors.green500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Error banner ──
                  if (isError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.red500.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.red500, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.error,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: AppColors.red500),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Email field ──
                  DefaultFormField(
                    controller: _emailController,
                    type: TextInputType.emailAddress,
                    label: Text(
                      'Email Address',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                    ),
                    prefix: IconBroken.Message,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!_emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Send button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isLoading || _cooldownSeconds > 0)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              _cooldownSeconds > 0
                                  ? 'Resend in ${_cooldownSeconds}s'
                                  : _emailSent
                                      ? 'Resend Reset Link'
                                      : 'Send Reset Link',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      AuthCubit.get(context).sendPasswordResetEmail(
        email: _emailController.text,
      );
    }
  }
}

Widget title(BuildContext context, String name, IconData iconData) {
  return Row(
    children: [
      Text(name, style: Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontSize: 19,
      )),
      const SizedBox(width: 10),
      Icon(iconData, size: 24, color: AppColors.blue600),
    ],
  );
}

Widget backButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(
      IconBroken.Arrow___Left_2,
      size: 28,
    ),
  );
}


