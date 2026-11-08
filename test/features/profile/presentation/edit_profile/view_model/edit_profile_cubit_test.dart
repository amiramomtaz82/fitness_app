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
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_saved_event.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../profile_test_helper.dart';

void main() {
  late MockEditProfileUseCase mockEditProfile;
  late EditProfileCubit cubit;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockEditProfile = MockEditProfileUseCase();
    cubit = EditProfileCubit(mockEditProfile);
  });

  tearDown(() => cubit.close());

  void startForm({ProfileEntity profile = testProfileEntity}) {
    cubit.doIntent(StartEditProfileIntent(profile));
  }

  void stubSaveSuccess([ProfileEntity profile = testProfileEntityEdited]) {
    when(
      () => mockEditProfile.call(any()),
    ).thenAnswer((_) async => SuccessResponse<ProfileEntity>(profile));
  }

  group('EditProfileCubit prefill', () {
    test('loads the handed profile into a draft', () {
      startForm();

      expect(cubit.state.saved, testProfileEntity);
      expect(cubit.state.draft, testProfileParams);
      expect(cubit.state.isDraftReady, isTrue);
      expect(cubit.state.draft?.age, 25);
      expect(cubit.state.draft?.weight, 75.5);
      expect(cubit.state.draft?.height, 178);
      expect(cubit.state.fieldErrors, isEmpty);
    });

    test('the locked fields read empty until a profile is handed in', () {
      expect(cubit.state.saved, isNull);
      expect(cubit.state.firstName, isEmpty);
      expect(cubit.state.lastName, isEmpty);
      expect(cubit.state.email, isEmpty);
      expect(cubit.state.gender, isEmpty);
    });

    test('the locked fields are served from the handed profile', () {
      startForm();

      expect(cubit.state.firstName, 'Ahmed');
      expect(cubit.state.lastName, 'Sukkary');
      expect(cubit.state.email, 'ahmed@test.com');
      expect(cubit.state.gender, 'male');
    });

    test('copies measurements the server never sent as zeroes', () {
      startForm(profile: const ProfileEntity());

      expect(cubit.state.draft?.age, 0);
      expect(cubit.state.draft?.weight, 0);
      expect(cubit.state.draft?.height, 0);
    });
  });

  group('draft editing', () {
    setUp(startForm);

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
    test('sends the draft, hands the result back and pops', () async {
      startForm();
      cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 30));
      stubSaveSuccess();
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const SaveProfileIntent());
      await Future<void>.delayed(Duration.zero);

      final saved =
          verify(() => mockEditProfile.call(captureAny())).captured.single
              as ProfileParams;
      expect(saved.firstName, 'Ahmed');
      expect(saved.age, 30);
      expect(cubit.state.saveResource.isSuccess, isTrue);
      expect(cubit.state.saved, testProfileEntityEdited);
      expect(cubit.state.firstName, 'Mohamed');
      expect(
        events,
        contains(
          isA<ProfileSavedEvent>().having(
            (event) => event.profile,
            'profile',
            testProfileEntityEdited,
          ),
        ),
      );
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
    });

    test('blocks an empty profile and reports every editable field', () {
      startForm(profile: const ProfileEntity());

      cubit.doIntent(const SaveProfileIntent());

      expect(
        cubit.state.fieldErrors.keys,
        unorderedEquals(EditProfileField.values),
      );
      expect(
        cubit.state.fieldErrors[EditProfileField.age],
        ValidationError.valueBelowMinimum,
      );
      expect(cubit.state.saveResource, const Resource<ProfileEntity>.initial());
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('rejects out-of-range numbers before hitting the API', () {
      startForm();

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

    test('emits a failure event when the server rejects the changes', () async {
      startForm();
      when(() => mockEditProfile.call(any())).thenAnswer(
        (_) async =>
            ErrorResponse<ProfileEntity>(failure: const ServerFailure()),
      );
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const SaveProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.saveResource.isError, isTrue);
      expect(cubit.state.saved, testProfileEntity);
      expect(events.any((event) => event is PopEvent), isFalse);
      expect(events.any((event) => event is ProfileSavedEvent), isFalse);
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
      startForm();
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

    test('does nothing before the draft exists', () {
      cubit.doIntent(const SaveProfileIntent());

      expect(cubit.state, const EditProfileState());
      verifyNever(() => mockEditProfile.call(any()));
    });

    test('editing before the draft exists is ignored', () {
      cubit.doIntent(const SelectOptionIntent(EditProfileField.goal, 'x'));
      cubit.doIntent(
        const UpdateNumberFieldIntent(EditProfileField.weight, 90),
      );

      expect(cubit.state, const EditProfileState());
    });
  });

  group('error clearing', () {
    test('fixing a field removes only that field error', () {
      startForm(profile: const ProfileEntity());
      cubit.doIntent(const SaveProfileIntent());
      expect(
        cubit.state.fieldErrors,
        hasLength(EditProfileField.values.length),
      );

      cubit.doIntent(
        const SelectOptionIntent(EditProfileField.goal, 'Lose weight'),
      );

      expect(
        cubit.state.fieldErrors.containsKey(EditProfileField.goal),
        isFalse,
      );
      expect(cubit.state.fieldErrors.containsKey(EditProfileField.age), isTrue);
    });

    test(
      'a rejected edit followed by a fixed edit publishes the profile',
      () async {
        startForm();
        cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 5));

        cubit.doIntent(const SaveProfileIntent());
        expect(
          cubit.state.fieldErrors[EditProfileField.age],
          ValidationError.valueBelowMinimum,
        );

        cubit.doIntent(const UpdateNumberFieldIntent(EditProfileField.age, 26));
        stubSaveSuccess(
          const ProfileEntity(
            id: '123',
            firstName: 'Ahmed',
            lastName: 'Sukkary',
            email: 'ahmed@test.com',
            gender: 'male',
            age: 26,
            weight: 75.5,
            height: 178,
            activityLevel: 'level1',
            goal: 'Gain weight',
          ),
        );

        cubit.doIntent(const SaveProfileIntent());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.fieldErrors, isEmpty);
        expect(cubit.state.saved?.age, 26);
      },
    );
  });
}
