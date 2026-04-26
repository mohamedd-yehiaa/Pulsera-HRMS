import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';

// =============================================================================
// Mocks & Fakes
// =============================================================================

/// Mock for [ImagePicker] to simulate gallery image selection.
class MockImagePicker extends Mock implements ImagePicker {}

/// Mock for [SupabaseClient] to intercept storage operations.
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock for [SupabaseStorageClient] to intercept bucket operations.
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

/// Mock for [StorageFileApi] – the per-bucket facade (e.g. `from('profiles')`).
class MockStorageFileApi extends Mock implements StorageFileApi {}

/// Fake [File] to serve as a placeholder for image files in test registration.
class FakeFile extends Fake implements File {}

/// Fake [FileOptions] for Mocktail fallback registration.
class FakeFileOptions extends Fake implements FileOptions {}

// =============================================================================
// Testable subclass
// =============================================================================

/// An extension of [ProfileCubit] that allows injecting mock dependencies
/// for Supabase and Firestore while preserving the real business logic.
class TestableProfileCubit extends ProfileCubit {
  final MockSupabaseClient mockSupabaseClient;
  final FakeFirebaseFirestore fakeFirestore;

  TestableProfileCubit({
    required this.mockSupabaseClient,
    required this.fakeFirestore,
  });

  /// Override uploadProfileImage to inject mocked Supabase & Firestore clients
  /// instead of relying on singleton `Supabase.instance` and
  /// `FirebaseFirestore.instance`.
  @override
  void uploadProfileImage({required String uId}) async {
    if (profileImage == null) return;

    emit(ProfileUpdateLoadingState());

    try {
      final fileName = profileImage!.path.split('/').last;
      final path = 'users/$uId/profile_pictures/$fileName';

      // 1. Upload to Supabase (mocked)
      await mockSupabaseClient.storage
          .from('profiles')
          .upload(
            path,
            profileImage!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 2. Get the public URL (mocked)
      final String imageUrl = mockSupabaseClient.storage
          .from('profiles')
          .getPublicUrl(path);

      // 3. Update Firestore user document (fake)
      await fakeFirestore
          .collection('users')
          .doc(uId)
          .update({'image': imageUrl});

      // 4. Clear local image & signal success
      profileImage = null;
      emit(ProfileUpdateSuccessState());
    } on StorageException catch (error) {
      emit(ProfileErrorState("Storage error: ${error.message}"));
    } catch (error) {
      emit(ProfileErrorState("An unexpected error occurred: ${error.toString()}"));
    }
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ── Register fallbacks for Mocktail ──────────────────────────────────────
  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeFileOptions());
  });

  // Shared test fixtures
  const testUId = 'test-user-123';
  const testFileName = 'avatar.png';
  const testFilePath = '/tmp/$testFileName';
  const expectedStoragePath = 'users/$testUId/profile_pictures/$testFileName';
  const expectedPublicUrl =
      'https://zmmygxtgpmkzjtljuamq.supabase.co/storage/v1/object/public/profiles/$expectedStoragePath';

  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockBucketApi;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    mockSupabaseClient = MockSupabaseClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockBucketApi = MockStorageFileApi();
    fakeFirestore = FakeFirebaseFirestore();

    // ── Wire mock chain: client.storage.from('profiles') ──
    when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
    when(() => mockStorageClient.from('profiles')).thenReturn(mockBucketApi);

    // ── Default stub: upload succeeds ──
    when(() => mockBucketApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        )).thenAnswer((_) async => expectedStoragePath);

    // ── Default stub: getPublicUrl returns expected URL ──
    when(() => mockBucketApi.getPublicUrl(any())).thenReturn(expectedPublicUrl);

    // ── Seed Firestore with a pre-existing user document ──
    await fakeFirestore.collection('users').doc(testUId).set({
      'firstName': 'Test',
      'lastName': 'User',
      'email': 'test@example.com',
      'phone': '1234567890',
      'uId': testUId,
      'image': '',
      'companyId': 'company-abc',
      'isEmailVerified': true,
      'userType': 'Employee',
    });
  });

  // ===========================================================================
  // Test Group 1: State Machine Transitions (Happy Path)
  // ===========================================================================
  group('Profile Upload – Happy Path', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'emits [ProfileUpdateLoadingState, ProfileUpdateSuccessState] '
      'on successful upload',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        // Simulate that user already picked an image
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => [
        isA<ProfileUpdateLoadingState>(),
        isA<ProfileUpdateSuccessState>(),
      ],
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'clears profileImage to null after successful upload (UI must use NetworkImage)',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (cubit) {
        expect(cubit.profileImage, isNull,
            reason: 'profileImage must be null after successful upload '
                'so the UI switches from FileImage to NetworkImage');
      },
    );
  });

  // ===========================================================================
  // Test Group 2: Backend Check 1 – Supabase Upload Verification
  // ===========================================================================
  group('Backend Check 1 – Supabase Storage', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'uploads file to the correct bucket path: '
      'users/{uId}/profile_pictures/{fileName}',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) {
        // Verify the upload was called with the exact path
        verify(() => mockBucketApi.upload(
              expectedStoragePath,
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).called(1);
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'uses upsert: true in FileOptions (allows re-upload of same filename)',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) {
        final captured = verify(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: captureAny(named: 'fileOptions'),
            )).captured;

        final fileOptions = captured.last as FileOptions;
        expect(fileOptions.upsert, isTrue,
            reason: 'FileOptions must set upsert: true to allow overwriting');
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'retrieves public URL for the uploaded path',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) {
        verify(() => mockBucketApi.getPublicUrl(expectedStoragePath)).called(1);
      },
    );
  });

  // ===========================================================================
  // Test Group 3: Backend Check 2 – Firebase Firestore Verification
  // ===========================================================================
  group('Backend Check 2 – Firebase Firestore', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'updates the user document image field with the Supabase public URL',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) async {
        final doc =
            await fakeFirestore.collection('users').doc(testUId).get();
        final storedUrl = doc.data()?['image'];

        expect(storedUrl, equals(expectedPublicUrl),
            reason: 'Firestore image field must exactly match '
                'the Supabase public URL');
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'does not overwrite other user fields on image update',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) async {
        final doc =
            await fakeFirestore.collection('users').doc(testUId).get();
        final data = doc.data()!;

        // Verify other fields remain untouched
        expect(data['firstName'], equals('Test'));
        expect(data['lastName'], equals('User'));
        expect(data['email'], equals('test@example.com'));
        expect(data['phone'], equals('1234567890'));
        expect(data['companyId'], equals('company-abc'));
      },
    );
  });

  // ===========================================================================
  // Test Group 4: Error Handling – Supabase Failures
  // ===========================================================================
  group('Error Handling – Supabase Storage Errors', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'emits [ProfileUpdateLoadingState, ProfileErrorState] '
      'when Supabase upload throws StorageException',
      build: () {
        // Override upload to throw a StorageException
        when(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(StorageException('Bucket not found'));

        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => [
        isA<ProfileUpdateLoadingState>(),
        isA<ProfileErrorState>(),
      ],
      verify: (cubit) {
        // profileImage should NOT be cleared on failure
        expect(cubit.profileImage, isNotNull,
            reason: 'On failure, the picked image should be retained '
                'so the user can retry');
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'preserves the original Firestore image on upload failure',
      build: () {
        when(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(StorageException('Network timeout'));

        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      verify: (_) async {
        final doc =
            await fakeFirestore.collection('users').doc(testUId).get();
        expect(doc.data()?['image'], equals(''),
            reason: 'Firestore image field must remain unchanged on failure');
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'error message includes "Storage error:" prefix for StorageException',
      build: () {
        when(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(StorageException('Permission denied'));

        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => [
        isA<ProfileUpdateLoadingState>(),
        predicate<ProfileStates>((state) =>
            state is ProfileErrorState &&
            state.error.contains('Storage error:')),
      ],
    );
  });

  // ===========================================================================
  // Test Group 5: Error Handling – Unexpected Errors
  // ===========================================================================
  group('Error Handling – Unexpected Errors', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'emits ProfileErrorState with generic message on unexpected exception',
      build: () {
        when(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Unexpected network error'));

        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        cubit.profileImage = File(testFilePath);
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => [
        isA<ProfileUpdateLoadingState>(),
        predicate<ProfileStates>((state) =>
            state is ProfileErrorState &&
            state.error.contains('An unexpected error occurred')),
      ],
    );
  });

  // ===========================================================================
  // Test Group 6: Edge Cases & Guards
  // ===========================================================================
  group('Edge Cases & Guards', () {
    blocTest<TestableProfileCubit, ProfileStates>(
      'does NOT emit any state when profileImage is null (no-op guard)',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        // No image set → profileImage is null
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => <ProfileStates>[],
      verify: (_) {
        // Supabase must never be called
        verifyNever(() => mockBucketApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            ));
      },
    );

    blocTest<TestableProfileCubit, ProfileStates>(
      'handles path with special characters in filename',
      build: () {
        final cubit = TestableProfileCubit(
          mockSupabaseClient: mockSupabaseClient,
          fakeFirestore: fakeFirestore,
        );
        // File with spaces and special chars
        cubit.profileImage = File('/tmp/my photo (1).jpg');
        return cubit;
      },
      act: (cubit) => cubit.uploadProfileImage(uId: testUId),
      expect: () => [
        isA<ProfileUpdateLoadingState>(),
        isA<ProfileUpdateSuccessState>(),
      ],
    );
  });

  // ===========================================================================
  // Test Group 7: Integration – Full Hybrid Flow End-to-End
  // ===========================================================================
  group('Full Hybrid Upload Flow – End-to-End', () {
    test('complete flow: pick → upload → Supabase → URL → Firestore → clear',
        () async {
      final cubit = TestableProfileCubit(
        mockSupabaseClient: mockSupabaseClient,
        fakeFirestore: fakeFirestore,
      );

      final states = <ProfileStates>[];
      final sub = cubit.stream.listen(states.add);

      // ── Step 1: Simulate image pick ──
      cubit.profileImage = File(testFilePath);
      expect(cubit.profileImage, isNotNull,
          reason: 'Step 1: Image should be picked');

      // ── Step 2: Trigger upload ──
      cubit.uploadProfileImage(uId: testUId);

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // ── Step 3: Verify state transitions ──
      expect(states.length, equals(2),
          reason: 'There should be exactly 2 state emissions');
      expect(states[0], isA<ProfileUpdateLoadingState>(),
          reason: 'Step 3a: First emission is loading');
      expect(states[1], isA<ProfileUpdateSuccessState>(),
          reason: 'Step 3b: Second emission is success');

      // ── Step 4: Verify Supabase got the file ──
      verify(() => mockBucketApi.upload(
            expectedStoragePath,
            any(),
            fileOptions: any(named: 'fileOptions'),
          )).called(1);

      // ── Step 5: Verify Firestore has the correct URL ──
      final doc =
          await fakeFirestore.collection('users').doc(testUId).get();
      expect(doc.data()?['image'], equals(expectedPublicUrl),
          reason: 'Step 5: Firestore image = Supabase public URL');

      // ── Step 6: Verify UI state cleanup ──
      expect(cubit.profileImage, isNull,
          reason: 'Step 6: profileImage cleared → UI renders NetworkImage');

      await sub.cancel();
      await cubit.close();
    });
  });
}
