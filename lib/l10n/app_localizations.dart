import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Bottom nav / sidebar label for Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav / sidebar label for Leave tab
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get navLeave;

  /// Sidebar label for Team tab
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get navTeam;

  /// Bottom nav / sidebar label for Payroll tab
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get navPayroll;

  /// Bottom nav / sidebar label for Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// AppBar greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Top bar welcome text with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String welcomeUser(String name);

  /// Leave tab AppBar title
  ///
  /// In en, this message translates to:
  /// **'All Leaves'**
  String get allLeaves;

  /// Payroll tab AppBar title
  ///
  /// In en, this message translates to:
  /// **'Payroll History'**
  String get payrollHistory;

  /// Apply leave button tooltip / title
  ///
  /// In en, this message translates to:
  /// **'Apply Leave'**
  String get applyLeave;

  /// Payroll config button tooltip
  ///
  /// In en, this message translates to:
  /// **'Payroll Settings'**
  String get payrollSettings;

  /// Settings AppBar upload photo button
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// Top bar save photo button (desktop)
  ///
  /// In en, this message translates to:
  /// **'Save Photo'**
  String get savePhoto;

  /// Settings AppBar remove photo button
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Forgot password sheet title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// Forgot password sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// Success banner title after reset email sent
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your inbox.'**
  String get resetLinkSent;

  /// Success banner description
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox. If you don\'t see it, check your spam/junk folder.'**
  String get resetLinkSentDescription;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email validation - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmail;

  /// Email validation - invalid format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Cooldown button text
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// Button text after reset link already sent
  ///
  /// In en, this message translates to:
  /// **'Resend Reset Link'**
  String get resendResetLink;

  /// Initial send reset link button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Auth branding panel default headline
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pulsera'**
  String get welcomeToPulsera;

  /// Auth branding panel default subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your workforce with ease\nand efficiency.'**
  String get managePulseraSubtitle;

  /// Social sign-in divider text
  ///
  /// In en, this message translates to:
  /// **'Or continue with social account'**
  String get orContinueWithSocial;

  /// Google sign-in button label
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// Leave card date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Leave card / home screen total days label
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDaysLabel;

  /// Leave card days count
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String nDays(int count);

  /// Leave card employee label
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// Leave card approval label
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get approval;

  /// Leave card reason label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// Leave approve button
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Leave reject button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Cancel leave button / dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Leave'**
  String get cancelLeave;

  /// Cancel approved leave confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this approved leave? Your vacation days will be restored.'**
  String get cancelApprovedLeaveMessage;

  /// Cancel pending leave confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this pending leave request?'**
  String get cancelPendingLeaveMessage;

  /// Status label for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Status label for approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Status label for rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Status label for cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No button in dialogs
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Yes cancel confirmation button
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// Rejected reason label on leave card
  ///
  /// In en, this message translates to:
  /// **'Rejected Reason'**
  String get rejectedReason;

  /// Check in label / swipe button
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// Check out label
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// Break in activity card title
  ///
  /// In en, this message translates to:
  /// **'Break In'**
  String get breakIn;

  /// Break out activity card title
  ///
  /// In en, this message translates to:
  /// **'Break Out'**
  String get breakOut;

  /// Prompt for company owner without company
  ///
  /// In en, this message translates to:
  /// **'Please Register your Company Details!'**
  String get registerCompanyPrompt;

  /// Create company button
  ///
  /// In en, this message translates to:
  /// **'Create Company'**
  String get createCompany;

  /// Prompt for employee without company
  ///
  /// In en, this message translates to:
  /// **'Please join a company to continue!'**
  String get joinCompanyPrompt;

  /// Instruction for employee to share their ID
  ///
  /// In en, this message translates to:
  /// **'Give your Id to the company'**
  String get giveIdToCompany;

  /// Snackbar after copying ID
  ///
  /// In en, this message translates to:
  /// **'Copied to your clipboard !'**
  String get copiedToClipboard;

  /// Refresh status button
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// Section header on home screen
  ///
  /// In en, this message translates to:
  /// **'Today Attendance'**
  String get todayAttendance;

  /// Section header on home screen
  ///
  /// In en, this message translates to:
  /// **'Your Activity'**
  String get yourActivity;

  /// Info card label
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// Info card label
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// Break button label
  ///
  /// In en, this message translates to:
  /// **'Take a Break'**
  String get takeABreak;

  /// Time details section header
  ///
  /// In en, this message translates to:
  /// **'Time Details'**
  String get timeDetails;

  /// Late minutes detail
  ///
  /// In en, this message translates to:
  /// **'Late by {minutes} min'**
  String lateByMinutes(int minutes);

  /// Early leave detail
  ///
  /// In en, this message translates to:
  /// **'Left {minutes} min early'**
  String leftEarlyMinutes(int minutes);

  /// Overtime detail
  ///
  /// In en, this message translates to:
  /// **'Overtime: {minutes} min'**
  String overtimeMinutes(int minutes);

  /// Toast after QR location verification
  ///
  /// In en, this message translates to:
  /// **'Location Verified'**
  String get locationVerified;

  /// Confirm action dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// Cancel button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Check-in status label
  ///
  /// In en, this message translates to:
  /// **'Early'**
  String get statusEarly;

  /// Check-in status label
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get statusOnTime;

  /// Check-in status label
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// Check-in status label
  ///
  /// In en, this message translates to:
  /// **'Very Late'**
  String get statusVeryLate;

  /// Check-out status label
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get statusEarlyLeave;

  /// Check-out status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Check-out status label
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get statusOvertime;

  /// Check-out status label
  ///
  /// In en, this message translates to:
  /// **'Insufficient Hours'**
  String get statusInsufficientHours;

  /// QR scanner success overlay text
  ///
  /// In en, this message translates to:
  /// **'QR Scanned'**
  String get qrScanned;

  /// QR scanner bottom instruction after scan
  ///
  /// In en, this message translates to:
  /// **'QR Scanned!'**
  String get qrScannedExclamation;

  /// QR scanner instruction text
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the QR code'**
  String get pointCameraAtQr;

  /// Login screen header
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBackExclamation;

  /// Login screen subheader
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// Password validation - empty
  ///
  /// In en, this message translates to:
  /// **'please enter your password'**
  String get pleaseEnterPassword;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get logIn;

  /// Auth footer link message (login)
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Auth footer link action (login)
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Desktop login branding headline
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBackBranding;

  /// Desktop login branding subtitle
  ///
  /// In en, this message translates to:
  /// **'Streamline your HR operations.\nAttendance, payroll, and team management\nin one place.'**
  String get loginBrandingSubtitle;

  /// Register screen header
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get letsGetStarted;

  /// Register screen subheader
  ///
  /// In en, this message translates to:
  /// **'Register now to continue'**
  String get registerNowToContinue;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// First name validation
  ///
  /// In en, this message translates to:
  /// **'please enter your first name'**
  String get pleaseEnterFirstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Last name validation
  ///
  /// In en, this message translates to:
  /// **'please enter your last name'**
  String get pleaseEnterLastName;

  /// User type dropdown label
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// User type option
  ///
  /// In en, this message translates to:
  /// **'Company Owner'**
  String get companyOwner;

  /// User type option
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employeeRole;

  /// User type validation
  ///
  /// In en, this message translates to:
  /// **'Please select your role'**
  String get pleaseSelectRole;

  /// Password validation
  ///
  /// In en, this message translates to:
  /// **'password is too short'**
  String get passwordTooShort;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password empty validation
  ///
  /// In en, this message translates to:
  /// **'please confirm your password'**
  String get pleaseConfirmPassword;

  /// Confirm password match validation
  ///
  /// In en, this message translates to:
  /// **'passwords do not match'**
  String get passwordsDoNotMatch;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone validation
  ///
  /// In en, this message translates to:
  /// **'please enter your phone number'**
  String get pleaseEnterPhone;

  /// Register button label
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Auth footer link message (register)
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Auth footer link action (register)
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Desktop register branding headline
  ///
  /// In en, this message translates to:
  /// **'Join Pulsera'**
  String get joinPulsera;

  /// Desktop register branding subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account and start\nmanaging your team efficiently.'**
  String get registerBrandingSubtitle;

  /// Register company AppBar title
  ///
  /// In en, this message translates to:
  /// **'Organization Setup'**
  String get organizationSetup;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Organization Details'**
  String get organizationDetails;

  /// Organization name field label
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationName;

  /// Generic required field validation
  ///
  /// In en, this message translates to:
  /// **'This field can\'t be empty'**
  String get fieldCantBeEmpty;

  /// Paid leave field label
  ///
  /// In en, this message translates to:
  /// **'Per Month Paid Leave'**
  String get perMonthPaidLeave;

  /// Sick leave field label
  ///
  /// In en, this message translates to:
  /// **'Per Month Sick/Casual Leave'**
  String get perMonthSickCasualLeave;

  /// WFH field label
  ///
  /// In en, this message translates to:
  /// **'Per Month Work From Home'**
  String get perMonthWorkFromHome;

  /// Start time picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get selectStartTime;

  /// End time picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select end time'**
  String get selectEndTime;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Attendance Rules'**
  String get attendanceRules;

  /// Grace period field label
  ///
  /// In en, this message translates to:
  /// **'Grace Period (minutes)'**
  String get gracePeriodMinutes;

  /// Early check-in allowance field label
  ///
  /// In en, this message translates to:
  /// **'Early Check-in Allowance (minutes)'**
  String get earlyCheckInAllowance;

  /// Late cutoff field label
  ///
  /// In en, this message translates to:
  /// **'Late Cut-off (minutes)'**
  String get lateCutoffMinutes;

  /// Minimum work hours field label
  ///
  /// In en, this message translates to:
  /// **'Minimum Work Hours'**
  String get minimumWorkHours;

  /// Register company submit button
  ///
  /// In en, this message translates to:
  /// **'Register Organization'**
  String get registerOrganization;

  /// Toast when time not selected
  ///
  /// In en, this message translates to:
  /// **'Please select working hours'**
  String get pleaseSelectWorkingHours;

  /// Toast on successful company registration
  ///
  /// In en, this message translates to:
  /// **'Company Registered Successfully'**
  String get companyRegisteredSuccessfully;

  /// Leave stats card label
  ///
  /// In en, this message translates to:
  /// **'Leave\nBalance'**
  String get leaveBalance;

  /// Leave stats card label
  ///
  /// In en, this message translates to:
  /// **'Leave\nApproved'**
  String get leaveApproved;

  /// Leave stats card label
  ///
  /// In en, this message translates to:
  /// **'Leave\nPending'**
  String get leavePending;

  /// Leave stats card label
  ///
  /// In en, this message translates to:
  /// **'Leave\nRejected'**
  String get leaveRejected;

  /// My data toggle label
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get my;

  /// Other data toggle label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No Data found.'**
  String get noDataFound;

  /// Toast after leave status update
  ///
  /// In en, this message translates to:
  /// **'Leave Status Updated'**
  String get leaveStatusUpdated;

  /// Toast after leave cancellation
  ///
  /// In en, this message translates to:
  /// **'Leave Cancelled — Days Restored'**
  String get leaveCancelledDaysRestored;

  /// Reject leave dialog title
  ///
  /// In en, this message translates to:
  /// **'Reject Leave'**
  String get rejectLeave;

  /// Rejection reason hint text
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection (optional)'**
  String get enterRejectionReason;

  /// Apply leave vacation balance label
  ///
  /// In en, this message translates to:
  /// **'Remaining Vacation Days'**
  String get remainingVacationDays;

  /// Days count value text
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String nDaysValue(int count);

  /// Apply leave assigned admin label
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// Fallback text for team admin name
  ///
  /// In en, this message translates to:
  /// **'Team Admin'**
  String get teamAdmin;

  /// Error when employee has no team
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any team. Contact your manager.'**
  String get notAssignedToTeam;

  /// Start date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// End date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// Total days preview
  ///
  /// In en, this message translates to:
  /// **'Total: {count} day{suffix}'**
  String totalNDays(int count, String suffix);

  /// Leave reason field label
  ///
  /// In en, this message translates to:
  /// **'Reason for leave'**
  String get reasonForLeave;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Submit leave request button
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// Toast after leave submission
  ///
  /// In en, this message translates to:
  /// **'Leave Request Submitted'**
  String get leaveRequestSubmitted;

  /// Leave status - pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Leave status - approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// Leave status - rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Leave status - cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'My Company'**
  String get myCompany;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select Language item label
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Business Tools'**
  String get businessTools;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get generateQrCode;

  /// Settings menu item / dialog button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// Logout dialog title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Edit profile button / screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Toast after profile update
  ///
  /// In en, this message translates to:
  /// **'Profile Updated Successfully'**
  String get profileUpdatedSuccessfully;

  /// Company details screen title
  ///
  /// In en, this message translates to:
  /// **'Company Details'**
  String get companyDetails;

  /// Edit company screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Company'**
  String get editCompany;

  /// Toast after company update
  ///
  /// In en, this message translates to:
  /// **'Company Updated Successfully'**
  String get companyUpdatedSuccessfully;

  /// Team members screen title
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// Add team member screen title
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get addTeamMember;

  /// Empty state for team members
  ///
  /// In en, this message translates to:
  /// **'No team members yet'**
  String get noTeamMembers;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Empty state for notifications
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// Mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Kiosk mode title
  ///
  /// In en, this message translates to:
  /// **'Kiosk Mode'**
  String get kioskMode;

  /// Kiosk account section title
  ///
  /// In en, this message translates to:
  /// **'Kiosk Account'**
  String get kioskAccount;

  /// Fallback user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Start time label
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// End time label
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Working days label
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingDays;

  /// Work schedule section header
  ///
  /// In en, this message translates to:
  /// **'Work Schedule'**
  String get workSchedule;

  /// Leave policy section header
  ///
  /// In en, this message translates to:
  /// **'Leave Policy'**
  String get leavePolicy;

  /// Paid leave label
  ///
  /// In en, this message translates to:
  /// **'Paid Leave'**
  String get paidLeave;

  /// Sick/casual leave label
  ///
  /// In en, this message translates to:
  /// **'Sick/Casual Leave'**
  String get sickCasualLeave;

  /// Work from home label
  ///
  /// In en, this message translates to:
  /// **'Work From Home'**
  String get workFromHome;

  /// Days per month value
  ///
  /// In en, this message translates to:
  /// **'{count} days/month'**
  String daysPerMonth(String count);

  /// Grace period label
  ///
  /// In en, this message translates to:
  /// **'Grace Period'**
  String get gracePeriod;

  /// Minutes value
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String nMinutes(String count);

  /// QR scan instruction
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// Employee ID field label
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// Employee ID validation
  ///
  /// In en, this message translates to:
  /// **'Please enter employee ID'**
  String get pleaseEnterEmployeeId;

  /// Add member button label
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// Toast after adding member
  ///
  /// In en, this message translates to:
  /// **'Member added successfully'**
  String get memberAddedSuccessfully;

  /// Role type dropdown label
  ///
  /// In en, this message translates to:
  /// **'Role Type'**
  String get roleType;

  /// Role type option
  ///
  /// In en, this message translates to:
  /// **'Hr admin'**
  String get hrAdmin;

  /// Role type option
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberRole;

  /// Manager label
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// Remove button label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Remove member dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// Remove member confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member?'**
  String get removeMemberConfirmation;

  /// Employee attendance screen title
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// Attendance status present
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// Attendance status absent
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// Empty state attendance
  ///
  /// In en, this message translates to:
  /// **'No attendance data found'**
  String get noAttendanceData;

  /// Payroll basic salary label
  ///
  /// In en, this message translates to:
  /// **'Basic Salary'**
  String get basicSalary;

  /// Payroll deductions label
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductions;

  /// Payroll net salary label
  ///
  /// In en, this message translates to:
  /// **'Net Salary'**
  String get netSalary;

  /// Generate payroll button / screen title
  ///
  /// In en, this message translates to:
  /// **'Generate Payroll'**
  String get generatePayroll;

  /// Payslip detail screen title
  ///
  /// In en, this message translates to:
  /// **'Payslip Details'**
  String get payslipDetails;

  /// Empty state payroll
  ///
  /// In en, this message translates to:
  /// **'No payroll data found'**
  String get noPayrollData;

  /// Month label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Toast after payroll generation
  ///
  /// In en, this message translates to:
  /// **'Payroll generated successfully'**
  String get payrollGenerated;

  /// Create kiosk button
  ///
  /// In en, this message translates to:
  /// **'Create Kiosk Account'**
  String get createKioskAccount;

  /// Kiosk email field label
  ///
  /// In en, this message translates to:
  /// **'Kiosk Email'**
  String get kioskEmail;

  /// Kiosk password field label
  ///
  /// In en, this message translates to:
  /// **'Kiosk Password'**
  String get kioskPassword;

  /// Toast after kiosk creation
  ///
  /// In en, this message translates to:
  /// **'Kiosk account created successfully'**
  String get kioskAccountCreated;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Toast after password change
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Company label
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// Role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Section header in profile
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// Section header in profile
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get companyInfo;

  /// QR code screen title
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCodeTitle;

  /// QR code screen instructions
  ///
  /// In en, this message translates to:
  /// **'Display this QR code at your office entrance for employees to scan during check-in/check-out.'**
  String get qrCodeInstructions;

  /// Refresh QR code button
  ///
  /// In en, this message translates to:
  /// **'Refresh QR Code'**
  String get refreshQrCode;

  /// Kiosk setup section title
  ///
  /// In en, this message translates to:
  /// **'Kiosk Setup'**
  String get kioskSetupTitle;

  /// Kiosk setup description
  ///
  /// In en, this message translates to:
  /// **'Create a dedicated kiosk account for a fixed device at your office entrance.'**
  String get kioskSetupDescription;

  /// Message when kiosk already created
  ///
  /// In en, this message translates to:
  /// **'Kiosk account already exists'**
  String get kioskExists;

  /// Shows current kiosk email
  ///
  /// In en, this message translates to:
  /// **'Current kiosk email: {email}'**
  String kioskCurrentEmail(String email);

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Days Worked'**
  String get daysWorked;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Late Days'**
  String get lateDays;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Early Leave Days'**
  String get earlyLeaveDays;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Overtime Days'**
  String get overtimeDays;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Total Late Minutes'**
  String get totalLateMinutes;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Total Overtime Minutes'**
  String get totalOvertimeMinutes;

  /// Employee attendance stat
  ///
  /// In en, this message translates to:
  /// **'Missing Checkout'**
  String get missingCheckout;

  /// Payroll month selector
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// Salary label
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// Bonus label
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// Allowance label
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// Tax label
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Insurance label
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// Penalties label
  ///
  /// In en, this message translates to:
  /// **'Penalties'**
  String get penalties;

  /// Other deductions label
  ///
  /// In en, this message translates to:
  /// **'Other Deductions'**
  String get otherDeductions;

  /// Total earnings label
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// Total deductions label
  ///
  /// In en, this message translates to:
  /// **'Total Deductions'**
  String get totalDeductions;

  /// Payroll config screen title
  ///
  /// In en, this message translates to:
  /// **'Payroll Configuration'**
  String get payrollConfig;

  /// Toast after payroll config save
  ///
  /// In en, this message translates to:
  /// **'Payroll configuration saved'**
  String get payrollSaved;

  /// Pay period label
  ///
  /// In en, this message translates to:
  /// **'Pay Period'**
  String get payPeriod;

  /// Monthly pay period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Team members search hint
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get searchMembers;

  /// View attendance button on team member card
  ///
  /// In en, this message translates to:
  /// **'View Attendance'**
  String get viewAttendance;

  /// Empty search results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Time ago in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeAgoMinutes(int minutes);

  /// Time ago in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeAgoHours(int hours);

  /// Time ago in days
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeAgoDays(int days);

  /// Time ago - just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Kiosk QR screen instruction
  ///
  /// In en, this message translates to:
  /// **'Scan to Check In'**
  String get scanToCheckIn;

  /// Kiosk check-in success
  ///
  /// In en, this message translates to:
  /// **'Check-in successful!'**
  String get checkInSuccessful;

  /// Kiosk check-out success
  ///
  /// In en, this message translates to:
  /// **'Check-out successful!'**
  String get checkOutSuccessful;

  /// Invalid QR code error
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQrCode;

  /// Employee not found error
  ///
  /// In en, this message translates to:
  /// **'Employee not found'**
  String get employeeNotFound;

  /// Kiosk logout button
  ///
  /// In en, this message translates to:
  /// **'Exit Kiosk'**
  String get kioskLogout;

  /// Employee attendance stat label
  ///
  /// In en, this message translates to:
  /// **'Early Leave Minutes'**
  String get earlyLeaveMinutes;

  /// Payroll override dialog title
  ///
  /// In en, this message translates to:
  /// **'Override Existing Payroll'**
  String get overrideConfirmTitle;

  /// Payroll override dialog message
  ///
  /// In en, this message translates to:
  /// **'Payroll has already been generated for this period. Do you want to override it?'**
  String get overrideConfirmMessage;

  /// Override button
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get overrideBtn;

  /// Team screen title for managers
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get myTeam;

  /// Team screen title for employees
  ///
  /// In en, this message translates to:
  /// **'Team Info'**
  String get teamInfo;

  /// Team members search bar hint
  ///
  /// In en, this message translates to:
  /// **'Search team members'**
  String get searchTeamMembers;

  /// Member count label that handles plurals automatically
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Member} other{{count} Members}}'**
  String nMembersCount(int count);

  /// Add member button label
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMemberButton;

  /// Empty state hint for team members
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Member\" to assign employees to your team.'**
  String get tapAddMemberHint;

  /// Remove member confirmation with name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from your team?'**
  String removeMemberConfirmationName(String name);

  /// Employee not in a team
  ///
  /// In en, this message translates to:
  /// **'Not assigned to any team yet'**
  String get notAssignedToTeamYet;

  /// My manager section header
  ///
  /// In en, this message translates to:
  /// **'My Manager'**
  String get myManager;

  /// No manager assigned message
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any manager yet.'**
  String get notAssignedToManager;

  /// Vacation balance section header
  ///
  /// In en, this message translates to:
  /// **'Vacation Balance'**
  String get vacationBalance;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Remaining label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Used label
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedLabel;

  /// Days per month short label
  ///
  /// In en, this message translates to:
  /// **'days/Month'**
  String get daysPerMonthShort;

  /// Days left label
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// Days label
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// Salary info section header
  ///
  /// In en, this message translates to:
  /// **'Salary Info'**
  String get salaryInfo;

  /// Monthly salary label
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary'**
  String get monthlySalary;

  /// Employee user ID field label
  ///
  /// In en, this message translates to:
  /// **'Employee UserID'**
  String get employeeUserId;

  /// Validating button text
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get validating;

  /// Validate button text
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validateButton;

  /// Contract details section header
  ///
  /// In en, this message translates to:
  /// **'Contract Details'**
  String get contractDetails;

  /// Contract details description
  ///
  /// In en, this message translates to:
  /// **'Define the employee\'s salary and vacation allowance.'**
  String get contractDetailsDescription;

  /// Employee role dropdown label
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employeeRoleLabel;

  /// HR Admin role dropdown label
  ///
  /// In en, this message translates to:
  /// **'HR Admin'**
  String get hrAdminRoleLabel;

  /// Monthly salary validation
  ///
  /// In en, this message translates to:
  /// **'Please enter the monthly salary'**
  String get pleaseEnterMonthlySalary;

  /// Invalid salary validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid salary amount'**
  String get pleaseEnterValidSalary;

  /// Monthly vacation days field label
  ///
  /// In en, this message translates to:
  /// **'Monthly Vacation Days'**
  String get monthlyVacationDays;

  /// Vacation days validation
  ///
  /// In en, this message translates to:
  /// **'Please enter vacation days'**
  String get pleaseEnterVacationDays;

  /// Invalid days validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of days'**
  String get pleaseEnterValidDays;

  /// Add to team button label
  ///
  /// In en, this message translates to:
  /// **'Add to Team'**
  String get addToTeam;

  /// Employee attendance screen title
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Attendance'**
  String employeeAttendanceTitle(String name);

  /// Worked hours label
  ///
  /// In en, this message translates to:
  /// **'Worked Hours'**
  String get workedHours;

  /// Persisted worked minutes label
  ///
  /// In en, this message translates to:
  /// **'Persisted Worked Minutes'**
  String get persistedWorkedMinutes;

  /// Minutes value
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String nMin(String count);

  /// Break details section header
  ///
  /// In en, this message translates to:
  /// **'Break Details'**
  String get breakDetails;

  /// Break number label
  ///
  /// In en, this message translates to:
  /// **'Break {n}:'**
  String breakN(int n);

  /// Edit attendance status button/dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Attendance Status'**
  String get editAttendanceStatus;

  /// Edit check-in time dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Check-In Time'**
  String get editCheckInTime;

  /// Edit check-out time dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Check-Out Time'**
  String get editCheckOutTime;

  /// Time format hint
  ///
  /// In en, this message translates to:
  /// **'Time (HH:mm:ss)'**
  String get timeFormatHint;

  /// Early check-in status label
  ///
  /// In en, this message translates to:
  /// **'Early Check-in'**
  String get earlyCheckInLabel;

  /// Late status label in attendance
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateLabel;

  /// Early leave label in attendance
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get earlyLeaveLabel;

  /// Overtime label in attendance
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtimeLabel;

  /// Exit kiosk mode dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit Kiosk Mode'**
  String get exitKioskMode;

  /// Kiosk exit dialog description
  ///
  /// In en, this message translates to:
  /// **'Enter your password to exit kiosk mode.'**
  String get enterPasswordToExit;

  /// Password validation in kiosk exit
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// Incorrect password error
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get incorrectPassword;

  /// Exit button label
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// QR not configured title
  ///
  /// In en, this message translates to:
  /// **'QR Verification Not Configured'**
  String get qrNotConfigured;

  /// QR not configured description
  ///
  /// In en, this message translates to:
  /// **'Please ask an admin to generate a shared secret from the QR Code Generator in Settings.'**
  String get qrNotConfiguredDescription;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Kiosk mode active info title
  ///
  /// In en, this message translates to:
  /// **'Kiosk Mode Active'**
  String get kioskModeActive;

  /// Kiosk mode instructions
  ///
  /// In en, this message translates to:
  /// **'Display this screen at your office entrance. Employees must scan this QR code before checking in, taking breaks, or checking out. The code refreshes every 5 seconds for security.'**
  String get kioskModeDescription;

  /// QR refresh countdown
  ///
  /// In en, this message translates to:
  /// **'Refreshes in {seconds}s'**
  String refreshesIn(int seconds);

  /// Profile details screen title
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Fallback when a field value is missing
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'UserName'**
  String get userName;

  /// Save changes button label
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Edit organization tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Organization Details'**
  String get editOrganizationDetails;

  /// Toast after org update
  ///
  /// In en, this message translates to:
  /// **'Organization Details Updated'**
  String get organizationDetailsUpdated;

  /// Edit organization screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Organization'**
  String get editOrganization;

  /// Error when company ID is missing
  ///
  /// In en, this message translates to:
  /// **'Company ID not found'**
  String get companyIdNotFound;

  /// QR code generator screen title
  ///
  /// In en, this message translates to:
  /// **'QR Code Generator'**
  String get qrCodeGenerator;

  /// QR setup view title
  ///
  /// In en, this message translates to:
  /// **'QR Verification Not Configured'**
  String get qrVerificationNotConfigured;

  /// QR setup view description
  ///
  /// In en, this message translates to:
  /// **'Generate a shared secret to enable QR-based location verification for your employees.'**
  String get qrVerificationDescription;

  /// Button text while configuring
  ///
  /// In en, this message translates to:
  /// **'Configuring...'**
  String get configuring;

  /// Enable QR verification button
  ///
  /// In en, this message translates to:
  /// **'Enable QR Verification'**
  String get enableQrVerification;

  /// Success snackbar after QR config
  ///
  /// In en, this message translates to:
  /// **'QR verification configured successfully!'**
  String get qrConfiguredSuccess;

  /// Error snackbar during QR config
  ///
  /// In en, this message translates to:
  /// **'Failed to configure: {error}'**
  String failedToConfigure(String error);

  /// Instructions section header
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsLabel;

  /// QR code display instructions body
  ///
  /// In en, this message translates to:
  /// **'Display this screen at your office entrance. Employees must scan this QR code before checking in, taking breaks, or checking out. The code refreshes every 5 seconds for security.'**
  String get qrDisplayInstructions;

  /// QR countdown text
  ///
  /// In en, this message translates to:
  /// **'Refreshes in {seconds}s'**
  String refreshesInSeconds(int seconds);

  /// Kiosk exists view title
  ///
  /// In en, this message translates to:
  /// **'Kiosk Account Active'**
  String get kioskAccountActive;

  /// Kiosk creation form description
  ///
  /// In en, this message translates to:
  /// **'Create a dedicated account for kiosk devices.'**
  String get createDedicatedKioskAccount;

  /// Kiosk email validation - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterAnEmail;

  /// Kiosk email validation - invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// Kiosk password validation - empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// Kiosk password validation - too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinSixChars;

  /// Button text while creating kiosk
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// Toast after kiosk creation
  ///
  /// In en, this message translates to:
  /// **'Kiosk account created successfully!'**
  String get kioskAccountCreatedSuccess;

  /// Toast after kiosk password change
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccessfully;

  /// Change kiosk password sheet title
  ///
  /// In en, this message translates to:
  /// **'Change Kiosk Password'**
  String get changeKioskPassword;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Confirm new password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Update password button label
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// Current password validation
  ///
  /// In en, this message translates to:
  /// **'Please enter the current password'**
  String get pleaseEnterCurrentPassword;

  /// New password validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// Confirm password validation
  ///
  /// In en, this message translates to:
  /// **'Please confirm the new password'**
  String get pleaseConfirmNewPassword;

  /// Error message with prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// Empty state payroll title
  ///
  /// In en, this message translates to:
  /// **'No payroll records found'**
  String get noPayrollRecords;

  /// Empty state payroll subtitle
  ///
  /// In en, this message translates to:
  /// **'Generate payroll to see records here'**
  String get generatePayrollHint;

  /// Generate button label
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Payslip short title
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payslip;

  /// Payslip empty state
  ///
  /// In en, this message translates to:
  /// **'No payroll selected'**
  String get noPayrollSelected;

  /// Payslip section title
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get attendanceSummary;

  /// Payslip section title
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get workedDays;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Absences'**
  String get absences;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtime;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get earlyLeave;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'No Checkout'**
  String get noCheckout;

  /// Payslip stat card label
  ///
  /// In en, this message translates to:
  /// **'Payable Days'**
  String get payableDays;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Worked Days Salary'**
  String get workedDaysSalary;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Paid Vacation Salary'**
  String get paidVacationSalary;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Overtime Bonus'**
  String get overtimeBonus;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Absence Deduction'**
  String get absenceDeduction;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Late Deduction'**
  String get lateDeduction;

  /// Payslip line item
  ///
  /// In en, this message translates to:
  /// **'Early Leave Deduction'**
  String get earlyLeaveDeduction;

  /// Period label
  ///
  /// In en, this message translates to:
  /// **'Period: {value}'**
  String period(String value);

  /// Base salary label
  ///
  /// In en, this message translates to:
  /// **'Base Salary: {value}'**
  String baseSalary(String value);

  /// Daily rate label
  ///
  /// In en, this message translates to:
  /// **'Daily Rate: {value}'**
  String dailyRate(String value);

  /// Generated date label
  ///
  /// In en, this message translates to:
  /// **'Generated: {value}'**
  String generated(String value);

  /// Former employee badge
  ///
  /// In en, this message translates to:
  /// **'Former Employee'**
  String get formerEmployee;

  /// Former badge short
  ///
  /// In en, this message translates to:
  /// **'Former'**
  String get former;

  /// Generate payroll month picker label
  ///
  /// In en, this message translates to:
  /// **'Payroll Month'**
  String get payrollMonth;

  /// Generate payroll info text
  ///
  /// In en, this message translates to:
  /// **'Payroll will be calculated using each employee\'s individual salary from their team profile. Deduction rules are loaded from your payroll configuration.'**
  String get payrollInfoBanner;

  /// Override toggle title
  ///
  /// In en, this message translates to:
  /// **'Override Existing Payroll'**
  String get overrideExistingPayroll;

  /// Override toggle description
  ///
  /// In en, this message translates to:
  /// **'Re-generate payroll even if it already exists for this month'**
  String get overrideDescription;

  /// Payroll config rules section title
  ///
  /// In en, this message translates to:
  /// **'Active Rules'**
  String get activeRules;

  /// Generate payroll button
  ///
  /// In en, this message translates to:
  /// **'Generate for All Employees'**
  String get generateForAll;

  /// Error when company data missing
  ///
  /// In en, this message translates to:
  /// **'Company data not available'**
  String get companyDataNotAvailable;

  /// Payroll config info banner text
  ///
  /// In en, this message translates to:
  /// **'Configure payroll deduction and bonus rules for your company. These rules apply to all employees.'**
  String get payrollConfigInfo;

  /// Payroll config section title
  ///
  /// In en, this message translates to:
  /// **'Absence Deduction'**
  String get absenceDeductionSection;

  /// Absence multiplier field description
  ///
  /// In en, this message translates to:
  /// **'Multiplier applied to daily salary for each unapproved absence day.'**
  String get absenceMultiplierDescription;

  /// Absence multiplier field label
  ///
  /// In en, this message translates to:
  /// **'Absence Multiplier (e.g. 1.0, 1.5, 2.0)'**
  String get absenceMultiplierLabel;

  /// Payroll config section title
  ///
  /// In en, this message translates to:
  /// **'Late Arrival Deduction'**
  String get lateArrivalDeduction;

  /// Deduction mode dropdown label
  ///
  /// In en, this message translates to:
  /// **'Deduction Mode'**
  String get deductionMode;

  /// Deduction mode option
  ///
  /// In en, this message translates to:
  /// **'Percentage of Daily Salary'**
  String get percentageOfDailySalary;

  /// Deduction mode option
  ///
  /// In en, this message translates to:
  /// **'Per Minute Deduction'**
  String get perMinuteDeduction;

  /// Late deduction percentage label
  ///
  /// In en, this message translates to:
  /// **'Deduction % per Late Day'**
  String get deductionPercentPerLateDay;

  /// Late deduction amount label
  ///
  /// In en, this message translates to:
  /// **'Deduction Amount per Minute'**
  String get deductionAmountPerMinute;

  /// Payroll config section title
  ///
  /// In en, this message translates to:
  /// **'Early Leave Deduction'**
  String get earlyLeaveDeductionSection;

  /// Early leave deduction description
  ///
  /// In en, this message translates to:
  /// **'Deduction applied when employees leave before the scheduled end time.'**
  String get earlyLeaveDeductionDescription;

  /// Early leave deduction mode dropdown label
  ///
  /// In en, this message translates to:
  /// **'Early Leave Deduction Mode'**
  String get earlyLeaveDeductionMode;

  /// Early leave deduction percentage label
  ///
  /// In en, this message translates to:
  /// **'Deduction % per Early Leave Day'**
  String get deductionPercentPerEarlyLeave;

  /// Payroll config section title
  ///
  /// In en, this message translates to:
  /// **'Overtime Bonus'**
  String get overtimeBonusSection;

  /// Minimum overtime field label
  ///
  /// In en, this message translates to:
  /// **'Minimum Overtime Minutes'**
  String get minimumOvertimeMinutes;

  /// Overtime bonus field label
  ///
  /// In en, this message translates to:
  /// **'Bonus % of Daily Salary (per overtime day)'**
  String get bonusPercentPerOvertimeDay;

  /// Payroll config section title
  ///
  /// In en, this message translates to:
  /// **'Missing Checkout Policy'**
  String get missingCheckoutPolicy;

  /// Missing checkout policy description
  ///
  /// In en, this message translates to:
  /// **'How to handle days where an employee checked in but never checked out.'**
  String get missingCheckoutDescription;

  /// Policy dropdown label
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get policy;

  /// Missing checkout policy option
  ///
  /// In en, this message translates to:
  /// **'Count as Half Day'**
  String get countAsHalfDay;

  /// Missing checkout policy option
  ///
  /// In en, this message translates to:
  /// **'Count as Absent'**
  String get countAsAbsent;

  /// Save config button
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// Toast after saving payroll config
  ///
  /// In en, this message translates to:
  /// **'Configuration saved successfully!'**
  String get configSavedSuccessfully;

  /// Number validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Absence Multiplier'**
  String get absenceMultiplier;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Late Grace'**
  String get lateGrace;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Late Deduction'**
  String get lateDeductionRule;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Overtime Min'**
  String get overtimeMin;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Overtime Bonus'**
  String get overtimeBonusRule;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get earlyLeaveRule;

  /// Rule label
  ///
  /// In en, this message translates to:
  /// **'Missing Checkout'**
  String get missingCheckoutRule;

  /// Rule value
  ///
  /// In en, this message translates to:
  /// **'{value}% of daily salary'**
  String percentOfDailySalary(String value);

  /// Rule value
  ///
  /// In en, this message translates to:
  /// **'{value}/min'**
  String perMinuteRate(String value);

  /// Rule value
  ///
  /// In en, this message translates to:
  /// **'{value}× daily salary'**
  String timesDailySalary(String value);

  /// Minutes suffix
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesSuffix(String value);

  /// Date picker help text
  ///
  /// In en, this message translates to:
  /// **'Select Payroll Month'**
  String get selectPayrollMonth;

  /// Clear all notifications button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllNotifications;

  /// Notification for leave submitted
  ///
  /// In en, this message translates to:
  /// **'{name} submitted a leave request for {days} days.'**
  String notifLeaveSubmitted(String name, String days);

  /// Notification for leave approved
  ///
  /// In en, this message translates to:
  /// **'{name} approved your leave request.'**
  String notifLeaveApproved(String name);

  /// Notification for leave rejected
  ///
  /// In en, this message translates to:
  /// **'{name} rejected your leave request.'**
  String notifLeaveRejected(String name);

  /// Notification for leave rejected with reason
  ///
  /// In en, this message translates to:
  /// **'{name} rejected your leave request. Reason: {reason}'**
  String notifLeaveRejectedWithReason(String name, String reason);

  /// Notification for leave cancelled
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled their {status} leave request.'**
  String notifLeaveCancelled(String name, String status);

  /// Notification for check in
  ///
  /// In en, this message translates to:
  /// **'{name} checked in.'**
  String notifCheckIn(String name);

  /// Notification for check out
  ///
  /// In en, this message translates to:
  /// **'{name} checked out.'**
  String notifCheckOut(String name);

  /// Notification for break in
  ///
  /// In en, this message translates to:
  /// **'{name} is on a break.'**
  String notifBreakIn(String name);

  /// Notification for break out
  ///
  /// In en, this message translates to:
  /// **'{name} finished their break.'**
  String notifBreakOut(String name);

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
