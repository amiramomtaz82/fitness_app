import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

void main() {
  late MockExerciseRepo mockRepo;
  late GetMusclesByGroupIdUseCase useCase;

  setUp(() {
    mockRepo = MockExerciseRepo();
    useCase = GetMusclesByGroupIdUseCase(mockRepo);
  });

  group('GetMusclesByGroupIdUseCase', () {
    const groupId = 'group_1';

    test('returns SuccessResponse from repository', () async {
      const muscles = [
        MuscleEntity(
          id: 'm_1',
          name: 'Upper Chest',
          imageUrl: 'https://img.png',
        ),
      ];
      when(
        () => mockRepo.getMusclesByGroupId(groupId),
      ).thenAnswer((_) async => const SuccessResponse(muscles));

      final result = await useCase(groupId);

      expect(result, isA<SuccessResponse<List<MuscleEntity>>>());
      expect((result as SuccessResponse<List<MuscleEntity>>).data, muscles);
      verify(() => mockRepo.getMusclesByGroupId(groupId)).called(1);
    });

    test('returns ErrorResponse from repository', () async {
      final error = ErrorResponse<List<MuscleEntity>>(errMessage: 'failure');
      when(
        () => mockRepo.getMusclesByGroupId(groupId),
      ).thenAnswer((_) async => error);

      final result = await useCase(groupId);

      expect(result, error);
      verify(() => mockRepo.getMusclesByGroupId(groupId)).called(1);
    });
  });
}
