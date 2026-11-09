import 'dart:math';

import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_trainings_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

void main() {
  late MockExerciseRepo mockRepo;
  late GetPopularTrainingsUseCase useCase;

  setUp(() {
    mockRepo = MockExerciseRepo();
    useCase = GetPopularTrainingsUseCase(mockRepo, Random(0));
  });

  group('GetPopularTrainingsUseCase', () {
    const muscles = [MuscleEntity(id: 'm_1', name: 'Chest', imageUrl: 'u1')];
    const levels = [DifficultyLevelEntity(id: 'l_1', name: 'Beginner')];
    const exercises = [
      ExerciseEntity(
        id: 'e_1',
        name: 'Bench Press',
        imageUrl: 'e1',
        difficultyLevel: 'Beginner',
      ),
    ];

    test('returns popular trainings built from muscle and level', () async {
      when(
        () => mockRepo.getDifficultyLevels(),
      ).thenAnswer((_) async => const SuccessResponse(levels));

      when(
        () => mockRepo.getRandomMuscles(),
      ).thenAnswer((_) async => const SuccessResponse(muscles));

      when(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      ).thenAnswer((_) async => const SuccessResponse(exercises));

      final result = await useCase();

      expect(result, isA<SuccessResponse<List<PopularTrainingEntity>>>());
      final trainings =
          (result as SuccessResponse<List<PopularTrainingEntity>>).data;
      expect(trainings, hasLength(2));
      expect(trainings.first.muscleName, 'Chest');
      expect(trainings.first.levelName, 'Beginner');
      expect(trainings.first.exercisesCount, 1);
      expect(trainings.first.imageUrl, 'u1');
      verify(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      ).called(2);
    });

    test('returns an empty list when there is nothing to train on', () async {
      when(() => mockRepo.getDifficultyLevels()).thenAnswer(
        (_) async => const SuccessResponse<List<DifficultyLevelEntity>>([]),
      );

      when(
        () => mockRepo.getRandomMuscles(),
      ).thenAnswer((_) async => const SuccessResponse<List<MuscleEntity>>([]));

      final result = await useCase();

      expect(result, isA<SuccessResponse<List<PopularTrainingEntity>>>());
      expect(
        (result as SuccessResponse<List<PopularTrainingEntity>>).data,
        isEmpty,
      );
      verifyNever(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      );
    });

    test('returns error when difficulty levels fail', () async {
      final error = ErrorResponse<List<DifficultyLevelEntity>>(
        errMessage: 'failure',
      );
      when(() => mockRepo.getDifficultyLevels()).thenAnswer((_) async => error);

      final result = await useCase();

      expect(result, isA<ErrorResponse<List<PopularTrainingEntity>>>());
      verifyNever(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      );
    });

    test('returns error when random muscles fail', () async {
      when(
        () => mockRepo.getDifficultyLevels(),
      ).thenAnswer((_) async => const SuccessResponse(levels));

      final error = ErrorResponse<List<MuscleEntity>>(errMessage: 'failure');
      when(() => mockRepo.getRandomMuscles()).thenAnswer((_) async => error);

      final result = await useCase();

      expect(result, isA<ErrorResponse<List<PopularTrainingEntity>>>());
    });

    test('returns error when exercises fail', () async {
      when(
        () => mockRepo.getDifficultyLevels(),
      ).thenAnswer((_) async => const SuccessResponse(levels));

      when(
        () => mockRepo.getRandomMuscles(),
      ).thenAnswer((_) async => const SuccessResponse(muscles));

      final error = ErrorResponse<List<ExerciseEntity>>(errMessage: 'failure');
      when(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      ).thenAnswer((_) async => error);

      final result = await useCase();

      expect(result, isA<ErrorResponse<List<PopularTrainingEntity>>>());
    });
  });
}
