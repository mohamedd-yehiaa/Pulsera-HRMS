import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulsera/models/team_members_model.dart';
import 'package:pulsera/shared/cubit/states.dart';

class ApplyLeaveCubit extends Cubit<AuthStates> {
  ApplyLeaveCubit() : super(AuthInitialState());

  static ApplyLeaveCubit get(context) => BlocProvider.of(context);

  var leavereasonTC = TextEditingController();
  DateTime? leaveStartDate;
  DateTime? leaveEndDate;

  List<MembersData> adminMembers = [];
  MembersData? selectedAdmin;
  bool isTeamLoading = false;


  void fetchAllAdminMembers({required String? companyId, required String? uId}) {
    if (companyId == null || uId == null) return;

    isTeamLoading = true;
    emit(AuthLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        .where('userType', whereIn: ['Company Owner', 'Manager',])
        .get()
        .then((value) {
      adminMembers = [];
      for (var doc in value.docs) {
        var member = MembersData.fromJson(doc.data());
        if (member.uId != uId) {
          adminMembers.add(member);
        }
      }

      if (adminMembers.isNotEmpty) {
        selectedAdmin = adminMembers.first;
      }

      isTeamLoading = false;
      emit(AuthInitialState());
    }).catchError((error) {
      isTeamLoading = false;
      emit(AuthErrorState(error.toString()));
    });
  }

  void changeSelectedAdmin(MembersData? newValue) {
    selectedAdmin = newValue;
    emit(AuthChangePasswordVisibilityState());
  }

  void applyLeave({
    required String? uId,
    required String? companyId,
    required dynamic userModel,
  }) {
    if (selectedAdmin == null || leavereasonTC.text.trim().isEmpty || leaveStartDate == null || leaveEndDate == null) {
      return;
    }

    emit(AuthLoadingState());

    FirebaseFirestore.instance.collection('leaves').add({
      "userID": uId,
      "companyID": companyId,
      "approvalTo": selectedAdmin?.toJson(), // Correctly mapping to MembersData
      "leaveStatus": "PENDING",
      "fromdate": DateFormat("yyyy-MM-ddTHH:mm:ss").format(leaveStartDate!),
      "todate": DateFormat("yyyy-MM-ddTHH:mm:ss").format(leaveEndDate!),
      "applyDate": DateFormat("yyyy-MM-dd").format(DateTime.now()),
      "leaveReason": leavereasonTC.text,
      "user": {
        "uId": uId,
        "fullName": "${userModel.firstName} ${userModel.lastName}", // Mapping local names to fullName
      },
    }).then((value) {
      emit(AuthSuccessState());
    }).catchError((error) {
      emit(AuthErrorState(error.toString()));
    });
  }

  void setDate(BuildContext context, {required bool isStart}) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((value) {
      if (value != null) {
        if (isStart) {
          leaveStartDate = value;
        } else {
          leaveEndDate = value;
        }
        emit(AuthChangePasswordVisibilityState());
      }
    });
  }
}