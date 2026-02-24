import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../components/helper_functions.dart';


class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  // Class Properties
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  IconData suffix = Icons.visibility_off_outlined;
  bool isPassword = true;
  String selectedUserType = 'Employee';

  //userRegister and userCreate

  void signInWithGoogle() {
    emit(GoogleSignInLoadingState());
    _googleSignIn.initialize(
     serverClientId: '419097121301-q2ve2cvvs3tbgo7t4u1314i96rh3rc4n.apps.googleusercontent.com',
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
      print(error.toString());
      emit(CreateUserErrorState(error.toString()));
    });
  }
  void registerCompany({
    required String orgName,
    required String paidLeave,
    required String sickLeave,
    required String wfhDays,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String ownerId,
  }) {
    emit(RegisterLoadingState());

    CompanyModel model = CompanyModel(
      ownerId: ownerId,
      organizationName: orgName,
      paidLeavePerMonth: int.parse(paidLeave),
      sickLeavePerMonth: int.parse(sickLeave),
      wfhPerMonth: int.parse(wfhDays),
      startTime: formatTimeOfDay(startTime!),
      endTime: formatTimeOfDay(endTime!),
    );

    FirebaseFirestore.instance
        .collection('companies')
        .doc(ownerId) // Or use .add() for a random ID
        .set(model.toMap())
        .then((value) {
      emit(CreateCompanySuccessState());
    }).catchError((error) {
      emit(CreateCompanyErrorState(error.toString()));
    });
  }
}