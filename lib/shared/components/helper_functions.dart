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

/// Replaces Get.back()
void closeDialogs(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

// --- Logic functions remain mostly the same (no Get dependencies) ---

final workingDaysMapping = <String, int>{
  "MONDAY": 1,
  "TUESDAY": 2,
  "WEDNESDAY": 3,
  "THURSDAY": 4,
  "FRIDAY": 5,
  "SATURDAY": 6,
  "SUNDAY": 7,
};

List<int> workingDays(List<String> days) {
  return days
      .where((day) => workingDaysMapping.containsKey(day))
      .map((day) => workingDaysMapping[day]!)
      .toList();
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