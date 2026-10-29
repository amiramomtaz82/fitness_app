import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_detail_response_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_dto.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_group_response_dto.dart';
import 'package:fitness_app/features/exercise/data/repo_imp/exercise_repo_imp.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExerciseRemoteDataSource extends Mock
    implements ExerciseRemoteDataSource {}

void main() {
  late MockExerciseRemoteDataSource mockRemoteDataSource;
  late ExerciseRepoImp repo;

  setUp(() {
    mockRemoteDataSource = MockExerciseRemoteDataSource();
    repo = ExerciseRepoImp(mockRemoteDataSource);
  });

  group('ExerciseRepoImp', () {
    group('getMuscleGroups', () {
      test('returns SuccessResponse with mapped entities', () async {
        const dto = MusclesGroupResponseDto(
          message: 'success',
          musclesGroup: [
            MuscleGroupDto(id: 'group_1', name: 'Chest'),
            MuscleGroupDto(id: 'group_2', name: 'Back'),
          ],
        );
        when(
          () => mockRemoteDataSource.getMuscleGroups(),
        ).thenAnswer((_) async => dto);

        final result = await repo.getMuscleGroups();

        expect(result, isA<SuccessResponse<List<MuscleGroupEntity>>>());
        final data = (result as SuccessResponse<List<MuscleGroupEntity>>).data;
        expect(data, const [
          MuscleGroupEntity(id: 'group_1', name: 'Chest'),
          MuscleGroupEntity(id: 'group_2', name: 'Back'),
        ]);
        verify(() => mockRemoteDataSource.getMuscleGroups()).called(1);
      });

      test('returns SuccessResponse with empty list when null', () async {
        const dto = MusclesGroupResponseDto(musclesGroup: null);
        when(
          () => mockRemoteDataSource.getMuscleGroups(),
        ).thenAnswer((_) async => dto);

        final result = await repo.getMuscleGroups();

        expect(result, isA<SuccessResponse<List<MuscleGroupEntity>>>());
        final data = (result as SuccessResponse<List<MuscleGroupEntity>>).data;
        expect(data, isEmpty);
      });

      test('returns ErrorResponse when remote data source throws', () async {
        when(
          () => mockRemoteDataSource.getMuscleGroups(),
        ).thenThrow(Exception('network error'));

        final result = await repo.getMuscleGroups();

        expect(result, isA<ErrorResponse<List<MuscleGroupEntity>>>());
        verify(() => mockRemoteDataSource.getMuscleGroups()).called(1);
      });
    });

    group('getMusclesByGroupId', () {
      const groupId = 'group_1';

      test('returns SuccessResponse with mapped entities', () async {
        const dto = MuscleGroupDetailResponseDto(
          muscles: [
            MuscleDto(id: 'm_1', name: 'Upper Chest', image: 'https://img.png'),
          ],
        );
        when(
          () => mockRemoteDataSource.getMusclesByGroupId(groupId),
        ).thenAnswer((_) async => dto);

        final result = await repo.getMusclesByGroupId(groupId);

        expect(result, isA<SuccessResponse<List<MuscleEntity>>>());
        final data = (result as SuccessResponse<List<MuscleEntity>>).data;
        expect(data, const [
          MuscleEntity(
            id: 'm_1',
            name: 'Upper Chest',
            imageUrl: 'https://img.png',
          ),
        ]);
        verify(
          () => mockRemoteDataSource.getMusclesByGroupId(groupId),
        ).called(1);
      });

      test('returns SuccessResponse with empty list when null', () async {
        const dto = MuscleGroupDetailResponseDto(muscles: null);
        when(
          () => mockRemoteDataSource.getMusclesByGroupId(groupId),
        ).thenAnswer((_) async => dto);

        final result = await repo.getMusclesByGroupId(groupId);

        expect(result, isA<SuccessResponse<List<MuscleEntity>>>());
        final data = (result as SuccessResponse<List<MuscleEntity>>).data;
        expect(data, isEmpty);
      });

      test('returns ErrorResponse when remote data source throws', () async {
        when(
          () => mockRemoteDataSource.getMusclesByGroupId(groupId),
        ).thenThrow(Exception('network error'));

        final result = await repo.getMusclesByGroupId(groupId);

        expect(result, isA<ErrorResponse<List<MuscleEntity>>>());
        verify(
          () => mockRemoteDataSource.getMusclesByGroupId(groupId),
        ).called(1);
      });
    });
  });
}
