import 'package:intl/intl.dart';

class NotificationModel {
  String? id;
  String? toUserId;
  String? fromUserName;
  String? message;
  String? type; // leave_submitted, leave_approved, leave_rejected, leave_cancelled
  String? leaveId;
  DateTime? createdAt;
  bool isRead;

  NotificationModel({
    this.id,
    this.toUserId,
    this.fromUserName,
    this.message,
    this.type,
    this.leaveId,
    this.createdAt,
    this.isRead = false,
  });

  NotificationModel.fromJson(Map<String, dynamic> json)
      : isRead = json['isRead'] ?? false {
    id = json['id'];
    toUserId = json['toUserId'];
    fromUserName = json['fromUserName'];
    message = json['message'];
    type = json['type'];
    leaveId = json['leaveId'];
    if (json['createdAt'] != null) {
      createdAt = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json['createdAt']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'message': message,
      'type': type,
      'leaveId': leaveId,
      'createdAt': createdAt != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt!)
          : null,
      'isRead': isRead,
    };
  }
}
