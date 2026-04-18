import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/cubit/states.dart';

class KioskCubit extends Cubit<KioskStates> {
  KioskCubit() : super(KioskInitialState());

  static KioskCubit get(context) => BlocProvider.of(context);

  String? kioskEmail;
  String? kioskUid;
  bool kioskExists = false;

  /// Checks if a kiosk account already exists for the given company.
  void checkKioskExists(String companyId) {
    if (companyId.isEmpty) {
      emit(KioskFetchErrorState('No company ID provided.'));
      return;
    }

    emit(KioskFetchLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        .where('userType', isEqualTo: 'KIOSK')
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        kioskEmail = data['email'];
        kioskUid = snapshot.docs.first.id;
        kioskExists = true;
        emit(KioskFetchedState());
      } else {
        kioskEmail = null;
        kioskUid = null;
        kioskExists = false;
        emit(KioskNotFoundState());
      }
    }).catchError((error) {
      emit(KioskFetchErrorState(error.toString()));
    });
  }

  /// Creates a kiosk account using a SECONDARY FirebaseApp instance
  /// to prevent logging out the currently signed-in admin.
  Future<void> createKioskAccount({
    required String email,
    required String password,
    required String companyId,
  }) async {
    emit(KioskLoadingState());

    FirebaseApp? secondaryApp;
    try {
      // 1. Create a secondary FirebaseApp instance
      secondaryApp = await Firebase.initializeApp(
        name: 'KioskCreation_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      // 2. Create the kiosk user on the secondary auth instance
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final kioskUserId = credential.user!.uid;

      // 3. Sign out from the secondary instance immediately
      await secondaryAuth.signOut();

      // 4. Save kiosk user document in Firestore
      final kioskUser = UserModel(
        firstName: 'Kiosk',
        lastName: 'Device',
        email: email,
        uId: kioskUserId,
        companyId: companyId,
        userType: 'KIOSK',
        isEmailVerified: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(kioskUserId)
          .set(kioskUser.toMap());

      // 5. Update local state
      kioskEmail = email;
      kioskUid = kioskUserId;
      kioskExists = true;

      emit(KioskCreateSuccessState());
    } catch (error) {
      emit(KioskCreateErrorState(error.toString()));
    } finally {
      // 6. Cleanup the secondary app
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
    }
  }

  /// Changes the kiosk account password using a SECONDARY FirebaseApp
  /// instance so the currently signed-in admin is NOT affected.
  Future<void> changeKioskPassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(KioskChangePasswordLoadingState());

    FirebaseApp? secondaryApp;
    try {
      // 1. Create a temporary secondary FirebaseApp
      secondaryApp = await Firebase.initializeApp(
        name: 'KioskPasswordUpdate_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // 2. Sign in as the kiosk user to validate current password
      await secondaryAuth.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );

      // 3. Update the password
      await secondaryAuth.currentUser!.updatePassword(newPassword);

      // 4. Sign out from the secondary instance
      await secondaryAuth.signOut();

      emit(KioskChangePasswordSuccessState());
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          'Incorrect current password',
        'weak-password' => 'Password must be at least 6 characters',
        'user-not-found' => 'Kiosk account not found',
        'too-many-requests' => 'Too many attempts. Try again later',
        'network-request-failed' => 'Check your internet connection',
        _ => 'Something went wrong. Please try again',
      };
      emit(KioskChangePasswordErrorState(msg));
    } catch (_) {
      emit(KioskChangePasswordErrorState('Check your internet connection'));
    } finally {
      // 5. Cleanup the secondary app
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
    }
  }
}
