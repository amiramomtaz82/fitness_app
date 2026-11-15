import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:fitness_app/features/exercise/data/repo_imp/exercise_repo_imp.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRemoteDataSource extends Mock
    implements ExerciseRemoteDataSource {}

const _exercisePayload = {
  '_id': 'exercise-1',
  'exercise': 'Barbell Bench Press',
  'difficulty_level': 'Beginner',
  'target_muscle_group': 'Chest',
  'prime_mover_muscle': 'Pectoralis Major',
  'primary_equipment': 'Barbell',
  'short_youtube_demonstration_link': 'https://youtu.be/dQw4w9WgXcQ',
  'in_depth_youtube_explanation_link': '',
};

final _exercisesResponse = ExercisesResponseModel.fromJson({
  'message': 'success',
  'totalExercises': 1,
  'totalPages': 2,
  'currentPage': 1,
  'exercises': [_exercisePayload],
});

final _difficultyLevelsResponse = DifficultyLevelsResponseModel.fromJson({
  'message': 'success',
  'totalLevels': 1,
  'difficulty_levels': [
    {'_id': 'level-1', 'name': 'Beginner'},
  ],
});

final _muscleGroupsResponse = MusclesGroupResponse.fromJson({
  'message': 'success',
  'musclesGroup': [
    {'_id': 'muscle-1', 'name': 'Chest'},
    {'_id': 'muscle-2', 'name': 'Back'},
  ],
});

void main() {
  late MockExerciseRemoteDataSource dataSource;
  late ExerciseRepoImp repo;

  setUp(() {
    dataSource = MockExerciseRemoteDataSource();
    repo = ExerciseRepoImp(dataSource);
  });

  group('ExerciseRepoImp.getExercises —', () {
    test('maps the response model into domain entities', () async {
      when(
        () => dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        ),
      ).thenAnswer((_) async => _exercisesResponse);

      final result = await repo.getExercises(
        muscleId: 'muscle-1',
        difficultyId: 'level-1',
        page: 1,
      );

      expect(result, isA<SuccessResponse<ExercisesResultEntity>>());
      final data = (result as SuccessResponse<ExercisesResultEntity>).data;
      expect(data.totalExercises, 1);
      expect(data.totalPages, 2);
      expect(data.currentPage, 1);
      expect(data.exercises.single.name, 'Barbell Bench Press');
      expect(
        data.exercises.single.shortVideoUrl,
        'https://youtu.be/dQw4w9WgXcQ',
      );
      verify(
        () => dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        ),
      ).called(1);
    });

    test('wraps a data source exception in an ErrorResponse', () async {
      when(
        () => dataSource.getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await repo.getExercises(
        muscleId: 'muscle-1',
        difficultyId: 'level-1',
        page: 1,
      );

      expect(result, isA<ErrorResponse<ExercisesResultEntity>>());
      expect((result as ErrorResponse).failure, isA<UnknownFailure>());
    });
  });

  group('ExerciseRepoImp.getDifficultyLevels —', () {
    test('maps the response entities into domain entities', () async {
      when(
        () => dataSource.getDifficultyLevels(muscleId: 'muscle-1'),
      ).thenAnswer((_) async => _difficultyLevelsResponse);

      final result = await repo.getDifficultyLevels(muscleId: 'muscle-1');

      final data = (result as SuccessResponse).data;
      expect(data.single.id, 'level-1');
      expect(data.single.name, 'Beginner');
    });

    test('returns an empty list when the payload has no levels', () async {
      when(
        () => dataSource.getDifficultyLevels(muscleId: 'muscle-1'),
      ).thenAnswer(
        (_) async => DifficultyLevelsResponseModel.fromJson(const {}),
      );

      final result = await repo.getDifficultyLevels(muscleId: 'muscle-1');

      expect((result as SuccessResponse).data, isEmpty);
    });

    test('wraps a data source exception in an ErrorResponse', () async {
      when(
        () => dataSource.getDifficultyLevels(muscleId: any(named: 'muscleId')),
      ).thenThrow(Exception('boom'));

      final result = await repo.getDifficultyLevels(muscleId: 'muscle-1');

      expect(result, isA<ErrorResponse>());
    });
  });

  group('ExerciseRepoImp.getMuscleGroups —', () {
    test('maps every muscle group into a domain entity', () async {
      when(
        () => dataSource.getMuscleGroups(),
      ).thenAnswer((_) async => _muscleGroupsResponse);

      final result = await repo.getMuscleGroups();

      expect(result, isA<SuccessResponse<List<MuscleGroupEntity>>>());
      final groups = (result as SuccessResponse<List<MuscleGroupEntity>>).data;
      expect(groups, hasLength(2));
      expect(groups.first.name, 'Chest');
      expect(groups.last.id, 'muscle-2');
    });

    test('returns an empty list when the payload omits the groups', () async {
      when(
        () => dataSource.getMuscleGroups(),
      ).thenAnswer((_) async => MusclesGroupResponse.fromJson(const {}));

      final result = await repo.getMuscleGroups();

      expect(
        (result as SuccessResponse<List<MuscleGroupEntity>>).data,
        isEmpty,
      );
    });

    test('wraps a data source exception in an ErrorResponse', () async {
      when(() => dataSource.getMuscleGroups()).thenThrow(Exception('boom'));

      final result = await repo.getMuscleGroups();

      expect(result, isA<ErrorResponse<List<MuscleGroupEntity>>>());
    });
  });
}
