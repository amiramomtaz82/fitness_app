import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_intent.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_state.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../profile_test_helper.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockUploadPhotoUseCase mockUploadPhoto;
  late MockPickPhotoUseCase mockPickPhoto;
  late MockEditProfileUseCase mockEditProfile;
  late ProfileCubit profileCubit;
  late EditProfileCubit cubit;

  setUpAll(registerProfileFallbacks);

  setUp(() async {
    mockGetProfile = MockGetProfileUseCase();
    mockUploadPhoto = MockUploadPhotoUseCase();
    mockPickPhoto = MockPickPhotoUseCase();
    mockEditProfile = MockEditProfileUseCase();
    profileCubit = buildProfileCubit(
      mockGetProfile,
      mockUploadPhoto,
      mockPickPhoto,
      await localePreferencesWith(),
    );
    cubit = EditProfileCubit(profileCubit, mockEditProfile);
  });

  tearDown(() async {
    await cubit.close();
    await profileCubit.close();
  });

  void stubSavedProfile(ProfileEntity? profile) {
    when(() => mockGetProfile.call()).thenAnswer(
      (_) async => profile == null
          ? ErrorResponse<ProfileEntity>(failure: const NetworkFailure())
          : SuccessResponse<ProfileEntity>(profile),
    );
  }

  Future<void> startForm({ProfileEntity profile = testProfileEntity}) async {
    stubSavedProfile(profile);
    cubit.doIntent(const StartEditProfileIntent());
    await Future<void>.delayed(Duration.zero);
  }

  void stubSaveSuccess([ProfileEntity profile = testProfileEntityEdited]) {
    when(
      () => mockEditProfile.call(any()),
    ).thenAnswer((_) async => SuccessResponse<ProfileEntity>(profile));
  }

  group('EditProfileCubit prefill', () {
    test('loads the saved profile into a draft', () async {
      await startForm();

      expect(cubit.state.saved, testProfileEntity);
      expect(cubit.state.draft, testProfileParams);
      expect(cubit.state.isDraftReady, isTrue);
      expect(cubit.state.draft?.age, 25);
      expect(cubit.state.draft?.weight, 75.5);
      expect(cubit.state.draft?.height, 178);
      expect(cubit.state.fieldErrors, isEmpty);
    });

    test('keeps the locked fields out of an unloaded form', () async {
      stubSavedProfile(null);

      cubit.doIntent(const StartEditProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.saved, isNull);
      expect(cubit.state.firstName, isEmpty);
      expect(cubit.state.lastName, isEmpty);
      expect(cubit.state.email, isEmpty);
    });

    test('copies measurements the server never sent as zeroes', () async {
      await startForm(profile: const ProfileEntity());

      expect(cubit.state.draft?.age, 0);
      expect(cubit.state.draft?.weight, 0);
      expect(cubit.state.draft?.height, 0);
    });

    test('reads the profile once and reuses the shared cache', () async {
      await startForm();

      expect(profileCubit.profile, testProfileEntity);
      verify(() => mockGetProfile.call()).called(1);
    });

    test('leaves the form unusable when the profile cannot be read', () async {
      stubSavedProfile(null);

      cubit.doIntent(const StartEditProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isDraftReady, isFalse);
      expect(cubit.state.draft, isNull);
    });
  });

  group('draft editing', () {
    setUp(() => startForm());

    test('an option pick updates the draft and leaves the rest untouched', () {
      cubit.doIntent(
        const SelectOptionIntent(EditProfileField.goal, 'Lose weight'),
      );

      expect(cubit.state.draft?.goal, 'Lose weight');
      expect(cubit.state.draft?.firstName, 'Ahmed');
      expect(cubit.state.draft?.lastName, 'Sukkary');
    });

    test('the draft always carries the names from the saved profile', () {
      cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 31));

      expect(cubit.state.draft?.firstName, 'Ahmed');
      expect(cubit.state.draft?.lastName, 'Sukkary');
    });

    test('option intents ignore numeric fields', () {
      cubit.doIntent(const SelectOptionIntent(EditProfileField.weight, '90'));

      expect(cubit.state.draft?.weight, 75.5);
    });

    test('numeric intents ignore option fields', () {
      cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.goal, 10));

      expect(cubit.state.draft?.goal, 'Gain weight');
    });

    test('picked numbers update the draft they belong to', () {
      cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 30));
      cubit.doIntent(
        const UpdateNumberFieldIntent(EditProfileField.weight, 80.0),
      );
      cubit.doIntent(
        const UpdateNumberFieldIntent(EditProfileField.height, 178.5),
      );

      expect(cubit.state.draft?.age, 30);
      expect(cubit.state.draft?.weight, 80);
      expect(cubit.state.draft?.height, 178.5);
    });

    test('an option pick stores the backend value, not the label', () {
      cubit.doIntent(
        const SelectOptionIntent(EditProfileField.activityLevel, 'level3'),
      );

      expect(cubit.state.draft?.activityLevel, 'level3');
    });
  });

  group('saving', () {
    test(
      'sends the draft, publishes it to the shared profile and pops',
      () async {
        await startForm();
        cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 30));
        stubSaveSuccess();
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(const SaveProfileIntent());
        await Future<void>.delayed(Duration.zero);

        final saved =
            verify(() => mockEditProfile.call(captureAny())).captured.single
                as ProfileParams;
        expect(saved.firstName, 'Ahmed');
        expect(saved.lastName, 'Sukkary');
        expect(saved.age, 30);
        expect(cubit.state.saveResource.isSuccess, isTrue);
        expect(cubit.state.saved, testProfileEntityEdited);
        expect(cubit.state.firstName, 'Mohamed');
        expect(profileCubit.profile, testProfileEntityEdited);
        expect(events, contains(isA<PopEvent>()));
        expect(
          events,
          contains(
            isA<ShowSuccessSnackBarEvent>().having(
              (event) => event.type,
              'type',
              CubitMessageType.profileUpdated,
            ),
          ),
        );
      },
    );

    test('blocks an empty profile and reports every editable field', () async {
      await startForm(profile: const ProfileEntity());

      cubit.doIntent(const SaveProfileIntent());

      expect(
        cubit.state.fieldErrors.keys,
        unorderedEquals(EditProfileField.values),
      );
      expect(
        cubit.state.fieldErrors[EditProfileField.gender],
        ValidationError.empty,
      );
      expect(
        cubit.state.fieldErrors[EditProfileField.age],
        ValidationError.valueBelowMinimum,
      );
      expect(cubit.state.saveResource, const Resource<ProfileEntity>.initial());
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('rejects out-of-range numbers before hitting the API', () async {
      await startForm();

      cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 5));
      cubit.doIntent(
        const UpdateNumberFieldIntent(EditProfileField.height, 400),
      );
      cubit.doIntent(const SaveProfileIntent());

      expect(
        cubit.state.fieldErrors[EditProfileField.age],
        ValidationError.valueBelowMinimum,
      );
      expect(
        cubit.state.fieldErrors[EditProfileField.height],
        ValidationError.valueAboveMaximum,
      );
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('rejects a gender the backend does not accept', () async {
      await startForm();

      cubit.doIntent(const SelectOptionIntent(EditProfileField.gender, 'x'));
      cubit.doIntent(const SaveProfileIntent());

      expect(
        cubit.state.fieldErrors[EditProfileField.gender],
        ValidationError.invalidGender,
      );
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('emits a failure event when the server rejects the changes', () async {
      await startForm();
      when(() => mockEditProfile.call(any())).thenAnswer(
        (_) async =>
            ErrorResponse<ProfileEntity>(failure: const ServerFailure()),
      );
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const SaveProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.saveResource.isError, isTrue);
      expect(cubit.state.saved, testProfileEntity);
      expect(profileCubit.profile, testProfileEntity);
      expect(events.any((event) => event is PopEvent), isFalse);
      expect(
        events,
        contains(
          isA<ShowErrorSnackBarEvent>().having(
            (event) => event.failure,
            'failure',
            isA<ServerFailure>(),
          ),
        ),
      );
    });

    test('ignores a second save while one is running', () async {
      await startForm();
      final completer = Completer<BaseResponse<ProfileEntity>>();
      when(
        () => mockEditProfile.call(any()),
      ).thenAnswer((_) => completer.future);

      cubit.doIntent(const SaveProfileIntent());
      cubit.doIntent(const SaveProfileIntent());
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
      );
      await Future<void>.delayed(Duration.zero);

      verify(() => mockEditProfile.call(any())).called(1);
    });

    test('does nothing before the draft exists', () async {
      cubit.doIntent(const SaveProfileIntent());

      expect(cubit.state, const EditProfileState());
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('editing before the draft exists is ignored', () async {
      cubit.doIntent(const SelectOptionIntent(EditProfileField.goal, 'x'));
      cubit.doIntent(
        const UpdateNumberFieldIntent(EditProfileField.weight, 90),
      );

      expect(cubit.state, const EditProfileState());
    });
  });

  group('error clearing', () {
    test('fixing a field removes only that field error', () async {
      await startForm(profile: const ProfileEntity());
      cubit.doIntent(const SaveProfileIntent());
      expect(
        cubit.state.fieldErrors,
        hasLength(EditProfileField.values.length),
      );

      cubit.doIntent(const SelectOptionIntent(EditProfileField.gender, 'male'));

      expect(
        cubit.state.fieldErrors.containsKey(EditProfileField.gender),
        isFalse,
      );
      expect(cubit.state.fieldErrors.containsKey(EditProfileField.age), isTrue);
    });

    test(
      'a failed save followed by a valid save publishes the new profile',
      () async {
        await startForm();
        cubit.doIntent(
          const SelectOptionIntent(EditProfileField.gender, 'other'),
        );

        cubit.doIntent(const SaveProfileIntent());
        expect(
          cubit.state.fieldErrors[EditProfileField.gender],
          ValidationError.invalidGender,
        );

        cubit.doIntent(
          const SelectOptionIntent(EditProfileField.gender, 'female'),
        );
        stubSaveSuccess(
          const ProfileEntity(
            id: '123',
            firstName: 'Ahmed',
            lastName: 'Sukkary',
            email: 'ahmed@test.com',
            gender: 'female',
            age: 25,
            weight: 75.5,
            height: 178,
            activityLevel: 'level1',
            goal: 'Gain weight',
          ),
        );

        cubit.doIntent(const SaveProfileIntent());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.fieldErrors, isEmpty);
        expect(profileCubit.profile?.gender, 'female');
      },
    );
  });
}
