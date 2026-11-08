import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_random_muscles_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

void main() {
  late MockExerciseRepo mockRepo;
  late GetRandomMusclesUseCase useCase;

  setUp(() {
    mockRepo = MockExerciseRepo();
    useCase = GetRandomMusclesUseCase(mockRepo);
  });

  group('GetRandomMusclesUseCase', () {
    test('returns SuccessResponse from repository', () async {
      const muscles = [
        MuscleEntity(id: 'm_1', name: 'Chest', imageUrl: 'https://img.png'),
      ];
      when(
        () => mockRepo.getRandomMuscles(),
      ).thenAnswer((_) async => const SuccessResponse(muscles));

      final result = await useCase();

      expect(result, isA<SuccessResponse<List<MuscleEntity>>>());
      expect((result as SuccessResponse<List<MuscleEntity>>).data, muscles);
      verify(() => mockRepo.getRandomMuscles()).called(1);
    });

    test('returns ErrorResponse from repository', () async {
      final error = ErrorResponse<List<MuscleEntity>>(errMessage: 'failure');
      when(() => mockRepo.getRandomMuscles()).thenAnswer((_) async => error);

      final result = await useCase();

      expect(result, error);
      verify(() => mockRepo.getRandomMuscles()).called(1);
    });
  });
}
