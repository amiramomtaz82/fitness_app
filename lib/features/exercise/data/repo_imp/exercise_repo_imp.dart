import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ExerciseRepo)
class ExerciseRepoImp implements ExerciseRepo {
  final ExerciseRemoteDataSource _exerciseRemoteDataSource;

  const ExerciseRepoImp(this._exerciseRemoteDataSource);

  @override
  Future<BaseResponse<ExercisesResultEntity>> getExercises({
    required String muscleId,
    required String difficultyId,
    required int page,
  }) {
    return safeCall(() async {
      final response = await _exerciseRemoteDataSource.getExercises(
        muscleId: muscleId,
        difficultyId: difficultyId,
        page: page,
      );

      return response.toEntity();
    });
  }

  @override
  Future<BaseResponse<List<DifficultyLevelEntity>>> getDifficultyLevels({required String muscleId}) {
    return safeCall(() async {
      final response = await _exerciseRemoteDataSource.getDifficultyLevels(muscleId: muscleId);

      return response.toEntities();
    });
  }
    @override
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups() {
    return safeCall<List<MuscleGroupEntity>>(() async {
      final response = await _exerciseRemoteDataSource.getMuscleGroups();
      final groups = response.musclesGroup ?? [];

      return groups.map((group) => group.toEntity()).toList();
    });
  }
}
