class UserActivityModel {
  List<String>? breakOutTime;
  List<String>? breakInTime;
  String? activityID;
  CheckIn? checkIn;
  OutTime? outTime;
  String? createdAt;

  /// The team (manager) this attendance record belongs to.
  String? teamId;

  /// Net worked minutes (stored on check-out for payroll readiness).
  int? workedMinutes;

  /// Attendance status: 'present', 'late', or 'absent'.
  String? status;

  /// Minutes late past grace period (stored on check-in).
  int? lateMinutes;

  /// Minutes before workEndTime that employee checked out.
  int? earlyLeaveMinutes;

  /// Minutes worked past workEndTime.
  int? overtimeMinutes;

  /// Check-in status: 'early', 'on_time', 'late', 'very_late'.
  String? checkInStatus;

  /// Check-out status: 'early_leave', 'completed', 'overtime', 'insufficient_hours'.
  String? checkOutStatus;

  UserActivityModel({
    this.breakOutTime,
    this.activityID,
    this.checkIn,
    this.breakInTime,
    this.outTime,
    this.createdAt,
    this.teamId,
    this.workedMinutes,
    this.status,
    this.lateMinutes,
    this.earlyLeaveMinutes,
    this.overtimeMinutes,
    this.checkInStatus,
    this.checkOutStatus,
  });

  UserPerformActivty get nextAction {
    // 1. If no check-in yet, user must check in
    if (checkIn == null) return UserPerformActivty.IN;
    // 2. If already checked out, day is done
    if (outTime != null) return UserPerformActivty.DONE;
    // 3. If on an active break, end it first
    int inCount = breakInTime?.length ?? 0;
    int outCount = breakOutTime?.length ?? 0;
    if (inCount > outCount) {
      return UserPerformActivty.BREAKOUT;
    }
    // 4. Primary action is Check-out (break is offered via separate button)
    return UserPerformActivty.OUT;
  }

  /// Whether the employee can start a break right now.
  bool get canTakeBreak {
    if (checkIn == null || outTime != null) return false;
    int inCount = breakInTime?.length ?? 0;
    int outCount = breakOutTime?.length ?? 0;
    return inCount <= outCount; // Not currently on break
  }

  /// Whether the employee is currently on an active break.
  bool get isOnBreak {
    if (checkIn == null || outTime != null) return false;
    int inCount = breakInTime?.length ?? 0;
    int outCount = breakOutTime?.length ?? 0;
    return inCount > outCount;
  }

  UserActivityModel.fromJson(Map<String, dynamic> json) {
    activityID = json['activityID'];
    createdAt = json['date'];
    checkIn = json['checkIn'] != null
        ? CheckIn.fromJson(json['checkIn'])
        : null;
    outTime = json['outTime'] != null
        ? OutTime.fromJson(json['outTime'])
        : null;

    breakInTime = (json['breakInTime'] as List<dynamic>?)?.cast<String>();
    breakOutTime = (json['breakOutTime'] as List<dynamic>?)?.cast<String>();
    teamId = json['teamId'];
    workedMinutes = json['workedMinutes'];
    status = json['status'];
    lateMinutes = json['lateMinutes'];
    earlyLeaveMinutes = json['earlyLeaveMinutes'];
    overtimeMinutes = json['overtimeMinutes'];
    checkInStatus = json['checkInStatus'];
    checkOutStatus = json['checkOutStatus'];
  }

  Map<String, dynamic> toJson() {
    return {
      'activityID': activityID,
      'date': createdAt,
      if (checkIn != null) 'checkIn': checkIn!.toJson(),
      if (outTime != null) 'outTime': outTime!.toJson(),
      'breakInTime': breakInTime,
      'breakOutTime': breakOutTime,
      if (teamId != null) 'teamId': teamId,
      if (workedMinutes != null) 'workedMinutes': workedMinutes,
      if (status != null) 'status': status,
      if (lateMinutes != null) 'lateMinutes': lateMinutes,
      if (earlyLeaveMinutes != null) 'earlyLeaveMinutes': earlyLeaveMinutes,
      if (overtimeMinutes != null) 'overtimeMinutes': overtimeMinutes,
      if (checkInStatus != null) 'checkInStatus': checkInStatus,
      if (checkOutStatus != null) 'checkOutStatus': checkOutStatus,
    };
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

  Map<String, dynamic> toJson() {
    return {'msg': msg, 'outTime': outTime};
  }
}

enum UserPerformActivty {
  IN,
  OUT,
  BREAKIN,
  BREAKOUT,
  DONE;

  String get label {
    return switch (this) {
      UserPerformActivty.IN => "Swipe to Check in.",
      UserPerformActivty.BREAKIN => "Swipe to Break in.",
      UserPerformActivty.BREAKOUT => "Swipe to Break out.",
      UserPerformActivty.OUT => "Swipe to Check out.",
      UserPerformActivty.DONE => "Day Completed ✓",
    };
  }
}
