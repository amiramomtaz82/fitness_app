import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:flutter_test/flutter_test.dart';

const _exercise = ExerciseEntity(
  id: 'exercise-1',
  name: 'Barbell Bench Press',
  difficultyLevel: 'Beginner',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Barbell',
  shortVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
  explanationVideoUrl: '',
);

void main() {
  group('ExerciseEntity —', () {
    test('two entities with the same fields are equal', () {
      const copy = ExerciseEntity(
        id: 'exercise-1',
        name: 'Barbell Bench Press',
        difficultyLevel: 'Beginner',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        primaryEquipment: 'Barbell',
        shortVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
        explanationVideoUrl: '',
      );

      expect(copy, _exercise);
      expect(copy.hashCode, _exercise.hashCode);
    });

    test('optional fields take part in equality', () {
      const withDetails = ExerciseEntity(
        id: 'exercise-1',
        name: 'Barbell Bench Press',
        difficultyLevel: 'Beginner',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        primaryEquipment: 'Barbell',
        shortVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
        explanationVideoUrl: '',
        secondaryMuscle: 'Triceps',
        mechanics: 'Compound',
      );

      expect(withDetails, isNot(_exercise));
      expect(withDetails.props, containsAll(<Object?>['Triceps', 'Compound']));
    });
  });

  group('ExercisesResultEntity —', () {
    test('two results with the same values are equal', () {
      const result = ExercisesResultEntity(
        totalExercises: 1,
        totalPages: 1,
        currentPage: 1,
        exercises: [_exercise],
      );
      const copy = ExercisesResultEntity(
        totalExercises: 1,
        totalPages: 1,
        currentPage: 1,
        exercises: [_exercise],
      );

      expect(copy, result);
    });

    test('a different exercise list makes the result unequal', () {
      const result = ExercisesResultEntity(
        totalExercises: 0,
        totalPages: 0,
        currentPage: 1,
        exercises: [],
      );

      expect(
        result,
        isNot(
          const ExercisesResultEntity(
            totalExercises: 0,
            totalPages: 0,
            currentPage: 1,
            exercises: [_exercise],
          ),
        ),
      );
    });
  });

  group('DifficultyLevelEntity and MuscleGroupEntity —', () {
    test('compare by value', () {
      expect(
        const DifficultyLevelEntity(id: '1', name: 'Beginner'),
        const DifficultyLevelEntity(id: '1', name: 'Beginner'),
      );
      expect(
        const MuscleGroupEntity(id: '1', name: 'Chest'),
        const MuscleGroupEntity(id: '1', name: 'Chest'),
      );
    });

    test('differ when the id or name changes', () {
      expect(
        const DifficultyLevelEntity(id: '1', name: 'Beginner'),
        isNot(const DifficultyLevelEntity(id: '2', name: 'Beginner')),
      );
      expect(
        const MuscleGroupEntity(id: '1', name: 'Chest'),
        isNot(const MuscleGroupEntity(id: '1', name: 'Back')),
      );
    });
  });
}
