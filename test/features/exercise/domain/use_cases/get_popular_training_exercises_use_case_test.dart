import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_training_exercises_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

void main() {
  late MockExerciseRepo mockRepo;
  late GetPopularTrainingExercisesUseCase useCase;

  const exercises = [
    ExerciseEntity(
      id: 'e_1',
      name: 'Bench Press',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Pectoralis Major',
    ),
  ];

  setUp(() {
    mockRepo = MockExerciseRepo();
    useCase = GetPopularTrainingExercisesUseCase(mockRepo);
  });

  group('GetPopularTrainingExercisesUseCase', () {
    test('forwards both ids to the repository and returns exercises', () async {
      when(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      ).thenAnswer((_) async => const SuccessResponse(exercises));

      final result = await useCase(
        primeMoverMuscleId: 'm_1',
        difficultyLevelId: 'l_1',
      );

      expect(result, isA<SuccessResponse<List<ExerciseEntity>>>());
      expect((result as SuccessResponse<List<ExerciseEntity>>).data, exercises);
      verify(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: 'm_1',
          difficultyLevelId: 'l_1',
        ),
      ).called(1);
    });

    test('returns the failure the repository reported', () async {
      const failure = ServerFailure(serverMessage: 'server error');
      when(
        () => mockRepo.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
          difficultyLevelId: any(named: 'difficultyLevelId'),
        ),
      ).thenAnswer(
        (_) async => ErrorResponse<List<ExerciseEntity>>(failure: failure),
      );

      final result = await useCase(
        primeMoverMuscleId: 'm_1',
        difficultyLevelId: 'l_1',
      );

      expect(result, isA<ErrorResponse<List<ExerciseEntity>>>());
      expect((result as ErrorResponse<List<ExerciseEntity>>).failure, failure);
    });
  });
}
