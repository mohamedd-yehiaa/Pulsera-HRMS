import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../../models/working_days_model.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());
  UserModel? user ;
  CompanyModel? company ;

  static ProfileCubit get(context) => BlocProvider.of(context);


  final organizationTC = TextEditingController();
  final userNameTC = TextEditingController();
  final emailTC = TextEditingController();
  final phoneTC = TextEditingController();

  List<WorkingDaysModel> workingDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void initProfileData(user) {
    emit(ProfileLoadingState());
    workingDays = [
      "Friday", "Saturday", "Sunday","Monday", "Tuesday", "Wednesday", "Thursday",
    ].map((e) => WorkingDaysModel(
      label: e,
      code: e.toUpperCase(),
      isSelected: false,
    )).toList();

    startTime =  TimeOfDay(hour: 9, minute: 0);
    endTime =  TimeOfDay(hour: 17, minute: 0);

    emit(ProfileSuccessState());
  }

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

    emit(ProfileUpdateLoadingState());
    // List<String> selectedCodes = workingDays
    //     .where((e) => e.isSelected)
    //     .map((e) => e.code)
    //     .toList();
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({
      'firstName': userNameTC.text.split(' ')[0],
      'lastName': userNameTC.text.split(' ')[1],
      'email': emailTC.text,
      'phone': phoneTC.text,
      // 'startTime': '${startTime!.hour}:${startTime!.minute}',
      // 'endTime': '${endTime!.hour}:${endTime!.minute}',
      // 'workingDays': selectedCodes,
    })
        .then((value) => emit(ProfileUpdateSuccessState()))
    .catchError((error) => emit(ProfileErrorState(error.toString())));
  }

  @override
  Future<void> close() {
    organizationTC.dispose();
    userNameTC.dispose();
    return super.close();
  }


  Future<void> openTimePicker({
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

