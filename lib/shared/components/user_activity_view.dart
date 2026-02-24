import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/shared/components/components.dart';
import '../../models/user_activity_model.dart';
import '../styles/icon_broken.dart';

class UserActivityView extends StatelessWidget {
  final UserActivityModel? userActivityModel;

  const UserActivityView({required this.userActivityModel, super.key});

  @override
  Widget build(BuildContext context) {
    if (userActivityModel == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        // 1. Check In Card
        if (userActivityModel!.checkIn != null) ...[
          ActivityCard(
            iconData: IconBroken.Login ,
            title: "Check In",
            dateTime: _safeParseDateTime(
              userActivityModel!.createdAt,
              userActivityModel!.checkIn!.inTime,
            ),
            description: userActivityModel!.checkIn?.msg ?? '-',
          ),
        ],

        // 2. Break Times (In/Out)
        _buildBreakList(
          userActivityModel?.breakInTime ?? [],
          userActivityModel?.breakOutTime ?? [],
        ),

        // 3. Check Out Card
        if (userActivityModel!.outTime != null) ...[
          const SizedBox(height: 16),
          ActivityCard(
            iconData: IconBroken.Logout, // Changed to logout icon for clarity
            title: "Check Out",
            dateTime: _safeParseDateTime(
              userActivityModel!.createdAt,
              userActivityModel!.outTime!.outTime,
            ),
            description: userActivityModel!.outTime?.msg ?? '-',
          ),
        ],
      ],
    );
  }

  Widget _buildBreakList(List<String> inTimes, List<String> outTimes) {
    // Assuming mergeBreakInBreakOutTimes is a global helper or defined in components.dart
    var newList = mergeBreakInBreakOutTimes(inTimes, outTimes);

    return Column(
      children: List.generate(newList.length, (index) {
        bool isBreakIn = index.isEven;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ActivityCard(
            iconData: isBreakIn
                ? Icons.coffee_outlined
                : Icons.coffee_maker_outlined,
            title: isBreakIn ? "Break In" : "Break Out",
            dateTime: _safeParseDateTime(
              userActivityModel!.createdAt,
              newList[index],
            ),
            description: "",
          ),
        );
      }),
    );
  }

  // Helper to handle parsing safely
  DateTime _safeParseDateTime(String? date, String? time) {
    if (date == null || time == null) return DateTime.now();
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse("$date $time");
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return DateTime.now();
    }
  }
}

List<String> mergeBreakInBreakOutTimes(
  List<String> inTimes,
  List<String> outTimes,
) {
  List<String> mergedTimes = [];
  int maxLength = inTimes.length > outTimes.length
      ? inTimes.length
      : outTimes.length;

  for (int i = 0; i < maxLength; i++) {
    if (i < inTimes.length) {
      mergedTimes.add(inTimes[i]);
    }
    if (i < outTimes.length) {
      mergedTimes.add(outTimes[i]);
    }
  }

  return mergedTimes;
}
