import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/models/leave_activity_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveCubit extends Cubit<LeaveStates> {
  LeaveCubit() : super(LeaveInitialState());

  static LeaveCubit get(context) => BlocProvider.of(context);

  // Variables and Controllers
  List<LeaveActivityModel> mainList = [];
  List<LeaveActivityModel> filteredLeaves = [];
  var leaveReasonTC = TextEditingController();

  bool myData = false;
  String selectedTab = 'pending';

  // 1. Get All Leaves for the Company
  void getAllLeaves({required String? uId, required String? companyId}) {
    if (uId == null || companyId == null) return;

    emit(GetLeavesLoadingState());

    FirebaseFirestore.instance
        .collection('leaves')
        .where('companyID', isEqualTo: companyId)
        .get()
        .then((value) {
      mainList = [];
      for (var doc in value.docs) {
        // Map Firestore data to your model
        var model = LeaveActivityModel.fromJson(doc.data());
        model.id = doc.id; // Ensure ID is captured for updates
        mainList.add(model);
      }

      filterAndEmit(uId);
      emit(GetLeavesSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetLeavesErrorState(error.toString()));
    });
  }

  // 2. Filter logic for My/Other and Tabs
  void filterAndEmit(String uId) {
    // Filter by Role (My Leaves vs Others)
    List<LeaveActivityModel> roleFiltered = mainList.where((element) {
      if (myData) {
        return element.userID == uId;
      } else {
        // Show leaves where I am the approver
        return element.approvalTo?.uId == uId;
      }
    }).toList();

    // Filter by Tab (Pending/Approved/Rejected)
    filteredLeaves = roleFiltered.where((element) {
      return element.leaveStatus?.code.toLowerCase() == selectedTab.toLowerCase();
    }).toList();
  }

  // 3. Tab Switching
  void emitTabChange(String status, String uId) {
    selectedTab = status;
    filterAndEmit(uId);
    emit(GetLeavesTabChangedState()); // Create this simple state in states.dart
  }

  // 4. Toggle My/Other Leaves
  void changeMyData(bool value, String uId) {
    myData = value;
    filterAndEmit(uId);
    emit(ChangeMyDataState());
  }

  // 5. Approve or Reject Leave
  void updateLeaveStatus({
    required String leaveId,
    required LeaveActivityState status,
    String? rejectReason,
    required String uId,
    required String companyId,
  }) {
    emit(UpdateLeaveLoadingState());

    FirebaseFirestore.instance
        .collection('leaves')
        .doc(leaveId)
        .update({
      'leaveStatus': status.code,
      'rejectedReason': rejectReason,
    }).then((value) {
      emit(UpdateLeaveSuccessState());
      // Refresh data to show changes
      getAllLeaves(uId: uId, companyId: companyId);
    }).catchError((error) {
      print(error.toString());
      emit(UpdateLeaveErrorState(error.toString()));
    });
  }
  void generateMockLeave(String uId, String companyId) {
    emit(UpdateLeaveLoadingState());

    // Creating a dummy model based on your LeaveActivityModel
    FirebaseFirestore.instance.collection('leaves').add({
      'userID': uId,
      'companyID': companyId,
      'leaveReason': 'Annual Family Vacation',
      'leaveStatus': 'PENDING',
      'fromdate': '2026-03-10T09:00:00',
      'todate': '2026-03-15T17:00:00',
      'applyDate': '2026-03-02',
      'approvalTo': {
        'uId': uId, // Sending to yourself for testing
        'firstName': 'Manager',
        'lastName': 'User',
      },
      'user': {
        'uId': uId,
        'firstName': 'Test',
        'lastName': 'Employee',
      }
    }).then((value) {
      Fluttertoast.showToast(msg: "Mock Leave Created");
      getAllLeaves(uId: uId, companyId: companyId);
    }).catchError((error) {
      emit(UpdateLeaveErrorState(error.toString()));
    });
  }
}
