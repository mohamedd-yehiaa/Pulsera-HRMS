abstract class AppStates {}

class AppInitialState extends AppStates {}
class AppChangeBottomNavBarState extends AppStates {}
class AppChangeDateState extends AppStates {}
class GetUserLoadingState extends AppStates {}
class GetUserSuccessState extends AppStates {}
class GetUserErrorState extends AppStates {
  final String error;
  GetUserErrorState(this.error);
}
class GetCompanyLoadingState extends AppStates {}
class GetCompanySuccessState extends AppStates {}
class GetCompanyErrorState extends AppStates {
  final String error;
  GetCompanyErrorState(this.error);
}


// -----------------------------------------------------------------------------
// Attendance States
abstract class AttendanceStates {}

class AttendanceInitialState extends AttendanceStates {}
class AttendanceChangeDateState extends AttendanceStates {}
class AttendanceLoadingState extends AttendanceStates {}
class AttendanceErrorState extends AttendanceStates {
  final String error;
  AttendanceErrorState(this.error);
}
class AttendanceSuccessState extends AttendanceStates {}

// -----------------------------------------------------------------------------
// Auth States
abstract class AuthStates {}

class AuthInitialState extends AuthStates {}
class AuthSuccessState extends AuthStates {}
class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}
class AuthLoadingState extends AuthStates {}
class AuthChangePasswordVisibilityState extends AuthStates {}

// -----------------------------------------------------------------------------
// Register States
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
class CreateCompanyLoadingState extends RegisterStates {}
class CreateCompanySuccessState extends RegisterStates {}
class CreateCompanyChangeWorkingDaysState extends RegisterStates {}
class CreateCompanyTimeChangedState extends  RegisterStates {}
class CreateCompanyErrorState extends RegisterStates {
  final String error;
  CreateCompanyErrorState(this.error);
}




// -----------------------------------------------------------------------------
// Profile States
abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates{}
class ProfileLoadingState extends ProfileStates{}
class ProfileSuccessState extends ProfileStates{}
class ProfileErrorState extends ProfileStates {
  final String error;
  ProfileErrorState(this.error);
}
class ProfileUpdateLoadingState extends ProfileStates{}
class ProfileUpdateSuccessState extends ProfileStates{}
class ProfileUpdateErrorState extends ProfileStates {
  final String error;
  ProfileUpdateErrorState(this.error);
}
class UpdateCompanyLoadingState extends ProfileStates {}
class UpdateCompanySuccessState extends ProfileStates {}
class UpdateCompanyErrorState extends ProfileStates {
  final String error;
  UpdateCompanyErrorState(this.error);
}