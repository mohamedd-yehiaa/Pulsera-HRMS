// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pulsera/shared/cubit/app_cubit.dart';
// import 'package:pulsera/shared/cubit/states.dart';
// import '../../models/user_model.dart';
//
// class ProfileCubit extends Cubit<ProfileStates> {
//   ProfileCubit() : super(ProfileInitialState());
//
//   static ProfileCubit get(context) => BlocProvider.of(context);
//
//   // Controllers for the text fields
//   var organizationTC = TextEditingController();
//   var userName = TextEditingController();
//
//   List<WorkingDaysModel> workingDays = [];
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//
//   // Initialize using your UserModel instead of AppStorage
//   void initProfileData(UserModel user) {
//     organizationTC.text = user.companyId ?? ''; // Or companyName if you add it
//     userName.text = '${user.firstName} ${user.lastName}';
//
//     workingDays =
//         [
//               "Monday",
//               "Tuesday",
//               "Wednesday",
//               "Thursday",
//               "Friday",
//               "Saturday",
//               "Sunday",
//             ]
//             .map(
//               (e) => WorkingDaysModel(
//                 label: e,
//                 code: e.toUpperCase(),
//                 // Check if user has working days (you might need to add this field to your model)
//                 isSelected: false,
//               ),
//             )
//             .toList();
//
//     // Default times
//     startTime = const TimeOfDay(hour: 9, minute: 0);
//     endTime = const TimeOfDay(hour: 17, minute: 0);
//
//     emit(ProfileInitialState());
//   }
//
//   void onWorkingDaysChange(int index) {
//     workingDays[index].isSelected = !workingDays[index].isSelected;
//     emit(ProfileUpdateWorkingDaysState());
//   }
//
//   Future<void> updateProfile(var uId) async {
//     emit(ProfileLoadingState());
//
//     // Filter selected days
//     List<String> selectedCodes = workingDays
//         .where((e) => e.isSelected)
//         .map((e) => e.code)
//         .toList();
//
//     // Update Firestore
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(uId)
//         .update({
//           'companyName': organizationTC.text,
//           'startTime': '${startTime!.hour}:${startTime!.minute}',
//           'endTime': '${endTime!.hour}:${endTime!.minute}',
//           'workingDays': selectedCodes,
//         })
//         .then((value) {
//           emit(ProfileSuccessState());
//         })
//         .catchError((error) {
//           emit(ProfileErrorState(error.toString()));
//         });
//   }
// }
//
// class WorkingDaysModel {
//   final String label;
//   final String code;
//   bool isSelected;
//   WorkingDaysModel({
//     required this.label,
//     required this.code,
//     required this.isSelected,
//   });
// }
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import '../../models/user_model.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());

  static ProfileCubit get(context) => BlocProvider.of(context);

  final organizationTC = TextEditingController();
  final userNameTC = TextEditingController();

  List<WorkingDaysModel> workingDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void initProfileData(UserModel user) {
    organizationTC.text = user.companyId ?? '';
    userNameTC.text = '${user.firstName} ${user.lastName}';

    // Initialize days
    workingDays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ].map((e) => WorkingDaysModel(
      label: e,
      code: e.toUpperCase(),
      isSelected: false,
    )).toList();

    startTime = const TimeOfDay(hour: 9, minute: 0);
    endTime = const TimeOfDay(hour: 17, minute: 0);

    emit(ProfileDataLoadedState());
  }

  // Handle Checkbox toggles
  void onWorkingDaysChange(int index) {
    workingDays[index].isSelected = !workingDays[index].isSelected;
    emit(ProfileUpdateWorkingDaysState());
  }

  // Handle Time Selection
  Future<void> selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      if (isStart) {
        startTime = picked;
      } else {
        endTime = picked;
      }
      emit(ProfileTimeChangedState());
    }
  }

  Future<void> updateProfile(var uId) async {
    emit(ProfileLoadingState());

    List<String> selectedCodes = workingDays
        .where((e) => e.isSelected)
        .map((e) => e.code)
        .toList();

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({
      'companyName': organizationTC.text,
      'startTime': '${startTime!.hour}:${startTime!.minute}',
      'endTime': '${endTime!.hour}:${endTime!.minute}',
      'workingDays': selectedCodes,
    })
        .then((value) => emit(ProfileSuccessState()))
        .catchError((error) => emit(ProfileErrorState(error.toString())));
  }

  @override
  Future<void> close() {
    organizationTC.dispose();
    userNameTC.dispose();
    return super.close();
  }

  // Inside your ProfileCubit class
  Future<void> openTimePickerdialog({
    required bool isStart,
    required BuildContext context,
  }) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,

      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );

    if (selectedTime != null) {
      if (isStart) {
        startTime = selectedTime;
      } else {
        endTime = selectedTime;
      }

      emit(ProfileTimeChangedState());
    }
  }


}

class WorkingDaysModel {
  final String label;
  final String code;
  bool isSelected;
  WorkingDaysModel({required this.label, required this.code, required this.isSelected});
}
