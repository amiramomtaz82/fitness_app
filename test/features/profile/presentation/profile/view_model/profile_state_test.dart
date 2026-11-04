import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_state.dart';

import '../../../profile_test_helper.dart';

void main() {
  const initial = ProfileState();

  group('ProfileState', () {
    test('starts without data and with an idle resource', () {
      expect(initial.profile, isNull);
      expect(initial.hasProfile, isFalse);
      expect(initial.isProfileLoading, isFalse);
      expect(initial.isUploadingPhoto, isFalse);
      expect(initial.pendingPhotoPath, isNull);
      expect(initial.profileResource, const Resource<ProfileEntity>.initial());
    });

    test('exposes the cached profile', () {
      final state = initial.copyWith(
        profileResource: const Resource<ProfileEntity>.success(
          testProfileEntity,
        ),
      );

      expect(state.profile, testProfileEntity);
      expect(state.hasProfile, isTrue);
    });

    test('keeps showing the profile while it is being re-read', () {
      final state = initial.copyWith(
        profileResource: const Resource<ProfileEntity>.loading(
          data: testProfileEntity,
        ),
      );

      expect(state.isProfileLoading, isTrue);
      expect(state.profile, testProfileEntity);
    });

    test('keeps showing the profile when the refresh failed', () {
      final state = initial.copyWith(
        profileResource: const Resource<ProfileEntity>.error(
          NetworkFailure(),
          data: testProfileEntity,
        ),
      );

      expect(state.profile, testProfileEntity);
    });

    test('a picked photo marks the state as uploading', () {
      final uploading = initial.withUpload('/tmp/a.jpg');

      expect(uploading.isUploadingPhoto, isTrue);
      expect(uploading.pendingPhotoPath, '/tmp/a.jpg');
    });

    test('withUpload keeps the profile and drops the photo once finished', () {
      final loaded = initial.copyWith(
        profileResource: const Resource<ProfileEntity>.success(
          testProfileEntity,
        ),
      );

      final finished = loaded.withUpload(null);

      expect(finished.isUploadingPhoto, isFalse);
      expect(finished.profile, testProfileEntity);
    });

    test('copyWith leaves the pending photo in place', () {
      final uploading = initial.withUpload('/tmp/a.jpg');

      final updated = uploading.copyWith(
        profileResource: const Resource<ProfileEntity>.success(
          testProfileEntity,
        ),
      );

      expect(updated.isUploadingPhoto, isTrue);
      expect(updated.profile, testProfileEntity);
    });

    test('withLanguage keeps the profile and the pending photo', () {
      final uploading = initial.withUpload('/tmp/a.jpg');

      final arabic = uploading.withLanguage(AppLanguage.arabic);

      expect(arabic.language, AppLanguage.arabic);
      expect(arabic.profile, uploading.profile);
      expect(arabic.pendingPhotoPath, '/tmp/a.jpg');
    });

    test('other updates leave the language in place', () {
      final arabic = initial.withLanguage(AppLanguage.arabic);

      final loaded = arabic.copyWith(
        profileResource: const Resource<ProfileEntity>.success(
          testProfileEntity,
        ),
      );

      expect(loaded.language, AppLanguage.arabic);
    });

    test('the language switch reads on only while english is active', () {
      expect(initial.isLanguageSwitchOn, isTrue);
      expect(
        initial.withLanguage(AppLanguage.arabic).isLanguageSwitchOn,
        isFalse,
      );
    });

    test('is value equal to an identical state', () {
      const a = ProfileState();
      const b = ProfileState();

      expect(a, b);
      expect(a, isNot(a.withLanguage(AppLanguage.arabic)));
      expect(a.props, [a.profileResource, a.pendingPhotoPath, a.language]);
    });
  });
}
