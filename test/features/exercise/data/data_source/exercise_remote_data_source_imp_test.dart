import 'package:fitness_app/features/exercise/data/api/exercise_api_client.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source_imp.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_detail_response_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_group_response_dto.dart';
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
        when(() => mockClient.getMuscleGroups())
            .thenAnswer((_) async => response);

        final result = await dataSource.getMuscleGroups();

        expect(result, response);
        verify(() => mockClient.getMuscleGroups()).called(1);
      });

      test('throws exception when client call throws', () async {
        when(() => mockClient.getMuscleGroups())
            .thenThrow(Exception('api error'));

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
            MuscleDto(
              id: 'm_1',
              name: 'Upper Chest',
              image: 'https://img.png',
            ),
          ],
        );
        when(() => mockClient.getMusclesByGroupId(groupId))
            .thenAnswer((_) async => response);

        final result = await dataSource.getMusclesByGroupId(groupId);

        expect(result, response);
        verify(() => mockClient.getMusclesByGroupId(groupId)).called(1);
      });

      test('throws exception when client call throws', () async {
        when(() => mockClient.getMusclesByGroupId(groupId))
            .thenThrow(Exception('api error'));

        expect(
          () => dataSource.getMusclesByGroupId(groupId),
          throwsException,
        );
        verify(() => mockClient.getMusclesByGroupId(groupId)).called(1);
      });
    });
  });
}
