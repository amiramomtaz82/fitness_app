import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../presentation_fixtures.dart';

void main() {
  const base = PopularTrainingGroupState(
    training: kTraining,
    relatedMuscles: ['Chest'],
    exercisesCount: 3,
    heroImageUrl: 'https://cdn.test/chest.png',
  );

  group('PopularTrainingGroupState', () {
    test('starts empty with an initial resource', () {
      const state = PopularTrainingGroupState();

      expect(state.training, isNull);
      expect(state.exercisesResource.status, ApiStatus.initial);
      expect(state.exercisesResource.data, isNull);
      expect(state.exercisesResource.failure, isNull);
      expect(state.relatedMuscles, isEmpty);
      expect(state.exercisesCount, 0);
      expect(state.heroImageUrl, isNull);
    });

    test('copyWith keeps the fields that are not given', () {
      final state = base.copyWith(exercisesResource: const Resource.loading());

      expect(state.training, kTraining);
      expect(state.relatedMuscles, ['Chest']);
      expect(state.exercisesCount, 3);
      expect(state.heroImageUrl, 'https://cdn.test/chest.png');
      expect(state.exercisesResource.status, ApiStatus.loading);
    });

    test('copyWith replaces the fields that are given', () {
      const items = Resource.success([kExerciseItem]);

      final state = base.copyWith(
        exercisesResource: items,
        relatedMuscles: const ['Back'],
        exercisesCount: 12,
        heroImageUrl: 'https://cdn.test/back.png',
      );

      expect(state.exercisesResource, items);
      expect(state.relatedMuscles, ['Back']);
      expect(state.exercisesCount, 12);
      expect(state.heroImageUrl, 'https://cdn.test/back.png');
    });

    test('states built with the same values are equal', () {
      final first = base.copyWith(relatedMuscles: const ['Back']);
      final second = base.copyWith(relatedMuscles: const ['Back']);

      expect(first, second);
    });

    test('states built with different values are not equal', () {
      expect(base.copyWith(exercisesCount: 4), isNot(base));
    });
  });
}
