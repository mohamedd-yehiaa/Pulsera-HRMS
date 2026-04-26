import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/components/helper_functions.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        emit(ProfileImagePickedSuccessState());
      } else {
        print('No image selected.');
      }
    } catch (e) {
      emit(ProfileImagePickedErrorState('Error picking image: $e'));
    }
  }

  void uploadProfileImage({required String uId}) async {
    if (profileImage == null) return;

    emit(ProfileUpdateLoadingState());

    try {
      final fileName = profileImage!.path.split('/').last;
      final path = 'users/$uId/profile_pictures/$fileName';

      // 1. Upload the file to the 'profiles' bucket
      await Supabase.instance.client.storage
          .from('profiles')
          .upload(
        path,
        profileImage!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 2. Get the public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(path);

      // 3. Update your user record in the database
      _updateUserImage(uId: uId, imageUrl: imageUrl);

    } on StorageException catch (error) {
      emit(ProfileErrorState("Storage error: ${error.message}"));
    } catch (error) {
      emit(ProfileErrorState("An unexpected error occurred: ${error.toString()}"));
    }
  }
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
