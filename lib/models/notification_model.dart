import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  String? id;
  String? toUserId;
  String? fromUserName;
  String? message;
  String? messageKey;
  Map<String, dynamic>? messageParams;
  // leave_submitted, leave_approved, leave_rejected, leave_cancelled,
  // attendance_checkin, attendance_checkout
  String? type;
  String? leaveId;
  DateTime? createdAt;
  bool isRead;

  NotificationModel({
    this.id,
    this.toUserId,
    this.fromUserName,
    this.message,
    this.messageKey,
    this.messageParams,
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
    messageKey = json['messageKey'];
    if (json['messageParams'] != null) {
      messageParams = Map<String, dynamic>.from(json['messageParams']);
    }
    type = json['type'];
    leaveId = json['leaveId'];
    if (json['createdAt'] != null) {
      final raw = json['createdAt'];
      if (raw is Timestamp) {
        createdAt = raw.toDate();
      } else if (raw is String) {
        createdAt = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(raw);
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'message': message,
      'messageKey': messageKey,
      'messageParams': messageParams,
      'type': type,
      'leaveId': leaveId,
      'createdAt': createdAt != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt!)
          : null,
      'isRead': isRead,
    };
  }
}
