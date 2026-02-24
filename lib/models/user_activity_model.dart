
class UserActivityModel {
  List<String>? breakOutTime;
  List<String>? breakInTime;
  String? activityID;
  CheckIn? checkIn;
  OutTime? outTime;
  String? createdAt;

  UserActivityModel({
    this.breakOutTime,
    this.activityID,
    this.checkIn,
    this.breakInTime,
    this.outTime,
    this.createdAt,
  });

  UserPerformActivty get nextAction {
    // 1. If no check-in yet, user must check in
    if (checkIn == null) return UserPerformActivty.IN;
    // 2. If already checked out, default to OUT or a 'Done' state
    if (outTime != null) return UserPerformActivty.OUT;
    // 3. Logic for Breaks
    int inCount = breakInTime?.length ?? 0;
    int outCount = breakOutTime?.length ?? 0;
    // If they have more "In" breaks than "Out" breaks, they are currently ON break
    if (inCount > outCount) {
      return UserPerformActivty.BREAKOUT;
    }
    // If they aren't on break and haven't checked out, they can either take a break or check out.
    return UserPerformActivty.BREAKIN;
  }

  UserActivityModel.fromJson(Map<String, dynamic> json) {
    activityID = json['activityID'];
    createdAt = json['date'];
    checkIn = json['checkIn'] != null ? CheckIn.fromJson(json['checkIn']) : null;
    outTime = json['outTime'] != null ? OutTime.fromJson(json['outTime']) : null;

    breakInTime = (json['breakInTime'] as List<dynamic>?)?.cast<String>();
    breakOutTime = (json['breakOutTime'] as List<dynamic>?)?.cast<String>();
  }
}

class CheckIn {
  String? inTime;
  String? msg;

  CheckIn({this.inTime, this.msg});

  CheckIn.fromJson(Map<String, dynamic> json) {
    inTime = json['inTime'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inTime'] = inTime;
    data['msg'] = msg;
    return data;
  }
}

class OutTime {
  String? msg;
  String? outTime;

  OutTime({this.msg, this.outTime});

  OutTime.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    outTime = json['outTime'];
  }
}

enum UserPerformActivty {
  IN,
  OUT,
  BREAKIN,
  BREAKOUT;

  String get label {
    return switch (this) {
      UserPerformActivty.IN => "Swipe to Check in.",
      UserPerformActivty.BREAKIN => "Swipe to Break in.",
      UserPerformActivty.BREAKOUT => "Swipe to Break out.",
      UserPerformActivty.OUT => "Swipe to Check out.",
    };
  }
}
