import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/models/working_days_model.dart';
import 'package:pulsera/shared/components/api_keys.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';


class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  // Class Properties
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  IconData suffix = Icons.visibility_off_outlined;
  bool isPassword = true;
  String selectedUserType = "Employee";
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final startTimeTC = TextEditingController();
  final endTimeTC = TextEditingController();

  //userRegister and userCreate
  void signInWithGoogle() {
    emit(GoogleSignInLoadingState());
    _googleSignIn.initialize(
     serverClientId: serverClientId,
    ).then((_) {

      _googleSignIn.authenticate().then((googleAccount) {

        final googleAuth = googleAccount.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: null,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the credential
        _auth.signInWithCredential(credential).then((userCredential) {
          emit(GoogleSignInSuccessState());
          if (userCredential.user != null) {
            createUserInFirestore(userCredential.user!);
          }
        }).catchError((error) {
          emit(GoogleSignInErrorState(error.toString()));
        });

      }).catchError((error) {
        emit(GoogleSignInErrorState(error.toString()));
      });

    }).catchError((error) {
      emit(GoogleSignInErrorState("Initialization failed: ${error.toString()}"));
    });
  }

  void createUserInFirestore(User user) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    UserModel googleModel = UserModel(
      uId: user.uid,
      firstName: user.displayName?.split(' ').first ?? '',
      lastName: user.displayName?.split(' ').last ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      userType: selectedUserType,
      isEmailVerified: true,
    );

    userDoc.get().then((doc) {
      if (!doc.exists) {
        userDoc.set(googleModel.toMap())
            .then((value) {
          emit(CreateUserSuccessState());
        }).catchError((error) {
          emit(CreateUserErrorState(error.toString()));
        });
      } else {
        emit(CreateUserSuccessState());
      }
    }).catchError((error) {
      emit(CreateUserErrorState(error.toString()));
    });
  }
// ================================================================================
  // UI Support Methods
  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(RegisterChangePasswordVisibilityState());
  }

  void changeUserType(String value) {
    selectedUserType = value;
    emit(RegisterChangeUserTypeState());
  }

  // Register via Email and Password
  void userRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) {
    emit(RegisterLoadingState());

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      userCreate(
        uId: value.user!.uid,
        phone: phone,
        email: email,
        firstName: firstName,
        lastName: lastName,
        userType: selectedUserType,
      );
    }).catchError((error) {
      emit(RegisterErrorState(error.toString()));
    });
  }

  void userCreate({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String uId,
    required String userType,
  }) {
    UserModel model = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
      userType: selectedUserType,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(CreateUserSuccessState());
    })
        .catchError((error) {
      emit(CreateUserErrorState(error.toString()));
    });
  }

  final workingDaysMapping = <String, int>{
    "FRIDAY": 1,
    "SATURDAY": 2,
    "SUNDAY": 3,
    "MONDAY": 4,
    "TUESDAY": 5,
    "WEDNESDAY": 6,
    "THURSDAY": 7,
  };

  List<WorkingDaysModel> workingDaysList =
  [
    "Friday",
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
  ]
      .map(
        (day) => WorkingDaysModel(
      label: day,
      code: day.toUpperCase(),
      isSelected: false,
    ),
  )
      .toList();

  // 1. Get the uppercase codes of selected days
  late List<String> selectedDayCodes = workingDaysList
      .where((day) => day.isSelected)
      .map((day) => day.code)
      .toList();
  // 2. Map those codes to their integer values using your mapping
  late List<int> selectedDayValues = selectedDayCodes
      .map((code) => workingDaysMapping[code]!)
      .toList();

  void onWorkingDaysChange(int index) {
    workingDaysList[index].isSelected = !workingDaysList[index].isSelected;
    emit(CreateCompanyChangeWorkingDaysState());
  }


  void registerCompany({
    required String orgName,
    required String paidLeave,
    required String sickLeave,
    required String wfhDays,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String ownerId,
    required List<WorkingDaysModel> workingDaysList,
    int gracePeriodMinutes = 15,
    int earlyAllowanceMinutes = 30,
    int lateCutoffMinutes = 120,
    int minimumWorkHours = 6,
  }) {

    // Convert the List of Objects into a List of Strings
    List<String> selectedDayValues = workingDaysList
        .where((day) => day.isSelected)
        .map((day) => day.code)
        .toList();

    if (selectedDayValues.isEmpty) {
      emit(CreateCompanyErrorState("Please select at least one working day."));
      return;
    }
    emit(CreateCompanyLoadingState());

    var companyDocRef = FirebaseFirestore.instance.collection('companies').doc();
    CompanyModel comModel = CompanyModel(
      companyId: companyDocRef.id,
      ownerId: ownerId,
      organizationName: orgName,
      paidLeavePerMonth: int.parse(paidLeave),
      sickLeavePerMonth: int.parse(sickLeave),
      wfhPerMonth: int.parse(wfhDays),
      startTime: formatTimeOfDay(startTime!),
      endTime: formatTimeOfDay(endTime!),
      workingDays: selectedDayValues,
      gracePeriodMinutes: gracePeriodMinutes,
      earlyAllowanceMinutes: earlyAllowanceMinutes,
      lateCutoffMinutes: lateCutoffMinutes,
      minimumWorkHours: minimumWorkHours,

    );

    companyDocRef
        .set(comModel.toMap())
        .then((value) {
      // Wait for the user doc update before emitting success
      // to avoid a race condition where getUserData() fetches stale data.
      return FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .update({'companyId': companyDocRef.id});
    }).then((_) async {
      await CacheHelper.saveData(key: 'companyId', value: companyDocRef.id);
      emit(CreateCompanySuccessState(companyDocRef.id));
    }).catchError((error) {
      emit(CreateCompanyErrorState(error.toString()));
    });
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
        startTimeTC.text = formatTimeOfDay(selectedTime).toString();
      } else {
        endTime = selectedTime;
        endTimeTC.text = formatTimeOfDay(selectedTime).toString();
      }
      emit(CreateCompanyTimeChangedState());
    }
  }
  void resetRegistrationData() {
    startTimeTC.clear();
    endTimeTC.clear();

    // Clear the actual TimeOfDay variables
    startTime = null;
    endTime = null;

    // Reset all working days to false
    for (var day in workingDaysList) {
      day.isSelected = false;
    }

    emit(RegisterInitialState());
  }
}