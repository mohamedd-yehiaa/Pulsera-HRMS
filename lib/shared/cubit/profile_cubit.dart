import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
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

  Future<void> getProfileImage(BuildContext context) async {
    try {
      // 1. Pick the image
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 2. Safety check: Ensure the widget is still mounted before using context
        if (!context.mounted) return;

        // 3. Crop the image immediately after picking
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 512,
          maxHeight: 512,
          compressQuality: 90,
          compressFormat: ImageCompressFormat.jpg,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Edit Profile Picture',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              cropStyle: CropStyle.circle,
              lockAspectRatio: true,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
            IOSUiSettings(
              title: 'Edit Profile Picture',
              cropStyle: CropStyle.circle,
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              aspectRatioPresets: [CropAspectRatioPreset.square],
            ),
            WebUiSettings(context: context, initialAspectRatio: 1.0),

          ],
        );

        // 4. Update state if cropped successfully
        if (croppedFile != null) {
          profileImage = File(croppedFile.path);
          emit(ProfileImagePickedSuccessState());
        } else {
          print('Image cropping was canceled by the user.');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      emit(ProfileImagePickedErrorState('Error picking/cropping image: $e'));
    }
  }

  Future<void> uploadProfileImage({required String uId}) async {
    if (profileImage == null) return;

    emit(ProfileUpdateLoadingState());

    try {
      final fileName = Uri.file(profileImage!.path).pathSegments.last;
      final path = 'users/$uId/profile_pictures/$fileName';

      final ref = firebase_storage.FirebaseStorage.instance.ref().child(path);
      await ref.putFile(profileImage!);
      final String imageUrl = await ref.getDownloadURL();

      _updateUserImage(uId: uId, imageUrl: imageUrl);
    } on firebase_storage.FirebaseException catch (error) {
      emit(ProfileErrorState("Storage error: ${error.message}"));
    } catch (error) {
      emit(
        ProfileErrorState("An unexpected error occurred: ${error.toString()}"),
      );
    }
  }

  void _updateUserImage({required String uId, required String imageUrl}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({'image': imageUrl})
        .then((value) {
          profileImage = null; // Clear local file after successful upload
          if (user != null) {
            user!.image = imageUrl;
          }
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
        .update({'image': ''})
        .then((value) {
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
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

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
