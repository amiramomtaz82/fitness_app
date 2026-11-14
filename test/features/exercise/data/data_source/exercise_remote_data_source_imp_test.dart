import 'package:fitness_app/features/exercise/data/api/exercise_api_client.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source_imp.dart';
import 'package:fitness_app/features/exercise/data/models/difficulty_level_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercise_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_detail_response_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_group_response_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/levels_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseApiClient extends Mock implements ExerciseApiClient {}

void main() {
  late MockExerciseApiClient mockClient;
  late ExerciseRemoteDataSourceImp dataSource;

  setUp(() {
    mockClient = MockExerciseApiClient();
    dataSource = ExerciseRemoteDataSourceImp(mockClient);
  });

  group('ExerciseRemoteDataSourceImp', () {
    group('getMuscleGroups', () {
      test('returns client response when call succeeds', () async {
        const response = MusclesGroupResponseDto(
          message: 'success',
          musclesGroup: [
            MuscleGroupDto(id: 'group_1', name: 'Chest'),
            MuscleGroupDto(id: 'group_2', name: 'Back'),
          ],
        );
        when(
          () => mockClient.getMuscleGroups(),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getMuscleGroups();

        expect(result, response);
        verify(() => mockClient.getMuscleGroups()).called(1);
      });

      test('throws exception when client call throws', () async {
        when(
          () => mockClient.getMuscleGroups(),
        ).thenThrow(Exception('api error'));

        expect(() => dataSource.getMuscleGroups(), throwsException);
        verify(() => mockClient.getMuscleGroups()).called(1);
      });
    });

    group('getMusclesByGroupId', () {
      const groupId = 'group_1';
      test('returns client response when call succeeds', () async {
        const response = MuscleGroupDetailResponseDto(
          message: 'success',
          muscleGroup: MuscleGroupDto(id: groupId, name: 'Chest'),
          muscles: [
            MuscleDto(id: 'm_1', name: 'Upper Chest', image: 'https://img.png'),
          ],
        );
        when(
          () => mockClient.getMusclesByGroupId(groupId),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getMusclesByGroupId(groupId);

        expect(result, response);
        verify(() => mockClient.getMusclesByGroupId(groupId)).called(1);
      });

      test('throws exception when client call throws', () async {
        when(
          () => mockClient.getMusclesByGroupId(groupId),
        ).thenThrow(Exception('api error'));

        expect(() => dataSource.getMusclesByGroupId(groupId), throwsException);
        verify(() => mockClient.getMusclesByGroupId(groupId)).called(1);
      });
    });

    group('getRandomMuscles', () {
      test('returns client response when call succeeds', () async {
        const response = MusclesResponseModel(
          message: 'success',
          totalMuscles: 2,
          muscles: [
            MuscleModel(id: 'm_1', name: 'Chest', image: 'u1'),
            MuscleModel(id: 'm_2', name: 'Back', image: 'u2'),
          ],
        );
        when(
          () => mockClient.getRandomMuscles(),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getRandomMuscles();

        expect(result, response);
        verify(() => mockClient.getRandomMuscles()).called(1);
      });

      test('throws exception when client call throws', () async {
        when(
          () => mockClient.getRandomMuscles(),
        ).thenThrow(Exception('api error'));

        expect(() => dataSource.getRandomMuscles(), throwsException);
        verify(() => mockClient.getRandomMuscles()).called(1);
      });
    });

    group('getDifficultyLevels', () {
      test('returns client response when call succeeds', () async {
        const response = LevelsResponseModel(
          message: 'success',
          levels: [
            DifficultyLevelModel(id: 'l_1', name: 'Beginner'),
            DifficultyLevelModel(id: 'l_2', name: 'Advanced'),
          ],
        );
        when(
          () => mockClient.getDifficultyLevels(),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getDifficultyLevels();

        expect(result, response);
        verify(() => mockClient.getDifficultyLevels()).called(1);
      });

      test('throws exception when client call throws', () async {
        when(
          () => mockClient.getDifficultyLevels(),
        ).thenThrow(Exception('api error'));

        expect(() => dataSource.getDifficultyLevels(), throwsException);
        verify(() => mockClient.getDifficultyLevels()).called(1);
      });
    });

    group('getExercisesByMuscleDifficulty', () {
      const primeMoverMuscleId = 'm_1';
      const difficultyLevelId = 'l_1';
      test('returns client response when call succeeds', () async {
        const response = ExercisesResponseModel(
          message: 'success',
          totalExercises: 1,
          exercises: [
            ExerciseModel(
              id: 'e_1',
              name: 'Bench Press',
              difficultyLevel: 'Beginner',
            ),
          ],
        );
        when(
          () => mockClient.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: primeMoverMuscleId,
            difficultyLevelId: difficultyLevelId,
          ),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getExercisesByMuscleDifficulty(
          primeMoverMuscleId: primeMoverMuscleId,
          difficultyLevelId: difficultyLevelId,
        );

        expect(result, response);
        verify(
          () => mockClient.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: primeMoverMuscleId,
            difficultyLevelId: difficultyLevelId,
          ),
        ).called(1);
      });

      test('throws exception when client call throws', () async {
        when(
          () => mockClient.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: primeMoverMuscleId,
            difficultyLevelId: difficultyLevelId,
          ),
        ).thenThrow(Exception('api error'));

        expect(
          () => dataSource.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: primeMoverMuscleId,
            difficultyLevelId: difficultyLevelId,
          ),
          throwsException,
        );
        verify(
          () => mockClient.getExercisesByMuscleDifficulty(
            primeMoverMuscleId: primeMoverMuscleId,
            difficultyLevelId: difficultyLevelId,
          ),
        ).called(1);
      });
    });
  });
}
