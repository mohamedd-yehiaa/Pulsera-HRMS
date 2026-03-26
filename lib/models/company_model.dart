class CompanyModel {
  String? companyId;
  String? ownerId;
  String? organizationName;
  int? paidLeavePerMonth;
  int? sickLeavePerMonth;
  int? wfhPerMonth;
  String? startTime;
  String? endTime;
  String? companyEmail;
  List<String>? workingDays;

  /// How many minutes after startTime is still considered "on time".
  int? gracePeriodMinutes;

  /// How many minutes before startTime an employee may check in.
  int? earlyAllowanceMinutes;

  /// Minutes after startTime beyond which check-in is marked "very late".
  int? lateCutoffMinutes;

  /// Minimum hours an employee should work per day.
  int? minimumWorkHours;

  CompanyModel({
    this.companyId,
    this.ownerId,
    this.organizationName,
    this.paidLeavePerMonth,
    this.sickLeavePerMonth,
    this.wfhPerMonth,
    this.startTime,
    this.endTime,
    this.companyEmail,
    this.workingDays,
    this.gracePeriodMinutes,
    this.earlyAllowanceMinutes,
    this.lateCutoffMinutes,
    this.minimumWorkHours,
  });

  // Receiving data from Firebase (Map -> Model)
  CompanyModel.fromJson(Map<String, dynamic>? json) {
    companyId = json?['companyId'];
    ownerId = json?['ownerId'];
    organizationName = json?['organizationName'];
    paidLeavePerMonth = json?['paidLeavePerMonth'];
    sickLeavePerMonth = json?['sickLeavePerMonth'];
    wfhPerMonth = json?['wfhPerMonth'];
    startTime = json?['startTime'];
    endTime = json?['endTime'];
    companyEmail = json?['companyEmail'];
    gracePeriodMinutes = json?['gracePeriodMinutes'];
    earlyAllowanceMinutes = json?['earlyAllowanceMinutes'];
    lateCutoffMinutes = json?['lateCutoffMinutes'];
    minimumWorkHours = json?['minimumWorkHours'];
    // Safe casting for the List
    if (json?['workingDays'] != null) {
      workingDays = List<String>.from(json?['workingDays']);
    }
  }

  // Sending data to Firebase (Model -> Map)
  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'ownerId': ownerId,
      'organizationName': organizationName,
      'paidLeavePerMonth': paidLeavePerMonth,
      'sickLeavePerMonth': sickLeavePerMonth,
      'wfhPerMonth': wfhPerMonth,
      'startTime': startTime,
      'endTime': endTime,
      'companyEmail': companyEmail,
      'workingDays': workingDays,
      if (gracePeriodMinutes != null) 'gracePeriodMinutes': gracePeriodMinutes,
      if (earlyAllowanceMinutes != null) 'earlyAllowanceMinutes': earlyAllowanceMinutes,
      if (lateCutoffMinutes != null) 'lateCutoffMinutes': lateCutoffMinutes,
      if (minimumWorkHours != null) 'minimumWorkHours': minimumWorkHours,
    };
  }
}

