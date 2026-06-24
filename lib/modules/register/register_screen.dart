import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../../shared/components/auth_branding_panel.dart';
import '../../shared/components/auth_footer_link.dart';
import '../../shared/components/auth_form_container.dart';
import '../../shared/components/components.dart';
import '../../shared/components/primary_button.dart';
import '../../shared/components/responsive_layout.dart';
import '../../shared/components/social_sign_in_section.dart';
import '../../shared/cubit/app_cubit.dart';
import '../../shared/cubit/register_cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/network/local/cache_helper.dart';
import '../../shared/styles/colors.dart';

class RegisterScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is CreateUserErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is RegisterErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is CreateUserSuccessState) {
            CacheHelper.saveData(
              key: 'uId',
              value: FirebaseAuth.instance.currentUser!.uid,
            ).then((value) {
              navigateAndFinish(context, HomeLayout());
              AppCubit.get(context).getUserData();
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            // AppBar only on mobile / tablet (back navigation)
            appBar: ResponsiveLayout.isDesktop(context)
                ? null
                : AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: backButton(context),
                  ),
            body: ResponsiveLayout(
              mobile: _buildMobileLayout(context, state),
              tablet: _buildTabletLayout(context, state),
              desktop: _buildDesktopLayout(context, state),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context, RegisterStates state) {
    return AuthFormContainer(
      deviceType: DeviceType.mobile,
      child: _RegisterFormBody(
        formKey: formKey,
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        passwordController: passwordController,
        phoneController: phoneController,
        confirmPasswordController: confirmPasswordController,
        state: state,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context, RegisterStates state) {
    return AuthFormContainer(
      deviceType: DeviceType.tablet,
      child: _RegisterFormBody(
        formKey: formKey,
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        passwordController: passwordController,
        phoneController: phoneController,
        confirmPasswordController: confirmPasswordController,
        state: state,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context, RegisterStates state) {
    return Row(
      children: [
        // Left — branding panel
        const Expanded(child: AuthBrandingPanel()),

        // Right — register form
        Expanded(
          child: Container(
            color: AppColors.grey50,
            child: AuthFormContainer(
              deviceType: DeviceType.desktop,
              child: _RegisterFormBody(
                formKey: formKey,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                emailController: emailController,
                passwordController: passwordController,
                phoneController: phoneController,
                confirmPasswordController: confirmPasswordController,
                state: state,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRIVATE: Shared form body (reused across all 3 layouts)
// ═════════════════════════════════════════════════════════════════════════════
class _RegisterFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController confirmPasswordController;
  final RegisterStates state;

  const _RegisterFormBody({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.confirmPasswordController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final RegisterCubit cubit = RegisterCubit.get(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Text(
            S.of(context).letsGetStarted,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontFamily: 'Jannah',
              fontSize: 30,
              color: AppColors.primary,
            ),
          ),
          Text(
            S.of(context).registerNowToContinue,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontFamily: 'Jannah',
              fontSize: 17,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 30),

          // ── First Name ──
          DefaultFormField(
            controller: firstNameController,
            type: TextInputType.name,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterFirstName;
              }
              return null;
            },
            label: Text(
              S.of(context).firstName,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Profile,
          ),

          const SizedBox(height: 15),

          // ── Last Name ──
          DefaultFormField(
            controller: lastNameController,
            type: TextInputType.name,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterLastName;
              }
              return null;
            },
            label: Text(
              S.of(context).lastName,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.User,
          ),

          const SizedBox(height: 15),

          // ── User Type dropdown ──
          DropdownButtonFormField<String>(
            initialValue: cubit.selectedUserType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 10.0,
              ),
              fillColor: AppColors.grey100,
              filled: true,
              labelText: S.of(context).userType,
              prefixIcon: const Icon(
                IconBroken.Bag_2,
                color: AppColors.blue500,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                borderSide: BorderSide.none,
              ),
              labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            items: ['Company Owner', 'Employee']
                .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)),
                )
                .toList(),
            onChanged: (value) {
              cubit.changeUserType(value!);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseSelectRole;
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // ── Email ──
          DefaultFormField(
            controller: emailController,
            type: TextInputType.emailAddress,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterEmail;
              }
              return null;
            },
            label: Text(
              S.of(context).emailAddress,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Message,
          ),

          const SizedBox(height: 15),

          // ── Password ──
          DefaultFormField(
            controller: passwordController,
            type: TextInputType.visiblePassword,
            suffix: cubit.suffix,
            isPassword: cubit.isPassword,
            suffixPressed: () => cubit.changePasswordVisibility(),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).passwordTooShort;
              }
              return null;
            },
            label: Text(
              S.of(context).password,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Lock,
          ),

          const SizedBox(height: 15),

          // ── Confirm Password ──
          DefaultFormField(
            controller: confirmPasswordController,
            type: TextInputType.visiblePassword,
            suffix: cubit.confirmSuffix,
            isPassword: cubit.isConfirmPassword,
            suffixPressed: () => cubit.changeConfirmPasswordVisibility(),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseConfirmPassword;
              }
              if (value != passwordController.text) {
                return S.of(context).passwordsDoNotMatch;
              }
              return null;
            },
            label: Text(
              S.of(context).confirmPassword,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Lock,
          ),

          const SizedBox(height: 15),

          // ── Phone ──
          DefaultFormField(
            controller: phoneController,
            type: TextInputType.phone,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterPhone;
              }
              return null;
            },
            label: Text(
              S.of(context).phoneNumber,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Call,
          ),

          const SizedBox(height: 30),

          // ── Register button ──
          PrimaryButton(
            label: S.of(context).register,
            isLoading: state is RegisterLoadingState,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                cubit.userRegister(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  phone: phoneController.text,
                  userType: cubit.selectedUserType,
                );
              }
            },
          ),

          const SizedBox(height: 25),

          // ── Social sign in ──
          SocialSignInSection(
            onGooglePressed: () {
              cubit.signInWithGoogle();
            },
          ),

          // ── Login link ──
          AuthFooterLink(
            message: S.of(context).alreadyHaveAccount,
            actionLabel: S.of(context).login,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
