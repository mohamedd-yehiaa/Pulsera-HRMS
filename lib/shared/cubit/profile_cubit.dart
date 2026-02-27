import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/cubit/states.dart';


class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());
  UserModel? user;
  CompanyModel? company;

  static ProfileCubit get(context) => BlocProvider.of(context);


  final userNameTC = TextEditingController();
  final emailTC = TextEditingController();
  final phoneTC = TextEditingController();

  final organizationTC = TextEditingController();
  final startTimeTC = TextEditingController();
  final endTimeTC = TextEditingController();



  // Future<void> selectTime(BuildContext context, bool isStart) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: isStart
  //         ? (startTime ?? TimeOfDay.now())
  //         : (endTime ?? TimeOfDay.now()),
  //   );
  //
  //   if (picked != null) {
  //     if (isStart) {
  //       startTime = picked;
  //     } else {
  //       endTime = picked;
  //     }
  //     emit(ProfileTimeChangedState());
  //   }
  // }

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
}
