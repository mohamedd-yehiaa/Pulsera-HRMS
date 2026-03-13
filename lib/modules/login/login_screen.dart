import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/register/register_screen.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../../shared/components/components.dart';
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
          if (state is AuthErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is AuthSuccessState) {
            CacheHelper.saveData(
              key: 'uId',
              value: FirebaseAuth.instance.currentUser!.uid,
            ).then((value) {
              AppCubit.get(context).getUserData();
              AppCubit.get(context).getCompanyData();
              navigateAndFinish(context, HomeLayout());
            });
          }
        },
        builder: (context, state) {
          AuthCubit cubit = AuthCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.topCenter,
                              child: const Image(
                                fit: BoxFit.contain,
                                image: AssetImage('assets/images/logo.png'),
                              ),
                            ),
                            Positioned(
                              bottom: 30,
                              left: 5,
                              right: 0,
                              child: Text(
                                'Welcome back!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                  fontFamily: 'Jannah',
                                  fontSize: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 5,
                              right: 0,
                              child: Text(
                                'Login to your account',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                  fontFamily: 'Jannah',
                                  fontSize: 17,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
                        DefaultFormField(
                          controller: emailController,
                          type: TextInputType.emailAddress,
                          label: Text(
                            'Email Address',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          prefix: IconBroken.Message,
                          onFieldSubmitted: (value) => print(value),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        DefaultFormField(
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          label: Text(
                            "Password",
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          prefix: IconBroken.Lock,
                          suffix: cubit.suffix,
                          isPassword: cubit.isPassword,
                          suffixPressed: () =>
                              cubit.changePasswordVisibility(),
                          onFieldSubmitted: (value) => print(value),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your email address';
                            }
                            return null;
                          },
                        ),
                        Container(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () {
                              showForgotPasswordSheet(context);
                            },
                            child: Text(
                              'Forget Password?',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                color: AppColors.blue500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        ConditionalBuilder(
                          condition: state is! AuthLoadingState,
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                cubit.userLogin(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                            style: Theme.of(
                              context,
                            ).elevatedButtonTheme.style,
                            child: Text(
                              "LOG IN",
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                          fallback: (BuildContext context) =>
                              Center(child: CircularProgressIndicator()),
                        ),
                        const SizedBox(height: 25.0),

                        // THE SOCIAL DIVIDER
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "Or continue with social account",
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),

                        const SizedBox(height: 24.0),

                        // THE GOOGLE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              RegisterCubit.get(context).signInWithGoogle();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(
                                    'assets/images/google.png',
                                  ),
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Google',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                    color: AppColors.grey700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 45.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                    color: AppColors.blue500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
