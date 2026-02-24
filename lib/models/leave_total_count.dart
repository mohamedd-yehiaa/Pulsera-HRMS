class LeaveTotalCountModel {
  int? totalLeaveCancelled;
  int? totalLeaveApproved;
  int? totalLeaveBalance;
  int? totalLeavePending;

  LeaveTotalCountModel({this.totalLeaveCancelled, this.totalLeaveApproved, this.totalLeaveBalance, this.totalLeavePending});

  LeaveTotalCountModel.fromJson(Map<String, dynamic> json) {
    totalLeaveCancelled = json['totalLeaveCancelled'];
    totalLeaveApproved = json['totalLeaveApproved'];
    totalLeaveBalance = json['totalLeaveBalance'];
    totalLeavePending = json['totalLeavePending'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalLeaveCancelled'] = totalLeaveCancelled;
    data['totalLeaveApproved'] = totalLeaveApproved;
    data['totalLeaveBalance'] = totalLeaveBalance;
    data['totalLeavePending'] = totalLeavePending;
    return data;
  }
}
