import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppStates {}

class AppInitialState extends AppStates {}
class AppChangeBottomNavBarState extends AppStates {}
class AppChangeDateState extends AppStates {}
class GetUserLoadingState extends AppStates {}
class GetUserSuccessState extends AppStates {}
class SocialGetUserErrorState extends AppStates {
  final String error;
  SocialGetUserErrorState(this.error);
}



abstract class AttendanceStates {}

class AttendanceInitialState extends AttendanceStates {}
class AttendanceChangeDateState extends AttendanceStates {}
class AttendanceLoadingState extends AttendanceStates {}
class AttendanceErrorState extends AttendanceStates {
  final String error;
  AttendanceErrorState(this.error);
}
class AttendanceSuccessState extends AttendanceStates {}


abstract class AuthStates {}

class AuthInitialState extends AuthStates {}
class AuthSuccessState extends AuthStates {}
class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}
class AuthLoadingState extends AuthStates {}
class AuthChangePasswordVisibilityState extends AuthStates {}


abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}
class RegisterLoadingState extends RegisterStates {}
class RegisterSuccessState extends RegisterStates {}
class RegisterChangeUserTypeState extends RegisterStates {}
class RegisterErrorState extends RegisterStates {
  final String error;
  RegisterErrorState(this.error);
}
class GoogleSignInLoadingState extends RegisterStates {}
class GoogleSignInSuccessState extends RegisterStates {}
class GoogleSignInErrorState extends RegisterStates {
  final String error;
  GoogleSignInErrorState(this.error);
}
class CreateUserSuccessState extends RegisterStates {}
class CreateUserErrorState extends RegisterStates {
  final String error;
  CreateUserErrorState(this.error);
}
class RegisterChangePasswordVisibilityState extends RegisterStates {}