import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRepo extends Mock implements ExerciseRepo {}

void main() {
  late MockExerciseRepo mockRepo;
  late GetMuscleGroupsUseCase useCase;

  setUp(() {
    mockRepo = MockExerciseRepo();
    useCase = GetMuscleGroupsUseCase(mockRepo);
  });

  group('GetMuscleGroupsUseCase', () {
    test('returns SuccessResponse from repository', () async {
      const groups = [
        MuscleGroupEntity(id: 'group_1', name: 'Chest'),
        MuscleGroupEntity(id: 'group_2', name: 'Back'),
      ];
      when(
        () => mockRepo.getMuscleGroups(),
      ).thenAnswer((_) async => const SuccessResponse(groups));

      final result = await useCase();

      expect(result, isA<SuccessResponse<List<MuscleGroupEntity>>>());
      expect((result as SuccessResponse<List<MuscleGroupEntity>>).data, groups);
      verify(() => mockRepo.getMuscleGroups()).called(1);
    });

    test('returns ErrorResponse from repository', () async {
      final error = ErrorResponse<List<MuscleGroupEntity>>(
        errMessage: 'failure',
      );
      when(() => mockRepo.getMuscleGroups()).thenAnswer((_) async => error);

      final result = await useCase();

      expect(result, error);
      verify(() => mockRepo.getMuscleGroups()).called(1);
    });
  });
}
