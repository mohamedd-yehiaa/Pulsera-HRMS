class UserModel {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? uId;
  String? image;
  String? companyId;
  bool? isEmailVerified;
  String? userType;
  String? managerId;
  String? roleType;



  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.uId,
    this.image,
    this.companyId,
    this.isEmailVerified,
    this.userType,
    this.managerId,
    this.roleType,
  });

  UserModel.fromJson(Map<String, dynamic> json)
  {
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    uId = json['uId'];
    image = json['image'];
    companyId = json['companyId'];
    isEmailVerified = json['isEmailVerified'];
    userType = json['userType'];
    managerId = json['managerId'];
    roleType = json['roleType'];
  }

  Map<String, dynamic> toMap()
  {
    return {
      'firstName':firstName,
      'lastName':lastName,
      'email':email,
      'phone':phone,
      'uId':uId,
      'image':image,
      'companyId':companyId,
      'isEmailVerified':isEmailVerified,
      'userType':userType,
      'managerId':managerId,
      'roleType':roleType,
    };
  }
}