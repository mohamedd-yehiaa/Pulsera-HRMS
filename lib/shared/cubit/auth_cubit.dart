import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';


class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);

  void userLogin({
    required String email,
    required String password,
  }) {

    emit(AuthLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      emit(AuthSuccessState(value.user!.uid));

    })
        .catchError((error)
    {
      emit(AuthErrorState(error.toString()));
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
    isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(AuthChangePasswordVisibilityState());
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(ResetPasswordLoadingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
      emit(ResetPasswordSuccessState());
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'invalid-email' => 'Invalid email format',
        'too-many-requests' => 'Too many attempts. Try again later',
        _ => 'Something went wrong. Please try again',
      };
      emit(ResetPasswordErrorState(msg));
    } catch (_) {
      emit(ResetPasswordErrorState('Check your internet connection'));
    }
  }
}