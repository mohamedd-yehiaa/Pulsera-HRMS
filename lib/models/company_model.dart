class CompanyModel {
  String? uId;
  String? ownerId;
  String? organizationName;
  int? paidLeavePerMonth;
  int? sickLeavePerMonth;
  int? wfhPerMonth;
  String? startTime;
  String? endTime;
  String? companyEmail;

  CompanyModel({
    this.uId,
    this.ownerId,
    this.organizationName,
    this.paidLeavePerMonth,
    this.sickLeavePerMonth,
    this.wfhPerMonth,
    this.startTime,
    this.endTime,
    this.companyEmail,
  });

  // Receiving data from Firebase (Map -> Model)
  CompanyModel.fromJson(Map<String, dynamic>? json) {
    uId = json?['uId'];
    ownerId = json?['ownerId'];
    organizationName = json?['organizationName'];
    paidLeavePerMonth = json?['paidLeavePerMonth'];
    sickLeavePerMonth = json?['sickLeavePerMonth'];
    wfhPerMonth = json?['wfhPerMonth'];
    startTime = json?['startTime'];
    endTime = json?['endTime'];
    companyEmail = json?['companyEmail'];
  }

  // Sending data to Firebase (Model -> Map)
  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'ownerId': ownerId,
      'organizationName': organizationName,
      'paidLeavePerMonth': paidLeavePerMonth,
      'sickLeavePerMonth': sickLeavePerMonth,
      'wfhPerMonth': wfhPerMonth,
      'startTime': startTime,
      'endTime': endTime,
      'companyEmail': companyEmail,
    };
  }
}