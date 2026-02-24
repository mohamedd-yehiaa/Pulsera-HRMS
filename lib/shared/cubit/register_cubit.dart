import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import '../../models/user_model.dart';


class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  // Class Properties
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  IconData suffix = Icons.visibility_off_outlined;
  bool isPassword = true;
  String? selectedUserType;

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

    userDoc.get().then((doc) {
      if (!doc.exists) {
        userDoc.set({
          'uId': user.uid,
          'firstName': user.displayName?.split(' ').first ?? '',
          'lastName': user.displayName?.split(' ').last ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'uType': selectedUserType,
          'isEmailVerified': true,
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        }).then((value) {
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
  }) {
    UserModel model = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
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
}