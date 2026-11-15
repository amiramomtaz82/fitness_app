import 'package:fitness_app/features/exercise/data/api/exercise_api_client.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source_imp.dart';
import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseApiClient extends Mock implements ExerciseApiClient {}

final _primaryExercises = ExercisesResponseModel.fromJson({
  'totalExercises': 1,
  'totalPages': 1,
  'currentPage': 1,
  'exercises': [
    {
      '_id': 'exercise-1',
      'exercise': 'Barbell Bench Press',
      'difficulty_level': 'Beginner',
      'target_muscle_group': 'Chest',
      'prime_mover_muscle': 'Pectoralis Major',
      'primary_equipment': 'Barbell',
      'short_youtube_demonstration_link': '',
      'in_depth_youtube_explanation_link': '',
    },
  ],
});

final _randomExercises = ExercisesResponseModel.fromJson({
  'totalExercises': 1,
  'totalPages': 1,
  'currentPage': 1,
  'exercises': [
    {
      '_id': 'exercise-2',
      'exercise': 'Push Up',
      'difficulty_level': 'Beginner',
      'target_muscle_group': 'Chest',
      'prime_mover_muscle': 'Pectoralis Major',
      'primary_equipment': 'Bodyweight',
      'short_youtube_demonstration_link': '',
      'in_depth_youtube_explanation_link': '',
    },
  ],
});

final _emptyExercises = ExercisesResponseModel.fromJson({
  'totalExercises': 0,
  'totalPages': 0,
  'currentPage': 1,
  'exercises': <Map<String, dynamic>>[],
});

final _primaryLevels = DifficultyLevelsResponseModel.fromJson({
  'totalLevels': 2,
  'difficulty_levels': [
    {'_id': 'level-1', 'name': 'Beginner'},
    {'_id': 'level-2', 'name': 'Intermediate'},
  ],
});

final _allLevels = DifficultyLevelsResponseModel.fromJson({
  'totalLevels': 3,
  'difficulty_levels': [
    {'_id': 'level-1', 'name': 'Beginner'},
    {'_id': 'level-2', 'name': 'Intermediate'},
    {'_id': 'level-3', 'name': 'Advanced'},
  ],
});

final _emptyLevels = DifficultyLevelsResponseModel.fromJson({
  'totalLevels': 0,
  'difficulty_levels': <Map<String, dynamic>>[],
});

final _muscleGroups = MusclesGroupResponse.fromJson({
  'message': 'success',
  'musclesGroup': [
    {'_id': 'muscle-1', 'name': 'Chest'},
  ],
});

void main() {
  late MockExerciseApiClient client;
  late ExerciseRemoteDataSourceImp dataSource;

  setUp(() {
    client = MockExerciseApiClient();
    dataSource = ExerciseRemoteDataSourceImp(client);
  });

  group('ExerciseRemoteDataSourceImp.getExercises â€”', () {
    test(
      'returns the by-muscle-difficulty response when it has data',
      () async {
        when(
          () => client.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: 'muscle-1',
            difficultyLevelId: 'level-1',
            page: 1,
          ),
        ).thenAnswer((_) async => _primaryExercises);

        final response = await dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        );

        expect(response, same(_primaryExercises));
        verifyNever(
          () => client.getRandomExercises(
            targetMuscleGroupId: any(named: 'targetMuscleGroupId'),
            difficultyLevelId: any(named: 'difficultyLevelId'),
          ),
        );
      },
    );

    test(
      'falls back to random exercises when the primary list is empty',
      () async {
        when(
          () => client.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
            difficultyLevelId: any(named: 'difficultyLevelId'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => _emptyExercises);
        when(
          () => client.getRandomExercises(
            targetMuscleGroupId: 'muscle-1',
            difficultyLevelId: 'level-1',
          ),
        ).thenAnswer((_) async => _randomExercises);

        final response = await dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        );

        expect(response, same(_randomExercises));
        verify(
          () => client.getRandomExercises(
            targetMuscleGroupId: 'muscle-1',
            difficultyLevelId: 'level-1',
          ),
        ).called(1);
      },
    );

    test(
      'falls back to random exercises when the primary call throws',
      () async {
        when(
          () => client.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
            difficultyLevelId: any(named: 'difficultyLevelId'),
            page: any(named: 'page'),
          ),
        ).thenThrow(Exception('primary failed'));
        when(
          () => client.getRandomExercises(
            targetMuscleGroupId: any(named: 'targetMuscleGroupId'),
            difficultyLevelId: any(named: 'difficultyLevelId'),
          ),
        ).thenAnswer((_) async => _randomExercises);

        final response = await dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        );

        expect(response, same(_randomExercises));
      },
    );

    test('lets a random endpoint failure propagate to the repo', () async {
      when(
        () => client.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
          difficultyLevelId: any(named: 'difficultyLevelId'),
          page: any(named: 'page'),
        ),
      ).thenThrow(Exception('primary failed'));
      when(
        () => client.getRandomExercises(
          targetMuscleGroupId: any(named: 'targetMuscleGroupId'),
          difficultyLevelId: any(named: 'difficultyLevelId'),
        ),
      ).thenThrow(Exception('fallback failed'));

      expect(
        () => dataSource.getExercises(
          muscleId: 'muscle-1',
          difficultyId: 'level-1',
          page: 1,
        ),
        throwsException,
      );
    });
  });

  group('ExerciseRemoteDataSourceImp.getDifficultyLevels â€”', () {
    test('returns the muscle-specific levels when they exist', () async {
      when(
        () => client.getDifficultyLevels(primeMoverMuscleId: 'muscle-1'),
      ).thenAnswer((_) async => _primaryLevels);

      final response = await dataSource.getDifficultyLevels(
        muscleId: 'muscle-1',
      );

      expect(response, same(_primaryLevels));
      verifyNever(() => client.getAllDifficultyLevels());
    });

    test('falls back to all levels when the primary list is empty', () async {
      when(
        () => client.getDifficultyLevels(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
        ),
      ).thenAnswer((_) async => _emptyLevels);
      when(
        () => client.getAllDifficultyLevels(),
      ).thenAnswer((_) async => _allLevels);

      final response = await dataSource.getDifficultyLevels(
        muscleId: 'muscle-1',
      );

      expect(response, same(_allLevels));
      verify(() => client.getAllDifficultyLevels()).called(1);
    });

    test('falls back to all levels when the primary call throws', () async {
      when(
        () => client.getDifficultyLevels(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
        ),
      ).thenThrow(Exception('primary failed'));
      when(
        () => client.getAllDifficultyLevels(),
      ).thenAnswer((_) async => _allLevels);

      final response = await dataSource.getDifficultyLevels(
        muscleId: 'muscle-1',
      );

      expect(response, same(_allLevels));
    });
  });

  group('ExerciseRemoteDataSourceImp.getMuscleGroups â€”', () {
    test('forwards the request and returns the client response', () async {
      when(
        () => client.getMuscleGroups(),
      ).thenAnswer((_) async => _muscleGroups);

      final response = await dataSource.getMuscleGroups();

      expect(response, same(_muscleGroups));
      verify(() => client.getMuscleGroups()).called(1);
    });

    test('lets a client failure propagate', () async {
      when(() => client.getMuscleGroups()).thenThrow(Exception('boom'));

      expect(() => dataSource.getMuscleGroups(), throwsException);
    });
  });
}
