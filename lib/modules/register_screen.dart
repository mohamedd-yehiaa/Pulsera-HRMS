import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/login_screen.dart';
import '../shared/components/components.dart';
import '../shared/cubit/register_cubit.dart';
import '../shared/cubit/states.dart';
import '../shared/styles/colors.dart';
import '../shared/styles/icon_broken.dart';

class RegisterScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is CreateUserErrorState) {
            Fluttertoast.showToast(msg: state.error);
          }
          if (state is CreateUserSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeLayout()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          RegisterCubit cubit = RegisterCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(IconBroken.Arrow___Left, color: AppColors.primary),
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's Get Started!",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                fontFamily: 'Jannah',
                                fontSize: 30,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          'Register now to continue',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontFamily: 'Jannah',
                                fontSize: 17,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 30.0),
                        DefaultFormField(
                          controller: firstNameController,
                          type: TextInputType.name,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your first name';
                            }
                            return null;
                          },
                          label: Text(
                            'First Name',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                          ),
                          prefix: IconBroken.Profile,
                        ),
                        const SizedBox(height: 15.0),
                        DefaultFormField(
                          controller: lastNameController,
                          type: TextInputType.name,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your last name';
                            }
                            return null;
                          },
                          label: Text(
                            'Last Name',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                          ),
                          prefix: IconBroken.User,
                        ),
                        const SizedBox(height: 15.0),
                        DropdownButtonFormField<String>(
                          initialValue: cubit.selectedUserType,
                          decoration: InputDecoration(
                            fillColor: AppColors.grey100,
                            filled: true,
                            labelText: 'User Type',
                            prefixIcon: const Icon(
                              IconBroken.Bag_2,
                              color: AppColors.blue500,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            labelStyle: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                          ),
                          items: ['Company Owner', 'Employee']
                              .map(
                                (label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            cubit.changeUserType(value!);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your role';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15.0),
                        DefaultFormField(
                          controller: emailController,
                          type: TextInputType.emailAddress,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your email address';
                            }
                            return null;
                          },
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
                        ),
                        const SizedBox(height: 15.0),
                        DefaultFormField(
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          suffix: cubit.suffix,
                          isPassword: cubit.isPassword,
                          suffixPressed: () {
                            cubit.changePasswordVisibility();
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'password is too short';
                            }
                            return null;
                          },
                          label: Text(
                            'Password',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                          ),
                          prefix: IconBroken.Lock,
                        ),
                        const SizedBox(height: 15.0),
                        DefaultFormField(
                          controller: phoneController,
                          type: TextInputType.phone,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter your phone number';
                            }
                            return null;
                          },
                          label: Text(
                            'Phone Number',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                          ),
                          prefix: IconBroken.Call,
                        ),
                        const SizedBox(height: 30.0),
                        ConditionalBuilder(
                          condition: state is! RegisterLoadingState,
                          builder: (context) => Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.userRegister(
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    phone: phoneController.text,
                                  );
                                }
                              },
                              style: Theme.of(
                                context,
                              ).elevatedButtonTheme.style,
                              child: Text(
                                "Register",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                          fallback: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                        const SizedBox(height: 25.0),
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
                              cubit.signInWithGoogle();
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
                                  image: AssetImage('assets/images/google.png'),
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

                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
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
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Login',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: AppColors.blue500,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
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
