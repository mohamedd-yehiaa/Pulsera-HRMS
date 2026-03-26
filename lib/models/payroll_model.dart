class PayrollModel {
  String? payrollId;
  String? employeeId;
  String? employeeName;
  String? companyId;
  String? month; // "YYYY-MM" format
  String? generatedDate; // ISO 8601
  String? employeeStatus; // 'Active' or 'Former Employee'

  // --- Salary components ---
  double? basicSalary; // Monthly base salary
  double? dailySalary; // Computed: basicSalary ÷ totalWorkingDays

  // --- Attendance breakdown ---
  int? totalWorkingDays; // Total official working days in the month
  int? workedDays; // Actual days attended
  int? paidVacationDays; // Approved leave days (no deduction)
  int? unapprovedAbsenceDays; // Days absent without approval
  int? lateMinutes; // Total late minutes beyond grace
  int? overtimeMinutes; // Total overtime minutes
  int? earlyLeaveMinutes; // Total early-departure minutes
  int? missingCheckoutDays; // Days with check-in but no check-out
  int? totalPayableDays; // workedDays + paidVacationDays

  // --- Calculated amounts ---
  double? workedDaysSalary; // workedDays × dailySalary
  double? paidVacationSalary; // paidVacationDays × dailySalary
  double? absenceDeduction; // unapprovedAbsences × multiplier × dailySalary
  double? lateDeduction; // Configurable late deduction total
  double? overtimeBonus; // Configurable overtime bonus total
  double? earlyLeaveDeduction; // Configurable early-leave deduction total
  double? finalSalary; // Net salary

  PayrollModel({
    this.payrollId,
    this.employeeId,
    this.employeeName,
    this.companyId,
    this.month,
    this.generatedDate,
    this.employeeStatus,
    this.basicSalary,
    this.dailySalary,
    this.totalWorkingDays,
    this.workedDays,
    this.paidVacationDays,
    this.unapprovedAbsenceDays,
    this.lateMinutes,
    this.overtimeMinutes,
    this.earlyLeaveMinutes,
    this.missingCheckoutDays,
    this.totalPayableDays,
    this.workedDaysSalary,
    this.paidVacationSalary,
    this.absenceDeduction,
    this.lateDeduction,
    this.overtimeBonus,
    this.earlyLeaveDeduction,
    this.finalSalary,
  });

  PayrollModel.fromJson(Map<String, dynamic> json) {
    payrollId = json['payrollId'];
    employeeId = json['employeeId'];
    employeeName = json['employeeName'];
    companyId = json['companyId'];
    month = json['month'];
    generatedDate = json['generatedDate'];
    employeeStatus = json['employeeStatus'];
    basicSalary = (json['basicSalary'] as num?)?.toDouble();
    dailySalary = (json['dailySalary'] as num?)?.toDouble();
    totalWorkingDays = json['totalWorkingDays'];
    workedDays = json['workedDays'];
    paidVacationDays = json['paidVacationDays'];
    unapprovedAbsenceDays = json['unapprovedAbsenceDays'];
    lateMinutes = json['lateMinutes'];
    overtimeMinutes = json['overtimeMinutes'];
    earlyLeaveMinutes = json['earlyLeaveMinutes'];
    missingCheckoutDays = json['missingCheckoutDays'];
    totalPayableDays = json['totalPayableDays'];
    workedDaysSalary = (json['workedDaysSalary'] as num?)?.toDouble();
    paidVacationSalary = (json['paidVacationSalary'] as num?)?.toDouble();
    absenceDeduction = (json['absenceDeduction'] as num?)?.toDouble();
    lateDeduction = (json['lateDeduction'] as num?)?.toDouble();
    overtimeBonus = (json['overtimeBonus'] as num?)?.toDouble();
    earlyLeaveDeduction = (json['earlyLeaveDeduction'] as num?)?.toDouble();
    finalSalary = (json['finalSalary'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'payrollId': payrollId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'companyId': companyId,
      'month': month,
      'generatedDate': generatedDate,
      'employeeStatus': employeeStatus,
      'basicSalary': basicSalary,
      'dailySalary': dailySalary,
      'totalWorkingDays': totalWorkingDays,
      'workedDays': workedDays,
      'paidVacationDays': paidVacationDays,
      'unapprovedAbsenceDays': unapprovedAbsenceDays,
      'lateMinutes': lateMinutes,
      'overtimeMinutes': overtimeMinutes,
      'earlyLeaveMinutes': earlyLeaveMinutes,
      'missingCheckoutDays': missingCheckoutDays,
      'totalPayableDays': totalPayableDays,
      'workedDaysSalary': workedDaysSalary,
      'paidVacationSalary': paidVacationSalary,
      'absenceDeduction': absenceDeduction,
      'lateDeduction': lateDeduction,
      'overtimeBonus': overtimeBonus,
      'earlyLeaveDeduction': earlyLeaveDeduction,
      'finalSalary': finalSalary,
    };
  }
}
