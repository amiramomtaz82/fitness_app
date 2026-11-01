import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ExerciseRepo)
class ExerciseRepoImp implements ExerciseRepo {
  final ExerciseRemoteDataSource _remoteDataSource;

  const ExerciseRepoImp(this._remoteDataSource);

  @override
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups() {
    return safeCall<List<MuscleGroupEntity>>(() async {
      final response = await _remoteDataSource.getMuscleGroups();
      final groups = response.musclesGroup ?? [];

      return groups.map((group) => group.toEntity()).toList();
    });
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(
    String muscleGroupId,
  ) {
    return safeCall<List<MuscleEntity>>(() async {
      final response = await _remoteDataSource.getMusclesByGroupId(
        muscleGroupId,
      );
      final muscles = response.muscles ?? [];

      return muscles.map((muscle) => muscle.toEntity()).toList();
    });
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles() {
    return safeCall<List<MuscleEntity>>(() async {
      final response = await _remoteDataSource.getRandomMuscles();

      return response.muscles?.map((muscle) => muscle.toDomain()).toList() ??
          [];
    });
  }

  @override
  Future<BaseResponse<List<DifficultyLevelEntity>>> getDifficultyLevels() {
    return safeCall<List<DifficultyLevelEntity>>(() async {
      final response = await _remoteDataSource.getDifficultyLevels();

      return response.levels?.map((level) => level.toDomain()).toList() ?? [];
    });
  }

  @override
  Future<BaseResponse<List<ExerciseEntity>>> getExercisesByMuscleDifficulty({
    required String primeMoverMuscleId,
    required String difficultyLevelId,
  }) {
    return safeCall<List<ExerciseEntity>>(() async {
      final response = await _remoteDataSource.getExercisesByMuscleDifficulty(
        primeMoverMuscleId: primeMoverMuscleId,
        difficultyLevelId: difficultyLevelId,
      );

      return response.exercises
              ?.map((exercise) => exercise.toEntity())
              .toList() ??
          [];
    });
  }
}
