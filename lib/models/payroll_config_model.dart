class PayrollConfigModel {
  String? companyId;
  double absenceMultiplier;        // e.g. 1.0, 1.5, 2.0 × daily salary
  int lateGracePeriodMinutes;      // e.g. 15
  String lateDeductionMode;        // 'percentage' or 'minutes'
  double lateDeductionValue;       // % of daily salary OR per-minute deduction amount
  int overtimeMinMinutes;          // minimum minutes to qualify as overtime
  double overtimeBonusPercentage;  // % of daily salary per qualifying overtime event

  PayrollConfigModel({
    this.companyId,
    this.absenceMultiplier = 1.0,
    this.lateGracePeriodMinutes = 15,
    this.lateDeductionMode = 'percentage',
    this.lateDeductionValue = 0.0,
    this.overtimeMinMinutes = 30,
    this.overtimeBonusPercentage = 0.0,
  });

  PayrollConfigModel.fromJson(Map<String, dynamic> json)
      : companyId = json['companyId'],
        absenceMultiplier = (json['absenceMultiplier'] as num?)?.toDouble() ?? 1.0,
        lateGracePeriodMinutes = json['lateGracePeriodMinutes'] ?? 15,
        lateDeductionMode = json['lateDeductionMode'] ?? 'percentage',
        lateDeductionValue = (json['lateDeductionValue'] as num?)?.toDouble() ?? 0.0,
        overtimeMinMinutes = json['overtimeMinMinutes'] ?? 30,
        overtimeBonusPercentage = (json['overtimeBonusPercentage'] as num?)?.toDouble() ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'absenceMultiplier': absenceMultiplier,
      'lateGracePeriodMinutes': lateGracePeriodMinutes,
      'lateDeductionMode': lateDeductionMode,
      'lateDeductionValue': lateDeductionValue,
      'overtimeMinMinutes': overtimeMinMinutes,
      'overtimeBonusPercentage': overtimeBonusPercentage,
    };
  }

  /// Creates a default configuration for a new company.
  factory PayrollConfigModel.defaults({required String companyId}) {
    return PayrollConfigModel(
      companyId: companyId,
      absenceMultiplier: 1.0,
      lateGracePeriodMinutes: 15,
      lateDeductionMode: 'percentage',
      lateDeductionValue: 0.0,
      overtimeMinMinutes: 30,
      overtimeBonusPercentage: 0.0,
    );
  }
}
