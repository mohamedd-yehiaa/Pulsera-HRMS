import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  File? profileImage;
  final ImagePicker _picker = ImagePicker();
  Future<void> getProfileImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        print("Image Path: ${pickedFile.path}");
        emit(ProfileImagePickedSuccessState());
      } else {
        print('No image selected.');
      }
    } catch (e) {
      // Catching platform exceptions (e.g., permission denied)
      emit(ProfileImagePickedErrorState('Error picking image: $e'));
    }
  }

  void uploadProfileImage({required String uId}) {
    if (profileImage == null) return;

    emit(ProfileUpdateLoadingState());

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(
          'users/$uId/profile_pictures/${Uri.file(profileImage!.path).pathSegments.last}',
        )
        .putFile(profileImage!)
        .then((value) {
          value.ref
              .getDownloadURL()
              .then((url) {
                // After getting the URL, update the user's image field in Firestore
                _updateUserImage(uId: uId, imageUrl: url);
              })
              .catchError((error) {
                emit(
                  ProfileErrorState(
                    "Failed to get download URL: ${error.toString()}",
                  ),
                );
              });
        })
        .catchError((error) {
          emit(
            ProfileErrorState("Failed to upload image: ${error.toString()}"),
          );
        });
  }

  // Private helper to update only the image field in Firestore
  void _updateUserImage({required String uId, required String imageUrl}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({'image': imageUrl})
        .then((value) {
          // Clear the local file after successful upload so the UI refreshes to the NetworkImage
          profileImage = null;
          emit(ProfileUpdateSuccessState());
        })
        .catchError((error) {
          emit(ProfileErrorState(error.toString()));
        });
  }

  Future<void> removeProfileImage({required String uId}) async {
    emit(ProfileUpdateLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({
          'image': '', // Set to empty string
        })
        .then((value) {
          // Update local model so UI refreshes
          user?.image = null;
          emit(ProfileUpdateSuccessState());
        })
        .catchError((error) {
          emit(ProfileErrorState(error.toString()));
        });
  }

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

  void resetProfileData() {
    userNameTC.clear();
    emailTC.clear();
    phoneTC.clear();
    organizationTC.clear();
    emit(ProfileInitialState());
  }
}
