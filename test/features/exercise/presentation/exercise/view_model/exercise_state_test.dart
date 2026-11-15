import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _exercise = ExerciseEntity(
  id: 'exercise-1',
  name: 'Barbell Bench Press',
  difficultyLevel: 'Beginner',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Barbell',
  shortVideoUrl: '',
  explanationVideoUrl: '',
);

const _levels = [
  DifficultyLevelEntity(id: 'level-1', name: 'Beginner'),
  DifficultyLevelEntity(id: 'level-2', name: 'Intermediate'),
];

const _result = ExercisesResultEntity(
  totalExercises: 12,
  totalPages: 3,
  currentPage: 1,
  exercises: [_exercise],
);

void main() {
  group('ExerciseDetailsState —', () {
    test('starts empty with safe defaults', () {
      const state = ExerciseDetailsState();

      expect(state.difficultyLevels.isInitial, isTrue);
      expect(state.exercises.isInitial, isTrue);
      expect(state.difficultyLevelsList, isEmpty);
      expect(state.exercisesList, isEmpty);
      expect(state.currentPage, 1);
      expect(state.totalPages, 1);
      expect(state.totalExercises, 0);
      expect(state.hasMorePages, isFalse);
      expect(state.selectedDifficultyId, isNull);
      expect(state.selectedDifficulty, isNull);
    });

    test('exposes data from a successful resource', () {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_levels),
        exercises: Resource.success(_result),
        selectedDifficultyId: 'level-2',
      );

      expect(state.difficultyLevelsList, _levels);
      expect(state.exercisesList, [_exercise]);
      expect(state.currentPage, 1);
      expect(state.totalPages, 3);
      expect(state.totalExercises, 12);
      expect(state.hasMorePages, isTrue);
      expect(state.selectedDifficulty?.name, 'Intermediate');
    });

    test('hasMorePages is false on the last page', () {
      const state = ExerciseDetailsState(
        exercises: Resource.success(
          ExercisesResultEntity(
            totalExercises: 1,
            totalPages: 1,
            currentPage: 1,
            exercises: [_exercise],
          ),
        ),
      );

      expect(state.hasMorePages, isFalse);
    });

    test('returns null selectedDifficulty for an unknown id', () {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_levels),
        selectedDifficultyId: 'missing',
      );

      expect(state.selectedDifficulty, isNull);
    });

    test('copyWith replaces only the given values', () {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_levels),
        selectedDifficultyId: 'level-1',
      );

      final updated = state.copyWith(
        exercises: const Resource.loading(),
        selectedDifficultyId: 'level-2',
      );

      expect(updated.difficultyLevels, same(state.difficultyLevels));
      expect(updated.exercises.isLoading, isTrue);
      expect(updated.selectedDifficultyId, 'level-2');
    });

    test('copyWith keeps the previous selection when it is omitted', () {
      const state = ExerciseDetailsState(selectedDifficultyId: 'level-1');

      expect(state.copyWith().selectedDifficultyId, 'level-1');
    });

    test('two states with the same resources are equal', () {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_levels),
        exercises: Resource.success(_result),
        selectedDifficultyId: 'level-1',
      );

      expect(state.copyWith(), state);
    });
  });
}
