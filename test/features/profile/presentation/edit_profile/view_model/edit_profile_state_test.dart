import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_state.dart';

import '../../../profile_test_helper.dart';

void main() {
  const initial = EditProfileState();

  group('EditProfileState', () {
    test('starts with no draft, no errors and an idle save', () {
      expect(initial.saved, isNull);
      expect(initial.draft, isNull);
      expect(initial.isDraftReady, isFalse);
      expect(initial.isSaving, isFalse);
      expect(initial.fieldErrors, isEmpty);
      expect(initial.saveResource, const Resource<ProfileEntity>.initial());
    });

    test('the locked fields read as empty until the profile is loaded', () {
      expect(initial.firstName, isEmpty);
      expect(initial.lastName, isEmpty);
      expect(initial.email, isEmpty);
    });

    test('the locked fields are served from the saved profile', () {
      final state = initial.copyWith(saved: testProfileEntity);

      expect(state.firstName, 'Ahmed');
      expect(state.lastName, 'Sukkary');
      expect(state.email, 'ahmed@test.com');
    });

    test('the draft is ready once the profile has been copied into it', () {
      final state = initial.copyWith(draft: testProfileParams);

      expect(state.isDraftReady, isTrue);
      expect(state.draft, testProfileParams);
    });

    test('reports no change before anything is loaded', () {
      expect(initial.hasChanges, isFalse);
    });

    test('reports no change while the draft mirrors the saved profile', () {
      final state = initial.copyWith(
        saved: testProfileEntity,
        draft: testProfileParams,
      );

      expect(state.hasChanges, isFalse);
    });

    test('reports a change once the draft differs from the saved profile', () {
      final state = initial.copyWith(
        saved: testProfileEntity,
        draft: testProfileParams.copyWith(age: 30),
      );

      expect(state.hasChanges, isTrue);
    });

    test('exposes the error of a single field', () {
      final state = initial.copyWith(
        fieldErrors: const {
          EditProfileField.gender: ValidationError.invalidGender,
        },
      );

      expect(
        state.errorOf(EditProfileField.gender),
        ValidationError.invalidGender,
      );
      expect(state.errorOf(EditProfileField.age), isNull);
    });

    test('knows when a save is in flight or failed', () {
      final saving = initial.copyWith(
        saveResource: const Resource<ProfileEntity>.loading(),
      );
      final failed = initial.copyWith(
        saveResource: const Resource<ProfileEntity>.error(NetworkFailure()),
      );

      expect(saving.isSaving, isTrue);
      expect(failed.saveResource.isError, isTrue);
    });

    test('copyWith keeps the saved payload while errors are replaced', () {
      final saved = initial.copyWith(
        saved: testProfileEntity,
        draft: testProfileParams,
        saveResource: const Resource<ProfileEntity>.success(testProfileEntity),
      );

      final rerouted = saved.copyWith(
        fieldErrors: const {
          EditProfileField.age: ValidationError.valueBelowMinimum,
        },
      );

      expect(rerouted.saved, testProfileEntity);
      expect(rerouted.draft, testProfileParams);
      expect(rerouted.saveResource.data, testProfileEntity);
      expect(
        rerouted.errorOf(EditProfileField.age),
        ValidationError.valueBelowMinimum,
      );
    });

    test('is value equal to an identical state', () {
      const a = EditProfileState();
      const b = EditProfileState();

      expect(a, b);
      expect(a.props, hasLength(4));
      expect(a.props.first, isNull);
      expect(a.props.last, a.saveResource);
    });

    test('a newer saved profile makes the state different', () {
      final before = initial.copyWith(saved: testProfileEntity);
      final after = initial.copyWith(saved: testProfileEntityEdited);

      expect(before, isNot(after));
      expect(after.firstName, 'Mohamed');
    });
  });
}
