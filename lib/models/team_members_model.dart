class MemberModel {
  MembersData? manager;
  List<MembersData>? members;

  MemberModel({this.manager, this.members});

  MemberModel.fromJson(Map<String, dynamic> json) {
    manager = json['manager'] != null
        ? MembersData.fromJson(json['manager'])
        : null;
    if (json['members'] != null) {
      members = <MembersData>[];
      json['members'].forEach((v) {
        members!.add(MembersData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (manager != null) {
      data['manager'] = manager!.toJson();
    }
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MembersData {
  String? id;
  String? userName;
  String? fullName;
  String? createdAt;
  String? roleType;

  MembersData(
      {this.id, this.userName, this.fullName, this.createdAt, this.roleType});

  MembersData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    fullName = json['fullName'];
    createdAt = json['createdAt'];
    roleType = json['roleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userName'] = userName;
    data['fullName'] = fullName;
    data['createdAt'] = createdAt;
    data['roleType'] = roleType;
    return data;
  }
}
