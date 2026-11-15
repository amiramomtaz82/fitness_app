import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseEntity.videoUrl', () {
    test('prefers the demonstration video', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        demonstrationVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
        explanationVideoUrl: 'https://youtu.be/aaaaaaaaaaa',
      );

      expect(exercise.videoUrl, 'https://youtu.be/dQw4w9WgXcQ');
    });

    test('falls back to the explanation video', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        explanationVideoUrl: 'https://youtu.be/aaaaaaaaaaa',
      );

      expect(exercise.videoUrl, 'https://youtu.be/aaaaaaaaaaa');
    });

    test('stays empty when the exercise has no video', () {
      const exercise = ExerciseEntity(id: 'e_1', name: 'Bench Press');

      expect(exercise.videoUrl, isNull);
    });
  });

  group('ExerciseEntity.muscleNames', () {
    test('keeps the muscles in the order they are declared', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        secondaryMuscle: 'Triceps Brachii',
        tertiaryMuscle: 'Anterior Deltoid',
      );

      expect(exercise.muscleNames, const [
        'Chest',
        'Pectoralis Major',
        'Triceps Brachii',
        'Anterior Deltoid',
      ]);
    });

    test('drops the muscles the exercise does not declare', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        targetMuscleGroup: 'Chest',
        tertiaryMuscle: 'Anterior Deltoid',
      );

      expect(exercise.muscleNames, const ['Chest', 'Anterior Deltoid']);
    });

    test('drops the muscles named with nothing', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        targetMuscleGroup: 'Chest',
        secondaryMuscle: '',
      );

      expect(exercise.muscleNames, const ['Chest']);
    });

    test('lists a muscle shared by several slots only once', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Chest',
      );

      expect(exercise.muscleNames, const ['Chest']);
    });

    test('is empty when no muscle is declared', () {
      const exercise = ExerciseEntity(id: 'e_1', name: 'Bench Press');

      expect(exercise.muscleNames, isEmpty);
    });
  });

  group('ExerciseEntity classification slots', () {
    test('keeps the three movement pattern slots', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        movementPattern1: 'Push',
        movementPattern3: 'Horizontal',
      );

      expect(exercise.movementPatterns, const ['Push', null, 'Horizontal']);
    });

    test('keeps the three plane of motion slots', () {
      const exercise = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        planeOfMotion2: 'Transverse',
      );

      expect(exercise.planesOfMotion, const [null, 'Transverse', null]);
    });
  });

  group('ExerciseEntity equality', () {
    test('treats exercises with the same values as the same', () {
      const first = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        difficultyLevel: 'Beginner',
        primaryEquipment: 'Barbell',
      );
      const second = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        difficultyLevel: 'Beginner',
        primaryEquipment: 'Barbell',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('separates exercises that differ only in a detail field', () {
      const first = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        grip: 'Pronated',
      );
      const second = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        grip: 'Neutral',
      );

      expect(first, isNot(second));
    });

    test('separates exercises that differ only in a video field', () {
      const first = ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        explanationVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );
      const second = ExerciseEntity(id: 'e_1', name: 'Bench Press');

      expect(first, isNot(second));
    });
  });
}
