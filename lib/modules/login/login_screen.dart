import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/kiosk/kiosk_qr_screen.dart';
import 'package:pulsera/modules/login/reset_password.dart';
import 'package:pulsera/modules/register/register_screen.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/components/auth_branding_panel.dart';
import '../../shared/components/auth_footer_link.dart';
import '../../shared/components/auth_form_container.dart';
import '../../shared/components/components.dart';
import '../../shared/components/primary_button.dart';
import '../../shared/components/responsive_layout.dart';
import '../../shared/components/social_sign_in_section.dart';
import '../../shared/cubit/app_cubit.dart';
import '../../shared/cubit/auth_cubit.dart';
import '../../shared/cubit/register_cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/network/local/cache_helper.dart';
import '../../shared/styles/colors.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterCubit, RegisterStates>(
          listener: (context, state) {
            if (state is CreateUserErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
            if (state is CreateUserSuccessState) {
              CacheHelper.saveData(
                key: 'uId',
                value: FirebaseAuth.instance.currentUser!.uid,
              ).then((value) {
                AppCubit.get(context).getUserData();
                AppCubit.get(context).getCompanyData();
              });
              navigateAndFinish(context, HomeLayout());
            }
          },
        ),
      ],
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          // --- Existing Login States ---
          if (state is AuthErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is AuthSuccessState) {
            _handleAuthSuccess(context, state.uId);
          }

          // Password Reset States
          if (state is ResetPasswordSuccessState) {
            Fluttertoast.showToast(
              msg:
                  S.of(context).resetLinkSent,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.green,
            );
            // Close the bottom sheet automatically
            Navigator.pop(context);
          }

          if (state is ResetPasswordErrorState) {
            Fluttertoast.showToast(
              msg: state
                  .error, // This grabs the awesome error messages you wrote in the switch statement!
              backgroundColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: ResponsiveLayout(
              // ── Mobile ──
              mobile: _buildMobileLayout(context, state),
              // ── Tablet ──
              tablet: _buildTabletLayout(context, state),
              // ── Desktop ──
              desktop: _buildDesktopLayout(context, state),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — single column, full-width, edge-to-edge
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context, AuthStates state) {
    return AuthFormContainer(
      deviceType: DeviceType.mobile,
      child: _LoginFormBody(
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
        state: state,
        showLogo: true,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TABLET LAYOUT — centred card, max-width 480
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context, AuthStates state) {
    return AuthFormContainer(
      deviceType: DeviceType.tablet,
      child: _LoginFormBody(
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
        state: state,
        showLogo: true,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT — split screen: branding | form
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context, AuthStates state) {
    return Row(
      children: [
        // Left — branding panel
        const Expanded(child: AuthBrandingPanel()),

        // Right — login form
        Expanded(
          child: Container(
            color: AppColors.grey50,
            child: AuthFormContainer(
              deviceType: DeviceType.desktop,
              child: _LoginFormBody(
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                state: state,
                showLogo: false, // logo is on the branding panel
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles post-auth logic: checks if user is KIOSK and redirects accordingly.
  Future<void> _handleAuthSuccess(BuildContext context, String uId) async {
    try {
      await CacheHelper.saveData(key: 'uId', value: uId);

      // Fetch user doc to check userType
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .get();

      final userType = doc.data()?['userType'];

      if (!context.mounted) return;

      if (userType == 'KIOSK') {
        // Kiosk user → save flag and go to kiosk QR screen
        await CacheHelper.saveData(key: 'isKiosk', value: true);
        final companyId = doc.data()?['companyId'] ?? '';
        if (!context.mounted) return;
        navigateAndFinish(context, KioskQrScreen(companyId: companyId));
      } else {
        // Normal user → standard flow
        if (!context.mounted) return;
        AppCubit.get(context).getUserData();
        AppCubit.get(context).getCompanyData();
        navigateAndFinish(context, HomeLayout());
      }
    } catch (e) {
      // Fallback: navigate to HomeLayout on any error
      if (!context.mounted) return;
      AppCubit.get(context).getUserData();
      AppCubit.get(context).getCompanyData();
      navigateAndFinish(context, HomeLayout());
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRIVATE: Shared form body (reused across all 3 layouts)
// ═════════════════════════════════════════════════════════════════════════════
class _LoginFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthStates state;
  final bool showLogo;

  const _LoginFormBody({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.state,
    required this.showLogo,
  });

  @override
  Widget build(BuildContext context) {
    final AuthCubit cubit = AuthCubit.get(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Logo (mobile & tablet only) ──
          if (showLogo) ...[
            Center(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],

          // ── Header text ──
          Text(
            S.of(context).welcomeBackExclamation,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontFamily: 'Jannah',
              fontSize: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).loginToAccount,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontFamily: 'Jannah',
              fontSize: 17,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 25),

          // ── Email ──
          DefaultFormField(
            controller: emailController,
            type: TextInputType.emailAddress,
            label: Text(
              S.of(context).emailAddress,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Message,
            onFieldSubmitted: (value) {},
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterEmail;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ── Password ──
          DefaultFormField(
            controller: passwordController,
            type: TextInputType.visiblePassword,
            label: Text(
              S.of(context).password,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            prefix: IconBroken.Lock,
            suffix: cubit.suffix,
            isPassword: cubit.isPassword,
            suffixPressed: () => cubit.changePasswordVisibility(),
            onFieldSubmitted: (value) {},
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterPassword;
              }
              return null;
            },
          ),

          // ── Forgot password ──
          Container(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                showForgotPasswordSheet(context);
              },
              child: Text(
                S.of(context).forgetPassword,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.blue500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ── Login button ──
          PrimaryButton(
            label: S.of(context).logIn,
            isLoading: state is AuthLoadingState,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                cubit.userLogin(
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
          ),

          const SizedBox(height: 25),

          // ── Social sign in ──
          SocialSignInSection(
            onGooglePressed: () {
              RegisterCubit.get(context).signInWithGoogle();
            },
          ),

          // ── Sign up link ──
          AuthFooterLink(
            message: S.of(context).dontHaveAccount,
            actionLabel: S.of(context).signUp,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
