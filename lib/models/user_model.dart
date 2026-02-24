class UserModel {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? uId;
  String? image;
  String? companyId;
  bool? isEmailVerified;

  UserModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.uId,
    this.image,
    this.companyId,
    this.isEmailVerified,
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
    };
  }
}