class MemberModel {
  String? teamId;
  MembersData? manager;
  List<MembersData>? members;

  MemberModel({this.teamId, this.manager, this.members});

  MembersData? getMemberByUid(String? uId) {
    if (uId == null || members == null) return null;

    // Use a try-catch or firstWhere with orElse to avoid crashes
    try {
      return members!.firstWhere((m) => m.uId == uId);
    } catch (e) {
      return null; // Not found in this team
    }
  }

  MemberModel.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    manager = json['manager'] != null
        ? MembersData.fromJson(json['manager'])
        : null;
    if (json['members'] is List) {
      members = (json['members'] as List)
          .map((v) => MembersData.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      if (manager != null) 'manager': manager!.toJson(),
      if (members != null) 'members': members!.map((v) => v.toJson()).toList(),
    };
  }
}

class MembersData {
  String? uId; // To link to UserModel
  String? fullName; // Redundant but helpful for quick UI display
  String? roleType; // Their specific role in THIS team
  String? email; // Redundant but helpful for quick UI display
  String? image;
  String? managerId; // Who they report to
  double? monthlySalary;
  int? monthlyVacationDays;
  int? remainingVacationDays;
  String? joinedAt; // Better than 'createdAt'—when they joined this team
  String? status; // 'Active' or 'Terminated'
  String? endDate; // ISO 8601 — last working day (set on termination)

  MembersData({
    this.uId,
    this.fullName,
    this.roleType,
    this.email,
    this.image,
    this.managerId,
    this.monthlySalary,
    this.monthlyVacationDays,
    this.remainingVacationDays,
    this.joinedAt,
    this.status = 'Active',
    this.endDate,
  });

  MembersData.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    fullName = json['fullName'];
    roleType = json['roleType'];
    email = json['email'];
    image = json['image'];
    managerId = json['managerId'];
    monthlySalary = (json['monthlySalary'] as num?)?.toDouble();
    monthlyVacationDays =
        json['monthlyVacationDays'] ?? json['annualVacationDays'];
    remainingVacationDays = json['remainingVacationDays'];
    joinedAt = json['joinedAt'];
    status = json['status'] ?? 'Active';
    endDate = json['endDate'];
  }
  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'fullName': fullName,
      'roleType': roleType,
      'email': email,
      'image': image,
      'managerId': managerId,
      'monthlySalary': monthlySalary,
      'monthlyVacationDays': monthlyVacationDays,
      'remainingVacationDays': remainingVacationDays,
      'joinedAt': joinedAt,
      'status': status ?? 'Active',
      'endDate': endDate,
    };
  }
}
