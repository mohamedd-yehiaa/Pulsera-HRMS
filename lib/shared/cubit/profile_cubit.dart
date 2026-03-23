import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
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


  Future<void> updateProfile(var uId) async {
    emit(ProfileUpdateLoadingState());
    List<String> nameParts = userNameTC.text.trim().split(' ');
    String firstName = nameParts[0];
    String lastName;
    if (nameParts.length > 1) {
      lastName = nameParts.sublist(1).join(' ');
    } else {
      lastName = '';
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({
          'firstName': firstName,
          'lastName': lastName,
          'email': emailTC.text.trim(),
          'phone': phoneTC.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
          // 'startTime': '${startTime!.hour}:${startTime!.minute}',
          // 'endTime': '${endTime!.hour}:${endTime!.minute}',
          // 'workingDays': selectedCodes,
        })
        .then((value) => emit(ProfileUpdateSuccessState()))
        .catchError((error) => emit(ProfileErrorState(error.toString())));
  }

  Future<void> updateOrganization({
    required String companyId,
    required String orgName,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required List<String> workingDays,
  }) async {
    emit(UpdateCompanyLoadingState());

    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .update({
        'organizationName': orgName.trim(),
        'startTime': formatTimeOfDay(startTime!),
        'endTime': formatTimeOfDay(endTime!),
        'workingDays': workingDays,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      emit(UpdateCompanySuccessState());
    } catch (error) {
      emit(UpdateCompanyErrorState(error.toString()));
    }
  }

  @override
  Future<void> close() {
    organizationTC.dispose();
    userNameTC.dispose();
    emailTC.dispose();
    phoneTC.dispose();
    startTimeTC.dispose();
    endTimeTC.dispose();
    return super.close();
  }
}
