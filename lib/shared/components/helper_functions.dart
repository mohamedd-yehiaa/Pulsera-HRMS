import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showSuccessSnack(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


void showErrorSnack(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


void closeDialogs(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

String secondsToTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, "0");
  return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(remainingSeconds)}";
}

String formatTimeOfDay(TimeOfDay timeOfDay) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return "${twoDigits(timeOfDay.hour)}:${twoDigits(timeOfDay.minute)}:00";
}

List<String> mergeBreakInBreakOutTimes(List<String> inTimes, List<String> outTimes) {
  List<String> mergedTimes = [];
  int maxLength = inTimes.length > outTimes.length ? inTimes.length : outTimes.length;

  for (int i = 0; i < maxLength; i++) {
    if (i < inTimes.length) mergedTimes.add(inTimes[i]);
    if (i < outTimes.length) mergedTimes.add(outTimes[i]);
  }
  return mergedTimes;
}

TimeOfDay parseTimeOfDay(String timeString) {
  // Assuming format is "HH:mm" or "HH:mm AM/PM"
  // This example handles "14:30" or "02:30 PM" style
  final format = RegExp(r'(\d+):(\d+)');
  final match = format.firstMatch(timeString);

  if (match != null) {
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);

    // Handle PM if your string contains it
    if (timeString.toLowerCase().contains('pm') && hour < 12) hour += 12;
    if (timeString.toLowerCase().contains('am') && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }
  return const TimeOfDay(hour: 9, minute: 0); // Default fallback
}