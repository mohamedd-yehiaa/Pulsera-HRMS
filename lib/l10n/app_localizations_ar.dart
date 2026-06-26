// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLeave => 'الإجازات';

  @override
  String get navTeam => 'الفريق';

  @override
  String get navPayroll => 'الرواتب';

  @override
  String get navProfile => 'الحساب';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String welcomeUser(String name) {
    return 'مرحباً $name';
  }

  @override
  String get allLeaves => 'جميع الإجازات';

  @override
  String get payrollHistory => 'سجل الرواتب';

  @override
  String get applyLeave => 'طلب إجازة';

  @override
  String get payrollSettings => 'إعدادات الرواتب';

  @override
  String get uploadPhoto => 'رفع الصورة';

  @override
  String get savePhoto => 'حفظ الصورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get resetLinkSent =>
      'تم إرسال رابط إعادة التعيين ! تحقق من بريدك الوارد.';

  @override
  String get resetLinkSentDescription =>
      'تحقق من صندوق بريدك الإلكتروني. إذا لم تجده، تحقق من مجلد البريد المزعج.';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String resendInSeconds(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get resendResetLink => 'إعادة إرسال رابط التعيين';

  @override
  String get sendResetLink => 'إرسال رابط التعيين';

  @override
  String get welcomeToPulsera => 'مرحبًا بك في Pulsera';

  @override
  String get managePulseraSubtitle => 'أدر قوى عملك بسهولة\nوكفاءة.';

  @override
  String get orContinueWithSocial => 'أو تابع بحساب اجتماعي';

  @override
  String get google => 'Google';

  @override
  String get date => 'التاريخ';

  @override
  String get totalDaysLabel => 'إجمالي الأيام';

  @override
  String nDays(int count) {
    return '$count أيام';
  }

  @override
  String get employee => 'الموظف';

  @override
  String get approval => 'الموافقة';

  @override
  String get reason => 'السبب';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get cancelLeave => 'إلغاء الإجازة';

  @override
  String get cancelApprovedLeaveMessage =>
      'هل أنت متأكد من إلغاء هذه الإجازة المعتمدة؟ سيتم استعادة أيام إجازتك.';

  @override
  String get cancelPendingLeaveMessage =>
      'هل أنت متأكد من إلغاء طلب الإجازة المعلق؟';

  @override
  String get pending => 'معلق';

  @override
  String get approved => 'معتمد';

  @override
  String get rejected => 'مرفوض';

  @override
  String get cancelled => 'ملغى';

  @override
  String get no => 'لا';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get rejectedReason => 'سبب الرفض';

  @override
  String get checkIn => 'تسجيل الحضور';

  @override
  String get checkOut => 'تسجيل الانصراف';

  @override
  String get breakIn => 'بداية الاستراحة';

  @override
  String get breakOut => 'نهاية الاستراحة';

  @override
  String get registerCompanyPrompt => 'يرجى تسجيل تفاصيل شركتك!';

  @override
  String get createCompany => 'إنشاء شركة';

  @override
  String get joinCompanyPrompt => 'يرجى الانضمام إلى شركة للمتابعة!';

  @override
  String get giveIdToCompany => 'أعطِ معرّفك للشركة';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة!';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get todayAttendance => 'حضور اليوم';

  @override
  String get yourActivity => 'نشاطك';

  @override
  String get breakTime => 'وقت الاستراحة';

  @override
  String get workingHours => 'ساعات العمل';

  @override
  String get takeABreak => 'أخذ استراحة';

  @override
  String get timeDetails => 'تفاصيل الوقت';

  @override
  String lateByMinutes(int minutes) {
    return 'متأخر $minutes دقيقة';
  }

  @override
  String leftEarlyMinutes(int minutes) {
    return 'غادر مبكراً $minutes دقيقة';
  }

  @override
  String overtimeMinutes(int minutes) {
    return 'عمل إضافي: $minutes دقيقة';
  }

  @override
  String get locationVerified => 'تم التحقق من الموقع';

  @override
  String get confirmAction => 'تأكيد الإجراء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get statusEarly => 'مبكر';

  @override
  String get statusOnTime => 'في الوقت';

  @override
  String get statusLate => 'متأخر';

  @override
  String get statusVeryLate => 'متأخر جداً';

  @override
  String get statusEarlyLeave => 'انصراف مبكر';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusOvertime => 'عمل إضافي';

  @override
  String get statusInsufficientHours => 'ساعات غير كافية';

  @override
  String get qrScanned => 'تم المسح';

  @override
  String get qrScannedExclamation => 'تم مسح الرمز!';

  @override
  String get pointCameraAtQr => 'وجّه الكاميرا نحو رمز QR';

  @override
  String get welcomeBackExclamation => 'مرحبًا بعودتك!';

  @override
  String get loginToAccount => 'سجّل الدخول إلى حسابك';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgetPassword => 'نسيت كلمة المرور؟';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get welcomeBackBranding => 'مرحباً بعودتك!';

  @override
  String get loginBrandingSubtitle =>
      'بسّط عمليات الموارد البشرية.\nالحضور والرواتب وإدارة الفريق\nفي مكان واحد.';

  @override
  String get letsGetStarted => 'لنبدأ!';

  @override
  String get registerNowToContinue => 'سجّل الآن للمتابعة';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get pleaseEnterFirstName => 'يرجى إدخال اسمك الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get pleaseEnterLastName => 'يرجى إدخال اسم العائلة';

  @override
  String get userType => 'نوع المستخدم';

  @override
  String get companyOwner => 'صاحب الشركة';

  @override
  String get employeeRole => 'موظف';

  @override
  String get pleaseSelectRole => 'يرجى اختيار دورك';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get pleaseEnterPhone => 'يرجى إدخال رقم هاتفك';

  @override
  String get register => 'تسجيل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get joinPulsera => 'انضم إلى Pulsera';

  @override
  String get registerBrandingSubtitle =>
      'أنشئ حسابك وابدأ\nإدارة فريقك بكفاءة.';

  @override
  String get organizationSetup => 'إعداد المؤسسة';

  @override
  String get organizationDetails => 'تفاصيل المؤسسة';

  @override
  String get organizationName => 'اسم المؤسسة';

  @override
  String get fieldCantBeEmpty => 'هذا الحقل لا يمكن أن يكون فارغاً';

  @override
  String get perMonthPaidLeave => 'إجازة مدفوعة شهرياً';

  @override
  String get perMonthSickCasualLeave => 'إجازة مرضية/عرضية شهرياً';

  @override
  String get perMonthWorkFromHome => 'عمل من المنزل شهرياً';

  @override
  String get selectStartTime => 'اختر وقت البدء';

  @override
  String get selectEndTime => 'اختر وقت الانتهاء';

  @override
  String get attendanceRules => 'قواعد الحضور';

  @override
  String get gracePeriodMinutes => 'فترة السماح (دقائق)';

  @override
  String get earlyCheckInAllowance => 'مهلة الحضور المبكر (دقائق)';

  @override
  String get lateCutoffMinutes => 'حد التأخير (دقائق)';

  @override
  String get minimumWorkHours => 'الحد الأدنى لساعات العمل';

  @override
  String get registerOrganization => 'تسجيل المؤسسة';

  @override
  String get pleaseSelectWorkingHours => 'يرجى اختيار ساعات العمل';

  @override
  String get companyRegisteredSuccessfully => 'تم تسجيل الشركة بنجاح';

  @override
  String get leaveBalance => 'رصيد\nالإجازات';

  @override
  String get leaveApproved => 'إجازات\nمعتمدة';

  @override
  String get leavePending => 'إجازات\nمعلقة';

  @override
  String get leaveRejected => 'إجازات\nمرفوضة';

  @override
  String get my => 'لي';

  @override
  String get other => 'الآخرين';

  @override
  String get noDataFound => 'لا توجد بيانات.';

  @override
  String get leaveStatusUpdated => 'تم تحديث حالة الإجازة';

  @override
  String get leaveCancelledDaysRestored => 'تم إلغاء الإجازة — استعادة الأيام';

  @override
  String get rejectLeave => 'رفض الإجازة';

  @override
  String get enterRejectionReason => 'أدخل سبب الرفض (اختياري)';

  @override
  String get remainingVacationDays => 'أيام الإجازة المتبقية';

  @override
  String nDaysValue(int count) {
    return '$count أيام';
  }

  @override
  String get assignedTo => 'معيّن إلى';

  @override
  String get teamAdmin => 'مدير الفريق';

  @override
  String get notAssignedToTeam => 'أنت غير معيّن لأي فريق. تواصل مع مديرك.';

  @override
  String get selectStartDate => 'اختر تاريخ البدء';

  @override
  String get selectEndDate => 'اختر تاريخ الانتهاء';

  @override
  String totalNDays(int count, String suffix) {
    return 'الإجمالي: $count يوم$suffix';
  }

  @override
  String get reasonForLeave => 'سبب الإجازة';

  @override
  String get required => 'مطلوب';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get leaveRequestSubmitted => 'تم إرسال طلب الإجازة';

  @override
  String get statusPending => 'معلق';

  @override
  String get statusApproved => 'معتمد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get myCompany => 'شركتي';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get businessTools => 'أدوات العمل';

  @override
  String get generateQrCode => 'إنشاء رمز QR';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get companyDetails => 'تفاصيل الشركة';

  @override
  String get editCompany => 'تعديل الشركة';

  @override
  String get companyUpdatedSuccessfully => 'تم تحديث الشركة بنجاح';

  @override
  String get teamMembers => 'أعضاء الفريق';

  @override
  String get addTeamMember => 'إضافة عضو';

  @override
  String get noTeamMembers => 'لا يوجد أعضاء في الفريق بعد';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد';

  @override
  String get markAllAsRead => 'تعيين الكل كمقروء';

  @override
  String get kioskMode => 'وضع الكشك';

  @override
  String get kioskAccount => 'حساب الكشك';

  @override
  String get user => 'مستخدم';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get workingDays => 'أيام العمل';

  @override
  String get workSchedule => 'جدول العمل';

  @override
  String get leavePolicy => 'سياسة الإجازات';

  @override
  String get paidLeave => 'إجازة مدفوعة';

  @override
  String get sickCasualLeave => 'إجازة مرضية/عرضية';

  @override
  String get workFromHome => 'عمل من المنزل';

  @override
  String daysPerMonth(String count) {
    return '$count أيام/شهر';
  }

  @override
  String get gracePeriod => 'فترة السماح';

  @override
  String nMinutes(String count) {
    return '$count دقيقة';
  }

  @override
  String get scanQrCode => 'مسح رمز QR';

  @override
  String get employeeId => 'معرّف الموظف';

  @override
  String get pleaseEnterEmployeeId => 'يرجى إدخال معرّف الموظف';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get memberAddedSuccessfully => 'تمت إضافة العضو بنجاح';

  @override
  String get roleType => 'نوع الدور';

  @override
  String get hrAdmin => 'مدير الموارد البشرية';

  @override
  String get memberRole => 'عضو';

  @override
  String get manager => 'مدير';

  @override
  String get remove => 'إزالة';

  @override
  String get removeMember => 'إزالة العضو';

  @override
  String get removeMemberConfirmation => 'هل أنت متأكد من إزالة هذا العضو؟';

  @override
  String get attendanceHistory => 'سجل الحضور';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get noAttendanceData => 'لا توجد بيانات حضور';

  @override
  String get basicSalary => 'الراتب الأساسي';

  @override
  String get deductions => 'الاستقطاعات';

  @override
  String get netSalary => 'صافي الراتب';

  @override
  String get generatePayroll => 'إنشاء كشف الرواتب';

  @override
  String get payslipDetails => 'تفاصيل كشف الراتب';

  @override
  String get noPayrollData => 'لا توجد بيانات رواتب';

  @override
  String get month => 'الشهر';

  @override
  String get year => 'السنة';

  @override
  String get payrollGenerated => 'تم إنشاء كشف الرواتب بنجاح';

  @override
  String get createKioskAccount => 'إنشاء حساب الكشك';

  @override
  String get kioskEmail => 'بريد الكشك';

  @override
  String get kioskPassword => 'كلمة مرور الكشك';

  @override
  String get kioskAccountCreated => 'تم إنشاء حساب الكشك بنجاح';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف';

  @override
  String get company => 'الشركة';

  @override
  String get role => 'الدور';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get companyInfo => 'معلومات الشركة';

  @override
  String get qrCodeTitle => 'رمز QR';

  @override
  String get qrCodeInstructions =>
      'اعرض رمز QR هذا عند مدخل مكتبك ليقوم الموظفون بمسحه عند الحضور والإنصراف.';

  @override
  String get refreshQrCode => 'تحديث رمز QR';

  @override
  String get kioskSetupTitle => 'إعداد الكشك';

  @override
  String get kioskSetupDescription =>
      'أنشئ حساب كشك مخصص لجهاز ثابت عند مدخل مكتبك.';

  @override
  String get kioskExists => 'حساب الكشك موجود بالفعل';

  @override
  String kioskCurrentEmail(String email) {
    return 'بريد الكشك الحالي: $email';
  }

  @override
  String get daysWorked => 'أيام العمل';

  @override
  String get lateDays => 'أيام التأخير';

  @override
  String get earlyLeaveDays => 'أيام الإنصراف المبكر';

  @override
  String get overtimeDays => 'أيام العمل الإضافي';

  @override
  String get totalLateMinutes => 'إجمالي دقائق التأخير';

  @override
  String get totalOvertimeMinutes => 'إجمالي دقائق العمل الإضافي';

  @override
  String get missingCheckout => 'إنصراف مفقود';

  @override
  String get selectMonth => 'اختر الشهر';

  @override
  String get salary => 'الراتب';

  @override
  String get bonus => 'المكافأة';

  @override
  String get allowance => 'البدلات';

  @override
  String get tax => 'الضريبة';

  @override
  String get insurance => 'التأمين';

  @override
  String get penalties => 'الجزاءات';

  @override
  String get otherDeductions => 'استقطاعات أخرى';

  @override
  String get totalEarnings => 'إجمالي الأرباح';

  @override
  String get totalDeductions => 'إجمالي الاستقطاعات';

  @override
  String get payrollConfig => 'إعدادات الرواتب';

  @override
  String get payrollSaved => 'تم حفظ إعدادات الرواتب';

  @override
  String get payPeriod => 'فترة الدفع';

  @override
  String get monthly => 'شهرياً';

  @override
  String get searchMembers => 'بحث عن الأعضاء...';

  @override
  String get viewAttendance => 'عرض الحضور';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get permanentlyDelete => 'حذف نهائي';

  @override
  String get permanentlyDeleteTitle => 'حذف نهائي؟';

  @override
  String permanentlyDeleteContent(String name) {
    return 'هل أنت متأكد من أنك تريد إزالة $name بالكامل من قاعدة البيانات؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteForever => 'حذف للأبد';

  @override
  String timeAgoMinutes(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String timeAgoHours(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String timeAgoDays(int days) {
    return 'منذ $days يوم';
  }

  @override
  String get justNow => 'الآن';

  @override
  String get scanToCheckIn => 'امسح لتسجيل الحضور';

  @override
  String get checkInSuccessful => 'تم تسجيل الحضور بنجاح!';

  @override
  String get checkOutSuccessful => 'تم تسجيل الإنصراف بنجاح!';

  @override
  String get invalidQrCode => 'رمز QR غير صالح';

  @override
  String get employeeNotFound => 'الموظف غير موجود';

  @override
  String get kioskLogout => 'الخروج من الكشك';

  @override
  String get earlyLeaveMinutes => 'دقائق الإنصراف المبكر';

  @override
  String get overrideConfirmTitle => 'استبدال كشف الرواتب';

  @override
  String get overrideConfirmMessage =>
      'تم إنشاء كشف الرواتب لهذه الفترة بالفعل. هل تريد استبداله؟';

  @override
  String get overrideBtn => 'استبدال';

  @override
  String get myTeam => 'فريقي';

  @override
  String get teamInfo => 'معلومات الفريق';

  @override
  String get searchTeamMembers => 'بحث عن أعضاء الفريق';

  @override
  String nMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضو',
      many: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
      zero: 'لا يوجد أعضاء',
    );
    return '$_temp0';
  }

  @override
  String get addMemberButton => 'إضافة عضو';

  @override
  String get tapAddMemberHint => 'اضغط \"إضافة عضو\" لتعيين موظفين إلى فريقك.';

  @override
  String removeMemberConfirmationName(String name) {
    return 'هل أنت متأكد من إزالة $name من فريقك؟';
  }

  @override
  String get notAssignedToTeamYet => 'غير معيّن لأي فريق بعد';

  @override
  String get myManager => 'مديري';

  @override
  String get notAssignedToManager => 'أنت غير معيّن لأي مدير بعد.';

  @override
  String get vacationBalance => 'رصيد الإجازات';

  @override
  String get total => 'الإجمالي';

  @override
  String get remaining => 'المتبقي';

  @override
  String get usedLabel => 'مستخدم';

  @override
  String get daysPerMonthShort => 'أيام/شهر';

  @override
  String get daysLeft => 'أيام متبقية';

  @override
  String get daysLabel => 'أيام';

  @override
  String get salaryInfo => 'معلومات الراتب';

  @override
  String get monthlySalary => 'الراتب الشهري';

  @override
  String get employeeUserId => 'معرّف المستخدم';

  @override
  String get validating => 'جارٍ التحقق...';

  @override
  String get validateButton => 'تحقق';

  @override
  String get contractDetails => 'تفاصيل العقد';

  @override
  String get contractDetailsDescription =>
      'حدّد راتب الموظف وعدد أيام الإجازة.';

  @override
  String get employeeRoleLabel => 'موظف';

  @override
  String get hrAdminRoleLabel => 'مدير الموارد البشرية';

  @override
  String get pleaseEnterMonthlySalary => 'يرجى إدخال الراتب الشهري';

  @override
  String get pleaseEnterValidSalary => 'يرجى إدخال مبلغ راتب صالح';

  @override
  String get monthlyVacationDays => 'أيام الإجازة الشهرية';

  @override
  String get pleaseEnterVacationDays => 'يرجى إدخال أيام الإجازة';

  @override
  String get pleaseEnterValidDays => 'يرجى إدخال عدد صالح من الأيام';

  @override
  String get addToTeam => 'إضافة إلى الفريق';

  @override
  String employeeAttendanceTitle(String name) {
    return 'حضور $name';
  }

  @override
  String get workedHours => 'ساعات العمل';

  @override
  String get persistedWorkedMinutes => 'دقائق العمل المسجلة';

  @override
  String nMin(String count) {
    return '$count دقيقة';
  }

  @override
  String get breakDetails => 'تفاصيل الاستراحة';

  @override
  String breakN(int n) {
    return 'استراحة $n:';
  }

  @override
  String get editAttendanceStatus => 'تعديل حالة الحضور';

  @override
  String get editCheckInTime => 'تعديل وقت الحضور';

  @override
  String get editCheckOutTime => 'تعديل وقت الإنصراف';

  @override
  String get timeFormatHint => 'الوقت (HH:mm:ss)';

  @override
  String get earlyCheckInLabel => 'حضور مبكر';

  @override
  String get lateLabel => 'متأخر';

  @override
  String get earlyLeaveLabel => 'إنصراف مبكر';

  @override
  String get overtimeLabel => 'عمل إضافي';

  @override
  String get exitKioskMode => 'الخروج من وضع الكشك';

  @override
  String get enterPasswordToExit => 'أدخل كلمة المرور للخروج من وضع الكشك.';

  @override
  String get pleaseEnterYourPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get exitButton => 'خروج';

  @override
  String get qrNotConfigured => 'لم يتم تهيئة التحقق بالرمز';

  @override
  String get qrNotConfiguredDescription =>
      'يرجى الطلب من المسؤول إنشاء رمز سري مشترك من مولد رمز QR في الإعدادات.';

  @override
  String get active => 'نشط';

  @override
  String get kioskModeActive => 'وضع الكشك نشط';

  @override
  String get kioskModeDescription =>
      'اعرض هذه الشاشة عند مدخل مكتبك. يجب على الموظفين مسح هذا الرمز قبل تسجيل الحضور أو الاستراحة أو الإنصراف. يتم تحديث الرمز كل ٥ ثوانٍ للأمان.';

  @override
  String refreshesIn(int seconds) {
    return 'يتم التحديث خلال $seconds ثانية';
  }

  @override
  String get personalDetails => 'التفاصيل الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get notProvided => 'غير متوفر';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get editOrganizationDetails => 'تعديل تفاصيل المؤسسة';

  @override
  String get organizationDetailsUpdated => 'تم تحديث تفاصيل المؤسسة';

  @override
  String get editOrganization => 'تعديل المؤسسة';

  @override
  String get companyIdNotFound => 'معرّف الشركة غير موجود';

  @override
  String get qrCodeGenerator => 'مولد رمز QR';

  @override
  String get qrVerificationNotConfigured => 'لم يتم إعداد التحقق بـ QR';

  @override
  String get qrVerificationDescription =>
      'أنشئ مفتاحاً سرياً مشتركاً لتفعيل التحقق من الموقع عبر QR لموظفيك.';

  @override
  String get configuring => 'جارٍ الإعداد...';

  @override
  String get enableQrVerification => 'تفعيل التحقق بـ QR';

  @override
  String get qrConfiguredSuccess => 'تم إعداد التحقق بـ QR بنجاح!';

  @override
  String failedToConfigure(String error) {
    return 'فشل في الإعداد: $error';
  }

  @override
  String get instructionsLabel => 'التعليمات';

  @override
  String get qrDisplayInstructions =>
      'اعرض هذه الشاشة عند مدخل مكتبك. يجب على الموظفين مسح رمز QR هذا قبل تسجيل الحضور أو أخذ الاستراحات أو تسجيل الانصراف. يتم تحديث الرمز كل 5 ثوانٍ للأمان.';

  @override
  String refreshesInSeconds(int seconds) {
    return 'يتم التحديث خلال $seconds ثانية';
  }

  @override
  String get kioskAccountActive => 'حساب الكشك نشط';

  @override
  String get createDedicatedKioskAccount => 'أنشئ حساباً مخصصاً لأجهزة الكشك.';

  @override
  String get pleaseEnterAnEmail => 'يرجى إدخال بريد إلكتروني';

  @override
  String get pleaseEnterAValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterAPassword => 'يرجى إدخال كلمة مرور';

  @override
  String get passwordMinSixChars => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get creating => 'جارٍ الإنشاء...';

  @override
  String get kioskAccountCreatedSuccess => 'تم إنشاء حساب الكشك بنجاح!';

  @override
  String get passwordUpdatedSuccessfully => 'تم تحديث كلمة المرور بنجاح!';

  @override
  String get changeKioskPassword => 'تغيير كلمة مرور الكشك';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get pleaseEnterCurrentPassword => 'يرجى إدخال كلمة المرور الحالية';

  @override
  String get pleaseEnterNewPassword => 'يرجى إدخال كلمة مرور جديدة';

  @override
  String get pleaseConfirmNewPassword => 'يرجى تأكيد كلمة المرور الجديدة';

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String get noPayrollRecords => 'لا توجد سجلات رواتب';

  @override
  String get generatePayrollHint => 'أنشئ كشف الرواتب لعرض السجلات هنا';

  @override
  String get generate => 'إنشاء';

  @override
  String get payslip => 'كشف الراتب';

  @override
  String get noPayrollSelected => 'لم يتم اختيار كشف راتب';

  @override
  String get attendanceSummary => 'ملخص الحضور';

  @override
  String get earnings => 'الأرباح';

  @override
  String get workedDays => 'عمل';

  @override
  String get absences => 'غياب';

  @override
  String get late => 'تأخير';

  @override
  String get overtime => 'عمل إضافي';

  @override
  String get earlyLeave => 'إنصراف مبكر';

  @override
  String get noCheckout => 'بدون إنصراف';

  @override
  String get payableDays => 'أيام مستحقة';

  @override
  String get workedDaysSalary => 'راتب أيام العمل';

  @override
  String get paidVacationSalary => 'راتب الإجازة المدفوعة';

  @override
  String get overtimeBonus => 'مكافأة العمل الإضافي';

  @override
  String get absenceDeduction => 'خصم الغياب';

  @override
  String get lateDeduction => 'خصم التأخير';

  @override
  String get earlyLeaveDeduction => 'خصم الإنصراف المبكر';

  @override
  String period(String value) {
    return 'الفترة: $value';
  }

  @override
  String baseSalary(String value) {
    return 'الراتب الأساسي: $value';
  }

  @override
  String dailyRate(String value) {
    return 'المعدل اليومي: $value';
  }

  @override
  String generated(String value) {
    return 'تاريخ الإنشاء: $value';
  }

  @override
  String get formerEmployee => 'موظف سابق';

  @override
  String get former => 'سابق';

  @override
  String get payrollMonth => 'شهر الراتب';

  @override
  String get payrollInfoBanner =>
      'سيتم حساب الرواتب باستخدام راتب كل موظف الفردي من ملف الفريق. يتم تحميل قواعد الخصم من إعدادات الرواتب.';

  @override
  String get overrideExistingPayroll => 'استبدال كشف الرواتب الحالي';

  @override
  String get overrideDescription =>
      'إعادة إنشاء كشف الرواتب حتى لو كان موجوداً لهذا الشهر';

  @override
  String get activeRules => 'القواعد النشطة';

  @override
  String get generateForAll => 'إنشاء لجميع الموظفين';

  @override
  String get companyDataNotAvailable => 'بيانات الشركة غير متوفرة';

  @override
  String get payrollConfigInfo =>
      'إعداد قواعد الخصم والمكافآت للرواتب في شركتك. تنطبق هذه القواعد على جميع الموظفين.';

  @override
  String get absenceDeductionSection => 'خصم الغياب';

  @override
  String get absenceMultiplierDescription =>
      'المضاعف المطبق على الراتب اليومي لكل يوم غياب غير معتمد.';

  @override
  String get absenceMultiplierLabel => 'مضاعف الغياب (مثال: 1.0، 1.5، 2.0)';

  @override
  String get lateArrivalDeduction => 'خصم التأخر';

  @override
  String get deductionMode => 'نمط الخصم';

  @override
  String get percentageOfDailySalary => 'نسبة من الراتب اليومي';

  @override
  String get perMinuteDeduction => 'خصم لكل دقيقة';

  @override
  String get deductionPercentPerLateDay => 'نسبة الخصم لكل يوم تأخير';

  @override
  String get deductionAmountPerMinute => 'مبلغ الخصم لكل دقيقة';

  @override
  String get earlyLeaveDeductionSection => 'خصم الإنصراف المبكر';

  @override
  String get earlyLeaveDeductionDescription =>
      'الخصم المطبق عند إنصراف الموظفين قبل الموعد المحدد.';

  @override
  String get earlyLeaveDeductionMode => 'نمط خصم الإنصراف المبكر';

  @override
  String get deductionPercentPerEarlyLeave => 'نسبة الخصم لكل يوم إنصراف مبكر';

  @override
  String get overtimeBonusSection => 'مكافأة العمل الإضافي';

  @override
  String get minimumOvertimeMinutes => 'الحد الأدنى لدقائق العمل الإضافي';

  @override
  String get bonusPercentPerOvertimeDay =>
      'نسبة المكافأة من الراتب اليومي (لكل يوم عمل إضافي)';

  @override
  String get missingCheckoutPolicy => 'سياسة الإنصراف المفقود';

  @override
  String get missingCheckoutDescription =>
      'كيفية التعامل مع الأيام التي سجّل فيها الموظف حضوره ولم يسجّل إنصرافه.';

  @override
  String get policy => 'السياسة';

  @override
  String get countAsHalfDay => 'احتساب كنصف يوم';

  @override
  String get countAsAbsent => 'احتساب كغياب';

  @override
  String get saveConfiguration => 'حفظ الإعدادات';

  @override
  String get configSavedSuccessfully => 'تم حفظ الإعدادات بنجاح!';

  @override
  String get enterValidNumber => 'أدخل رقماً صحيحاً';

  @override
  String get absenceMultiplier => 'مضاعف الغياب';

  @override
  String get lateGrace => 'فترة سماح التأخير';

  @override
  String get lateDeductionRule => 'خصم التأخير';

  @override
  String get overtimeMin => 'الحد الأدنى للعمل الإضافي';

  @override
  String get overtimeBonusRule => 'مكافأة العمل الإضافي';

  @override
  String get earlyLeaveRule => 'الإنصراف المبكر';

  @override
  String get missingCheckoutRule => 'الإنصراف المفقود';

  @override
  String percentOfDailySalary(String value) {
    return '$value% من الراتب اليومي';
  }

  @override
  String perMinuteRate(String value) {
    return '$value/دقيقة';
  }

  @override
  String timesDailySalary(String value) {
    return '$value× الراتب اليومي';
  }

  @override
  String minutesSuffix(String value) {
    return '$value دقيقة';
  }

  @override
  String get selectPayrollMonth => 'اختر شهر الراتب';

  @override
  String get clearAllNotifications => 'مسح الكل';

  @override
  String notifLeaveSubmitted(String name, String days) {
    return 'قدم $name طلب إجازة لمدة $days أيام.';
  }

  @override
  String notifLeaveApproved(String name) {
    return 'وافق $name على طلب إجازتك.';
  }

  @override
  String notifLeaveRejected(String name) {
    return 'رفض $name طلب إجازتك.';
  }

  @override
  String notifLeaveRejectedWithReason(String name, String reason) {
    return 'رفض $name طلب إجازتك. السبب: $reason';
  }

  @override
  String notifLeaveCancelled(String name, String status) {
    return 'ألغى $name طلب إجازته الـ $status.';
  }

  @override
  String notifCheckIn(String name) {
    return 'سجل $name الحضور.';
  }

  @override
  String notifCheckOut(String name) {
    return 'سجل $name الانصراف.';
  }

  @override
  String notifBreakIn(String name) {
    return 'بدأ $name فترة راحة.';
  }

  @override
  String notifBreakOut(String name) {
    return 'أنهى $name فترة راحة.';
  }

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get unassignedEmployee => 'مرحباً! لم يتم تعيينك في فريق بعد.';

  @override
  String get noPayrollForUnassigned =>
      'لا توجد بيانات رواتب متاحة بعد. يرجى تعيين هذا الموظف في فريق أولاً.';
}
