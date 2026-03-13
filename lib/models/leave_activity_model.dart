import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/team_members_model.dart';
import '../shared/styles/colors.dart';


class LeaveActivityModel {
  String? id;
  String? userID;
  String? companyID;
  String? teamId;
  MembersData? approvalTo;
  DateTime? applyDate;
  LeaveActivityState? leaveStatus;
  DateTime? fromdate;
  DateTime? todate;
  int? totalDays;
  String? leaveReason;
  String? rejectedReason;
  MembersData? user;

  LeaveActivityModel({
    this.id,
    this.userID,
    this.companyID,
    this.teamId,
    this.approvalTo,
    this.applyDate,
    this.leaveStatus,
    this.fromdate,
    this.todate,
    this.totalDays,
    this.leaveReason,
    this.rejectedReason,
    this.user,
  });

  LeaveActivityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userID = json['userID'];
    companyID = json['companyID'];
    teamId = json['teamId'];
    if (json['user'] != null) {
      user = MembersData.fromJson(json['user']);
    }
    if (json['approvalTo'] != null) {
      approvalTo = MembersData.fromJson(json['approvalTo']);
    }
    leaveStatus = LeaveActivityState.fromStrings(json['leaveStatus']);
    totalDays = json['totalDays'];

    if (json['fromdate'] != null) {
      fromdate = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json['fromdate']);
    }
    if (json['todate'] != null) {
      todate = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json['todate']);
    }
    if (json['applyDate'] != null) {
      applyDate = DateFormat("yyyy-MM-dd").parse(json['applyDate']);
    }
    leaveReason = json['leaveReason'];
    rejectedReason = json['rejectedReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userID'] = userID;
    data['companyID'] = companyID;
    data['teamId'] = teamId;
    data['approvalTo'] = approvalTo?.toJson();
    data['applyDate'] = applyDate != null
        ? DateFormat('yyyy-MM-dd').format(applyDate!)
        : null;
    data['leaveStatus'] = leaveStatus?.code;
    data['fromdate'] = fromdate != null
        ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(fromdate!)
        : null;
    data['todate'] = todate != null
        ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(todate!)
        : null;
    data['totalDays'] = totalDays;
    data['leaveReason'] = leaveReason;
    data['rejectedReason'] = rejectedReason;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

  /// Calculates leave days (inclusive of start and end date).
  static int calculateTotalDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}

enum LeaveActivityState {
  pending,
  approved,
  rejected,
  cancelled;

  static List<String> get list {
    return [
      "Pending",
      "Approved",
      "Rejected",
      "Cancelled",
    ];
  }

  static LeaveActivityState? fromStrings(String val) {
    switch (val.toUpperCase()) {
      case ("PENDING"):
        return LeaveActivityState.pending;
      case ("APPROVED"):
        return LeaveActivityState.approved;
      case ("REJECTED"):
        return LeaveActivityState.rejected;
      case ("CANCELLED"):
        return LeaveActivityState.cancelled;
    }
    return null;
  }

  String get code {
    return switch (this) {
      (pending) => "PENDING",
      (approved) => "APPROVED",
      (rejected) => "REJECTED",
      (cancelled) => "CANCELLED",
    };
  }

  String get getName {
    return switch (this) {
      (pending) => "Pending",
      (approved) => "Approved",
      (rejected) => "Rejected",
      (cancelled) => "Cancelled",
    };
  }

  Color get getColor {
    return switch (this) {
      (pending) => (AppColors.blue700),
      (approved) => (AppColors.green500),
      (rejected) => (AppColors.error),
      (cancelled) => (AppColors.orange500),
    };
  }
}
