import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_difficlulty_levels_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_exercise_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_group_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

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

const _exercisesResult = ExercisesResultEntity(
  totalExercises: 1,
  totalPages: 1,
  currentPage: 1,
  exercises: [_exercise],
);

const _difficultyLevels = [
  DifficultyLevelEntity(id: 'level-1', name: 'Beginner'),
];

const _muscleGroups = [MuscleGroupEntity(id: 'muscle-1', name: 'Chest')];

void main() {
  late MockExerciseRepo repo;

  setUp(() => repo = MockExerciseRepo());

  group('GetExercisesUseCase —', () {
    test('forwards every argument to the repo', () async {
      const response = SuccessResponse(_exercisesResult);
      when(
        () => repo.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 2,
        ),
      ).thenAnswer((_) async => response);

      final result = await GetExercisesUseCase(repo)(
        muscleId: 'muscle-1',
        difficultyId: 'level-1',
        page: 2,
      );

      expect(result, same(response));
      verify(
        () => repo.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 2,
        ),
      ).called(1);
    });

    test('returns the error response from the repo unchanged', () async {
      final response = ErrorResponse<ExercisesResultEntity>(
        failure: const NetworkFailure(serverMessage: 'offline'),
      );
      when(
        () => repo.getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => response);

      final result = await GetExercisesUseCase(repo)(
        muscleId: 'muscle-1',
        difficultyId: 'level-1',
        page: 1,
      );

      expect(result, same(response));
    });
  });

  group('GetDifficultyLevelsUseCase —', () {
    test('forwards the muscle id to the repo', () async {
      const response = SuccessResponse(_difficultyLevels);
      when(
        () => repo.getDifficultyLevels(muscleId: 'muscle-1'),
      ).thenAnswer((_) async => response);

      final result = await GetDifficultyLevelsUseCase(repo)(
        muscleId: 'muscle-1',
      );

      expect(result, same(response));
      verify(() => repo.getDifficultyLevels(muscleId: 'muscle-1')).called(1);
    });

    test('returns the error response from the repo unchanged', () async {
      final response = ErrorResponse<List<DifficultyLevelEntity>>(
        failure: const ServerFailure(serverMessage: 'boom'),
      );
      when(
        () => repo.getDifficultyLevels(muscleId: any(named: 'muscleId')),
      ).thenAnswer((_) async => response);

      final result = await GetDifficultyLevelsUseCase(repo)(muscleId: 'm');

      expect(result, same(response));
    });
  });

  group('GetMuscleGroupsUseCase —', () {
    test('requests the muscle groups from the repo', () async {
      const response = SuccessResponse(_muscleGroups);
      when(() => repo.getMuscleGroups()).thenAnswer((_) async => response);

      final result = await GetMuscleGroupsUseCase(repo)();

      expect(result, same(response));
      verify(() => repo.getMuscleGroups()).called(1);
    });

    test('returns the error response from the repo unchanged', () async {
      final response = ErrorResponse<List<MuscleGroupEntity>>(
        failure: const UnknownFailure(serverMessage: 'unknown'),
      );
      when(() => repo.getMuscleGroups()).thenAnswer((_) async => response);

      final result = await GetMuscleGroupsUseCase(repo)();

      expect(result, same(response));
    });
  });
}
