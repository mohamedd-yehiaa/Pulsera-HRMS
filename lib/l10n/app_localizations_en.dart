// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLeave => 'Leave';

  @override
  String get navTeam => 'Team';

  @override
  String get navPayroll => 'Payroll';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String welcomeUser(String name) {
    return 'Welcome $name';
  }

  @override
  String get allLeaves => 'All Leaves';

  @override
  String get payrollHistory => 'Payroll History';

  @override
  String get applyLeave => 'Apply Leave';

  @override
  String get payrollSettings => 'Payroll Settings';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get savePhoto => 'Save Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get resetLinkSent => 'Reset link sent! Check your inbox.';

  @override
  String get resetLinkSentDescription =>
      'Check your email inbox. If you don\'t see it, check your spam/junk folder.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get pleaseEnterEmail => 'Please enter your email address';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendResetLink => 'Resend Reset Link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get welcomeToPulsera => 'Welcome to Pulsera';

  @override
  String get managePulseraSubtitle =>
      'Manage your workforce with ease\nand efficiency.';

  @override
  String get orContinueWithSocial => 'Or continue with social account';

  @override
  String get google => 'Google';

  @override
  String get date => 'Date';

  @override
  String get totalDaysLabel => 'Total Days';

  @override
  String nDays(int count) {
    return '$count Days';
  }

  @override
  String get employee => 'Employee';

  @override
  String get approval => 'Approval';

  @override
  String get reason => 'Reason';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get cancelLeave => 'Cancel Leave';

  @override
  String get cancelApprovedLeaveMessage =>
      'Are you sure you want to cancel this approved leave? Your vacation days will be restored.';

  @override
  String get cancelPendingLeaveMessage =>
      'Are you sure you want to cancel this pending leave request?';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get rejectedReason => 'Rejected Reason';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get breakIn => 'Break In';

  @override
  String get breakOut => 'Break Out';

  @override
  String get registerCompanyPrompt => 'Please Register your Company Details!';

  @override
  String get createCompany => 'Create Company';

  @override
  String get joinCompanyPrompt => 'Please join a company to continue!';

  @override
  String get giveIdToCompany => 'Give your Id to the company';

  @override
  String get copiedToClipboard => 'Copied to your clipboard !';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get todayAttendance => 'Today Attendance';

  @override
  String get yourActivity => 'Your Activity';

  @override
  String get breakTime => 'Break Time';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get takeABreak => 'Take a Break';

  @override
  String get timeDetails => 'Time Details';

  @override
  String lateByMinutes(int minutes) {
    return 'Late by $minutes min';
  }

  @override
  String leftEarlyMinutes(int minutes) {
    return 'Left $minutes min early';
  }

  @override
  String overtimeMinutes(int minutes) {
    return 'Overtime: $minutes min';
  }

  @override
  String get locationVerified => 'Location Verified';

  @override
  String get confirmAction => 'Confirm Action';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get statusEarly => 'Early';

  @override
  String get statusOnTime => 'On Time';

  @override
  String get statusLate => 'Late';

  @override
  String get statusVeryLate => 'Very Late';

  @override
  String get statusEarlyLeave => 'Early Leave';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusOvertime => 'Overtime';

  @override
  String get statusInsufficientHours => 'Insufficient Hours';

  @override
  String get qrScanned => 'QR Scanned';

  @override
  String get qrScannedExclamation => 'QR Scanned!';

  @override
  String get pointCameraAtQr => 'Point your camera at the QR code';

  @override
  String get welcomeBackExclamation => 'Welcome back!';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get pleaseEnterPassword => 'please enter your password';

  @override
  String get password => 'Password';

  @override
  String get forgetPassword => 'Forget Password?';

  @override
  String get logIn => 'LOG IN';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get welcomeBackBranding => 'Welcome Back!';

  @override
  String get loginBrandingSubtitle =>
      'Streamline your HR operations.\nAttendance, payroll, and team management\nin one place.';

  @override
  String get letsGetStarted => 'Let\'s Get Started!';

  @override
  String get registerNowToContinue => 'Register now to continue';

  @override
  String get firstName => 'First Name';

  @override
  String get pleaseEnterFirstName => 'please enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get pleaseEnterLastName => 'please enter your last name';

  @override
  String get userType => 'User Type';

  @override
  String get companyOwner => 'Company Owner';

  @override
  String get employeeRole => 'Employee';

  @override
  String get pleaseSelectRole => 'Please select your role';

  @override
  String get passwordTooShort => 'password is too short';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'please confirm your password';

  @override
  String get passwordsDoNotMatch => 'passwords do not match';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pleaseEnterPhone => 'please enter your phone number';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get login => 'Login';

  @override
  String get joinPulsera => 'Join Pulsera';

  @override
  String get registerBrandingSubtitle =>
      'Create your account and start\nmanaging your team efficiently.';

  @override
  String get organizationSetup => 'Organization Setup';

  @override
  String get organizationDetails => 'Organization Details';

  @override
  String get organizationName => 'Organization Name';

  @override
  String get fieldCantBeEmpty => 'This field can\'t be empty';

  @override
  String get perMonthPaidLeave => 'Per Month Paid Leave';

  @override
  String get perMonthSickCasualLeave => 'Per Month Sick/Casual Leave';

  @override
  String get perMonthWorkFromHome => 'Per Month Work From Home';

  @override
  String get selectStartTime => 'Select start time';

  @override
  String get selectEndTime => 'Select end time';

  @override
  String get attendanceRules => 'Attendance Rules';

  @override
  String get gracePeriodMinutes => 'Grace Period (minutes)';

  @override
  String get earlyCheckInAllowance => 'Early Check-in Allowance (minutes)';

  @override
  String get lateCutoffMinutes => 'Late Cut-off (minutes)';

  @override
  String get minimumWorkHours => 'Minimum Work Hours';

  @override
  String get registerOrganization => 'Register Organization';

  @override
  String get pleaseSelectWorkingHours => 'Please select working hours';

  @override
  String get companyRegisteredSuccessfully => 'Company Registered Successfully';

  @override
  String get leaveBalance => 'Leave\nBalance';

  @override
  String get leaveApproved => 'Leave\nApproved';

  @override
  String get leavePending => 'Leave\nPending';

  @override
  String get leaveRejected => 'Leave\nRejected';

  @override
  String get my => 'My';

  @override
  String get other => 'Other';

  @override
  String get noDataFound => 'No Data found.';

  @override
  String get leaveStatusUpdated => 'Leave Status Updated';

  @override
  String get leaveCancelledDaysRestored => 'Leave Cancelled — Days Restored';

  @override
  String get rejectLeave => 'Reject Leave';

  @override
  String get enterRejectionReason => 'Enter reason for rejection (optional)';

  @override
  String get remainingVacationDays => 'Remaining Vacation Days';

  @override
  String nDaysValue(int count) {
    return '$count days';
  }

  @override
  String get assignedTo => 'Assigned To';

  @override
  String get teamAdmin => 'Team Admin';

  @override
  String get notAssignedToTeam =>
      'You are not assigned to any team. Contact your manager.';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String totalNDays(int count, String suffix) {
    return 'Total: $count day$suffix';
  }

  @override
  String get reasonForLeave => 'Reason for leave';

  @override
  String get required => 'Required';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get leaveRequestSubmitted => 'Leave Request Submitted';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get myProfile => 'My Profile';

  @override
  String get myCompany => 'My Company';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get businessTools => 'Business Tools';

  @override
  String get generateQrCode => 'Generate QR Code';

  @override
  String get logOut => 'Log out';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get profileUpdatedSuccessfully => 'Profile Updated Successfully';

  @override
  String get companyDetails => 'Company Details';

  @override
  String get editCompany => 'Edit Company';

  @override
  String get companyUpdatedSuccessfully => 'Company Updated Successfully';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get addTeamMember => 'Add Team Member';

  @override
  String get noTeamMembers => 'No team members yet';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get kioskMode => 'Kiosk Mode';

  @override
  String get kioskAccount => 'Kiosk Account';

  @override
  String get user => 'User';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get workingDays => 'Working Days';

  @override
  String get workSchedule => 'Work Schedule';

  @override
  String get leavePolicy => 'Leave Policy';

  @override
  String get paidLeave => 'Paid Leave';

  @override
  String get sickCasualLeave => 'Sick/Casual Leave';

  @override
  String get workFromHome => 'Work From Home';

  @override
  String daysPerMonth(String count) {
    return '$count days/month';
  }

  @override
  String get gracePeriod => 'Grace Period';

  @override
  String nMinutes(String count) {
    return '$count minutes';
  }

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get pleaseEnterEmployeeId => 'Please enter employee ID';

  @override
  String get addMember => 'Add Member';

  @override
  String get memberAddedSuccessfully => 'Member added successfully';

  @override
  String get roleType => 'Role Type';

  @override
  String get hrAdmin => 'Hr admin';

  @override
  String get memberRole => 'Member';

  @override
  String get manager => 'Manager';

  @override
  String get remove => 'Remove';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirmation =>
      'Are you sure you want to remove this member?';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get noAttendanceData => 'No attendance data found';

  @override
  String get basicSalary => 'Basic Salary';

  @override
  String get deductions => 'Deductions';

  @override
  String get netSalary => 'Net Salary';

  @override
  String get generatePayroll => 'Generate Payroll';

  @override
  String get payslipDetails => 'Payslip Details';

  @override
  String get noPayrollData => 'No payroll data found';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get payrollGenerated => 'Payroll generated successfully';

  @override
  String get createKioskAccount => 'Create Kiosk Account';

  @override
  String get kioskEmail => 'Kiosk Email';

  @override
  String get kioskPassword => 'Kiosk Password';

  @override
  String get kioskAccountCreated => 'Kiosk account created successfully';

  @override
  String get changePassword => 'Change Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get company => 'Company';

  @override
  String get role => 'Role';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get companyInfo => 'Company Info';

  @override
  String get qrCodeTitle => 'QR Code';

  @override
  String get qrCodeInstructions =>
      'Display this QR code at your office entrance for employees to scan during check-in/check-out.';

  @override
  String get refreshQrCode => 'Refresh QR Code';

  @override
  String get kioskSetupTitle => 'Kiosk Setup';

  @override
  String get kioskSetupDescription =>
      'Create a dedicated kiosk account for a fixed device at your office entrance.';

  @override
  String get kioskExists => 'Kiosk account already exists';

  @override
  String kioskCurrentEmail(String email) {
    return 'Current kiosk email: $email';
  }

  @override
  String get daysWorked => 'Days Worked';

  @override
  String get lateDays => 'Late Days';

  @override
  String get earlyLeaveDays => 'Early Leave Days';

  @override
  String get overtimeDays => 'Overtime Days';

  @override
  String get totalLateMinutes => 'Total Late Minutes';

  @override
  String get totalOvertimeMinutes => 'Total Overtime Minutes';

  @override
  String get missingCheckout => 'Missing Checkout';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get salary => 'Salary';

  @override
  String get bonus => 'Bonus';

  @override
  String get allowance => 'Allowance';

  @override
  String get tax => 'Tax';

  @override
  String get insurance => 'Insurance';

  @override
  String get penalties => 'Penalties';

  @override
  String get otherDeductions => 'Other Deductions';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get totalDeductions => 'Total Deductions';

  @override
  String get payrollConfig => 'Payroll Configuration';

  @override
  String get payrollSaved => 'Payroll configuration saved';

  @override
  String get payPeriod => 'Pay Period';

  @override
  String get monthly => 'Monthly';

  @override
  String get searchMembers => 'Search members...';

  @override
  String get viewAttendance => 'View Attendance';

  @override
  String get noResults => 'No results found';

  @override
  String timeAgoMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeAgoDays(int days) {
    return '${days}d ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get scanToCheckIn => 'Scan to Check In';

  @override
  String get checkInSuccessful => 'Check-in successful!';

  @override
  String get checkOutSuccessful => 'Check-out successful!';

  @override
  String get invalidQrCode => 'Invalid QR code';

  @override
  String get employeeNotFound => 'Employee not found';

  @override
  String get kioskLogout => 'Exit Kiosk';

  @override
  String get earlyLeaveMinutes => 'Early Leave Minutes';

  @override
  String get overrideConfirmTitle => 'Override Existing Payroll';

  @override
  String get overrideConfirmMessage =>
      'Payroll has already been generated for this period. Do you want to override it?';

  @override
  String get overrideBtn => 'Override';

  @override
  String get myTeam => 'My Team';

  @override
  String get teamInfo => 'Team Info';

  @override
  String get searchTeamMembers => 'Search team members';

  @override
  String nMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Members',
      one: '1 Member',
    );
    return '$_temp0';
  }

  @override
  String get addMemberButton => 'Add Member';

  @override
  String get tapAddMemberHint =>
      'Tap \"Add Member\" to assign employees to your team.';

  @override
  String removeMemberConfirmationName(String name) {
    return 'Are you sure you want to remove $name from your team?';
  }

  @override
  String get notAssignedToTeamYet => 'Not assigned to any team yet';

  @override
  String get myManager => 'My Manager';

  @override
  String get notAssignedToManager => 'You are not assigned to any manager yet.';

  @override
  String get vacationBalance => 'Vacation Balance';

  @override
  String get total => 'Total';

  @override
  String get remaining => 'Remaining';

  @override
  String get usedLabel => 'Used';

  @override
  String get daysPerMonthShort => 'days/Month';

  @override
  String get daysLeft => 'days left';

  @override
  String get daysLabel => 'days';

  @override
  String get salaryInfo => 'Salary Info';

  @override
  String get monthlySalary => 'Monthly Salary';

  @override
  String get employeeUserId => 'Employee UserID';

  @override
  String get validating => 'Validating...';

  @override
  String get validateButton => 'Validate';

  @override
  String get contractDetails => 'Contract Details';

  @override
  String get contractDetailsDescription =>
      'Define the employee\'s salary and vacation allowance.';

  @override
  String get employeeRoleLabel => 'Employee';

  @override
  String get hrAdminRoleLabel => 'HR Admin';

  @override
  String get pleaseEnterMonthlySalary => 'Please enter the monthly salary';

  @override
  String get pleaseEnterValidSalary => 'Please enter a valid salary amount';

  @override
  String get monthlyVacationDays => 'Monthly Vacation Days';

  @override
  String get pleaseEnterVacationDays => 'Please enter vacation days';

  @override
  String get pleaseEnterValidDays => 'Please enter a valid number of days';

  @override
  String get addToTeam => 'Add to Team';

  @override
  String employeeAttendanceTitle(String name) {
    return '$name\'s Attendance';
  }

  @override
  String get workedHours => 'Worked Hours';

  @override
  String get persistedWorkedMinutes => 'Persisted Worked Minutes';

  @override
  String nMin(String count) {
    return '$count min';
  }

  @override
  String get breakDetails => 'Break Details';

  @override
  String breakN(int n) {
    return 'Break $n:';
  }

  @override
  String get editAttendanceStatus => 'Edit Attendance Status';

  @override
  String get editCheckInTime => 'Edit Check-In Time';

  @override
  String get editCheckOutTime => 'Edit Check-Out Time';

  @override
  String get timeFormatHint => 'Time (HH:mm:ss)';

  @override
  String get earlyCheckInLabel => 'Early Check-in';

  @override
  String get lateLabel => 'Late';

  @override
  String get earlyLeaveLabel => 'Early Leave';

  @override
  String get overtimeLabel => 'Overtime';

  @override
  String get exitKioskMode => 'Exit Kiosk Mode';

  @override
  String get enterPasswordToExit => 'Enter your password to exit kiosk mode.';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get incorrectPassword => 'Incorrect password. Please try again.';

  @override
  String get exitButton => 'Exit';

  @override
  String get qrNotConfigured => 'QR Verification Not Configured';

  @override
  String get qrNotConfiguredDescription =>
      'Please ask an admin to generate a shared secret from the QR Code Generator in Settings.';

  @override
  String get active => 'Active';

  @override
  String get kioskModeActive => 'Kiosk Mode Active';

  @override
  String get kioskModeDescription =>
      'Display this screen at your office entrance. Employees must scan this QR code before checking in, taking breaks, or checking out. The code refreshes every 5 seconds for security.';

  @override
  String refreshesIn(int seconds) {
    return 'Refreshes in ${seconds}s';
  }

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get notProvided => 'Not provided';

  @override
  String get userName => 'UserName';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editOrganizationDetails => 'Edit Organization Details';

  @override
  String get organizationDetailsUpdated => 'Organization Details Updated';

  @override
  String get editOrganization => 'Edit Organization';

  @override
  String get companyIdNotFound => 'Company ID not found';

  @override
  String get qrCodeGenerator => 'QR Code Generator';

  @override
  String get qrVerificationNotConfigured => 'QR Verification Not Configured';

  @override
  String get qrVerificationDescription =>
      'Generate a shared secret to enable QR-based location verification for your employees.';

  @override
  String get configuring => 'Configuring...';

  @override
  String get enableQrVerification => 'Enable QR Verification';

  @override
  String get qrConfiguredSuccess => 'QR verification configured successfully!';

  @override
  String failedToConfigure(String error) {
    return 'Failed to configure: $error';
  }

  @override
  String get instructionsLabel => 'Instructions';

  @override
  String get qrDisplayInstructions =>
      'Display this screen at your office entrance. Employees must scan this QR code before checking in, taking breaks, or checking out. The code refreshes every 5 seconds for security.';

  @override
  String refreshesInSeconds(int seconds) {
    return 'Refreshes in ${seconds}s';
  }

  @override
  String get kioskAccountActive => 'Kiosk Account Active';

  @override
  String get createDedicatedKioskAccount =>
      'Create a dedicated account for kiosk devices.';

  @override
  String get pleaseEnterAnEmail => 'Please enter an email';

  @override
  String get pleaseEnterAValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get passwordMinSixChars => 'Password must be at least 6 characters';

  @override
  String get creating => 'Creating...';

  @override
  String get kioskAccountCreatedSuccess =>
      'Kiosk account created successfully!';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get changeKioskPassword => 'Change Kiosk Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter the current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get pleaseConfirmNewPassword => 'Please confirm the new password';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get noPayrollRecords => 'No payroll records found';

  @override
  String get generatePayrollHint => 'Generate payroll to see records here';

  @override
  String get generate => 'Generate';

  @override
  String get payslip => 'Payslip';

  @override
  String get noPayrollSelected => 'No payroll selected';

  @override
  String get attendanceSummary => 'Attendance Summary';

  @override
  String get earnings => 'Earnings';

  @override
  String get workedDays => 'Worked';

  @override
  String get absences => 'Absences';

  @override
  String get late => 'Late';

  @override
  String get overtime => 'Overtime';

  @override
  String get earlyLeave => 'Early Leave';

  @override
  String get noCheckout => 'No Checkout';

  @override
  String get payableDays => 'Payable Days';

  @override
  String get workedDaysSalary => 'Worked Days Salary';

  @override
  String get paidVacationSalary => 'Paid Vacation Salary';

  @override
  String get overtimeBonus => 'Overtime Bonus';

  @override
  String get absenceDeduction => 'Absence Deduction';

  @override
  String get lateDeduction => 'Late Deduction';

  @override
  String get earlyLeaveDeduction => 'Early Leave Deduction';

  @override
  String period(String value) {
    return 'Period: $value';
  }

  @override
  String baseSalary(String value) {
    return 'Base Salary: $value';
  }

  @override
  String dailyRate(String value) {
    return 'Daily Rate: $value';
  }

  @override
  String generated(String value) {
    return 'Generated: $value';
  }

  @override
  String get formerEmployee => 'Former Employee';

  @override
  String get former => 'Former';

  @override
  String get payrollMonth => 'Payroll Month';

  @override
  String get payrollInfoBanner =>
      'Payroll will be calculated using each employee\'s individual salary from their team profile. Deduction rules are loaded from your payroll configuration.';

  @override
  String get overrideExistingPayroll => 'Override Existing Payroll';

  @override
  String get overrideDescription =>
      'Re-generate payroll even if it already exists for this month';

  @override
  String get activeRules => 'Active Rules';

  @override
  String get generateForAll => 'Generate for All Employees';

  @override
  String get companyDataNotAvailable => 'Company data not available';

  @override
  String get payrollConfigInfo =>
      'Configure payroll deduction and bonus rules for your company. These rules apply to all employees.';

  @override
  String get absenceDeductionSection => 'Absence Deduction';

  @override
  String get absenceMultiplierDescription =>
      'Multiplier applied to daily salary for each unapproved absence day.';

  @override
  String get absenceMultiplierLabel =>
      'Absence Multiplier (e.g. 1.0, 1.5, 2.0)';

  @override
  String get lateArrivalDeduction => 'Late Arrival Deduction';

  @override
  String get deductionMode => 'Deduction Mode';

  @override
  String get percentageOfDailySalary => 'Percentage of Daily Salary';

  @override
  String get perMinuteDeduction => 'Per Minute Deduction';

  @override
  String get deductionPercentPerLateDay => 'Deduction % per Late Day';

  @override
  String get deductionAmountPerMinute => 'Deduction Amount per Minute';

  @override
  String get earlyLeaveDeductionSection => 'Early Leave Deduction';

  @override
  String get earlyLeaveDeductionDescription =>
      'Deduction applied when employees leave before the scheduled end time.';

  @override
  String get earlyLeaveDeductionMode => 'Early Leave Deduction Mode';

  @override
  String get deductionPercentPerEarlyLeave => 'Deduction % per Early Leave Day';

  @override
  String get overtimeBonusSection => 'Overtime Bonus';

  @override
  String get minimumOvertimeMinutes => 'Minimum Overtime Minutes';

  @override
  String get bonusPercentPerOvertimeDay =>
      'Bonus % of Daily Salary (per overtime day)';

  @override
  String get missingCheckoutPolicy => 'Missing Checkout Policy';

  @override
  String get missingCheckoutDescription =>
      'How to handle days where an employee checked in but never checked out.';

  @override
  String get policy => 'Policy';

  @override
  String get countAsHalfDay => 'Count as Half Day';

  @override
  String get countAsAbsent => 'Count as Absent';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get configSavedSuccessfully => 'Configuration saved successfully!';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get absenceMultiplier => 'Absence Multiplier';

  @override
  String get lateGrace => 'Late Grace';

  @override
  String get lateDeductionRule => 'Late Deduction';

  @override
  String get overtimeMin => 'Overtime Min';

  @override
  String get overtimeBonusRule => 'Overtime Bonus';

  @override
  String get earlyLeaveRule => 'Early Leave';

  @override
  String get missingCheckoutRule => 'Missing Checkout';

  @override
  String percentOfDailySalary(String value) {
    return '$value% of daily salary';
  }

  @override
  String perMinuteRate(String value) {
    return '$value/min';
  }

  @override
  String timesDailySalary(String value) {
    return '$value× daily salary';
  }

  @override
  String minutesSuffix(String value) {
    return '$value min';
  }

  @override
  String get selectPayrollMonth => 'Select Payroll Month';

  @override
  String get clearAllNotifications => 'Clear All';

  @override
  String notifLeaveSubmitted(String name, String days) {
    return '$name submitted a leave request for $days days.';
  }

  @override
  String notifLeaveApproved(String name) {
    return '$name approved your leave request.';
  }

  @override
  String notifLeaveRejected(String name) {
    return '$name rejected your leave request.';
  }

  @override
  String notifLeaveRejectedWithReason(String name, String reason) {
    return '$name rejected your leave request. Reason: $reason';
  }

  @override
  String notifLeaveCancelled(String name, String status) {
    return '$name cancelled their $status leave request.';
  }

  @override
  String notifCheckIn(String name) {
    return '$name checked in.';
  }

  @override
  String notifCheckOut(String name) {
    return '$name checked out.';
  }

  @override
  String notifBreakIn(String name) {
    return '$name is on a break.';
  }

  @override
  String notifBreakOut(String name) {
    return '$name finished their break.';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';
}
