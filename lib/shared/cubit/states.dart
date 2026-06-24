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
class AttendanceSuccessState extends AttendanceStates {}
class AttendanceLoadingState extends AttendanceStates {}
class AttendanceErrorState extends AttendanceStates {
  final String error;
  AttendanceErrorState(this.error);
}
class AttendanceValidationErrorState extends AttendanceStates {
  final String error;
  AttendanceValidationErrorState(this.error);
}
/// Emitted while a swipe action is in progress (prevents double-swipe).
class AttendanceActionInProgressState extends AttendanceStates {}
/// Emitted once after a successful attendance action with an optional feedback message.
class AttendanceActionCompletedState extends AttendanceStates {
  final String? message;
  AttendanceActionCompletedState({this.message});
}
/// States for admin team attendance view.
class TeamAttendanceLoadingState extends AttendanceStates {}
class TeamAttendanceLoadedState extends AttendanceStates {}
class TeamAttendanceErrorState extends AttendanceStates {
  final String error;
  TeamAttendanceErrorState(this.error);
}

/// QR location validation states — decoupled from attendance logic.
class LocationScanningState extends AttendanceStates {}
class LocationVerifiedState extends AttendanceStates {}
class LocationValidationFailedState extends AttendanceStates {
  final String error;
  LocationValidationFailedState(this.error);
}


// -----------------------------------------------------------------------------
// Auth States
abstract class AuthStates {}

class AuthInitialState extends AuthStates {}
class AuthLoadingState extends AuthStates {}
class AuthSuccessState extends AuthStates {
  final String uId;
  AuthSuccessState(this.uId);
}
class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}
class AuthChangePasswordVisibilityState extends AuthStates {}

// Reset Password States
class ResetPasswordLoadingState extends AuthStates {}
class ResetPasswordSuccessState extends AuthStates {}
class ResetPasswordErrorState extends AuthStates {
  final String error;
  ResetPasswordErrorState(this.error);
}

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
class CreateCompanyLoadingState extends RegisterStates {}
class CreateCompanySuccessState extends RegisterStates {
  final String companyId;
  CreateCompanySuccessState(this.companyId);
}
class CreateCompanyChangeWorkingDaysState extends RegisterStates {}
class CreateCompanyTimeChangedState extends  RegisterStates {}
class CreateCompanyErrorState extends RegisterStates {
  final String error;
  CreateCompanyErrorState(this.error);
}
class RegisterChangePasswordVisibilityState extends RegisterStates {}




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
class ProfileImagePickedSuccessState extends ProfileStates {}
class ProfileImagePickedErrorState extends ProfileStates {
  final String error;
  ProfileImagePickedErrorState(this.error);
}
class ProfileRemoveImageLoadingState extends ProfileStates {}
class ProfileRemoveImageSuccessState extends ProfileStates {}
class ProfileRemoveImageErrorState extends ProfileStates {
  final String error;
  ProfileRemoveImageErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Leave States
abstract class LeaveStates {}

class LeaveInitialState extends LeaveStates {}

// Get Leaves States
class GetLeavesLoadingState extends LeaveStates {}
class GetLeavesSuccessState extends LeaveStates {}
class GetLeavesErrorState extends LeaveStates {
  final String error;
  GetLeavesErrorState(this.error);
}

// Update Leave States (Approve/Reject)
class UpdateLeaveLoadingState extends LeaveStates {}
class UpdateLeaveSuccessState extends LeaveStates {}
class UpdateLeaveErrorState extends LeaveStates {
  final String error;
  UpdateLeaveErrorState(this.error);
}
class GetLeavesTabChangedState extends LeaveStates {}
class ChangeMyDataState extends LeaveStates {}

// Cancel Leave States
class CancelLeaveLoadingState extends LeaveStates {}
class CancelLeaveSuccessState extends LeaveStates {}
class CancelLeaveErrorState extends LeaveStates {
  final String error;
  CancelLeaveErrorState(this.error);
}

// Vacation Balance
class VacationBalanceLoadedState extends LeaveStates {}
class LeaveBalanceResetState extends LeaveStates {}

// Stream Error
class LeaveStreamErrorState extends LeaveStates {
  final String error;
  LeaveStreamErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Apply Leave States
abstract class ApplyLeaveStates {}

class ApplyLeaveInitialState extends ApplyLeaveStates {}
class ApplyLeaveLoadingState extends ApplyLeaveStates {}
class ApplyLeaveSuccessState extends ApplyLeaveStates {}
class ApplyLeaveErrorState extends ApplyLeaveStates {
  final String error;
  ApplyLeaveErrorState(this.error);
}
class ApplyLeaveTeamLoadedState extends ApplyLeaveStates {}
class ApplyLeaveFieldChangedState extends ApplyLeaveStates {}
class ApplyLeaveValidationErrorState extends ApplyLeaveStates {
  final String error;
  ApplyLeaveValidationErrorState(this.error);
}
class ApplyLeaveOverlapErrorState extends ApplyLeaveStates {
  final String error;
  ApplyLeaveOverlapErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Payroll States
abstract class PayrollStates {}

class PayrollInitialState extends PayrollStates {}
class PayrollLoadingState extends PayrollStates {}
class PayrollGeneratingState extends PayrollStates {}
class PayrollGeneratedSuccessState extends PayrollStates {}
class PayrollLoadedState extends PayrollStates {}
class PayrollErrorState extends PayrollStates {
  final String error;
  PayrollErrorState(this.error);
}
class PayrollMonthChangedState extends PayrollStates {}
class PayrollOverrideConfirmState extends PayrollStates {}

// -----------------------------------------------------------------------------
// Payroll Config States
abstract class PayrollConfigStates {}

class PayrollConfigInitialState extends PayrollConfigStates {}
class PayrollConfigLoadingState extends PayrollConfigStates {}
class PayrollConfigLoadedState extends PayrollConfigStates {}
class PayrollConfigSavedState extends PayrollConfigStates {}
class PayrollConfigErrorState extends PayrollConfigStates {
  final String error;
  PayrollConfigErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Team States
abstract class TeamStates {}

class TeamInitialState extends TeamStates {}
class TeamLoadingState extends TeamStates {}
class TeamMembersLoadedState extends TeamStates {}
class TeamMemberAddedState extends TeamStates {}
class TeamUserValidatedState extends TeamStates {}
class TeamUserValidationErrorState extends TeamStates {
  final String error;
  TeamUserValidationErrorState(this.error);
}
class TeamErrorState extends TeamStates {
  final String error;
  TeamErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Notification States
abstract class NotificationStates {}

class NotificationInitialState extends NotificationStates {}
class NotificationsLoadedState extends NotificationStates {}
class NotificationMarkedReadState extends NotificationStates {}
class NotificationAllMarkedReadState extends NotificationStates {}
class NotificationsClearedState extends NotificationStates {}
class NotificationStreamErrorState extends NotificationStates {
  final String error;
  NotificationStreamErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Kiosk States
abstract class KioskStates {}

class KioskInitialState extends KioskStates {}
class KioskLoadingState extends KioskStates {}
class KioskCreateSuccessState extends KioskStates {}
class KioskCreateErrorState extends KioskStates {
  final String error;
  KioskCreateErrorState(this.error);
}
class KioskFetchLoadingState extends KioskStates {}
class KioskFetchedState extends KioskStates {}
class KioskNotFoundState extends KioskStates {}
class KioskFetchErrorState extends KioskStates {
  final String error;
  KioskFetchErrorState(this.error);
}
class KioskChangePasswordLoadingState extends KioskStates {}
class KioskChangePasswordSuccessState extends KioskStates {}
class KioskChangePasswordErrorState extends KioskStates {
  final String error;
  KioskChangePasswordErrorState(this.error);
}

// -----------------------------------------------------------------------------
// Localization States
abstract class LocalizationStates {}

class LocalizationInitialState extends LocalizationStates {}

class ChangeLanguageState extends LocalizationStates {
  final String locale;
  ChangeLanguageState(this.locale);
}
