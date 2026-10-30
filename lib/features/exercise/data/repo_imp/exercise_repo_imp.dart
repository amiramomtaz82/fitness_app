import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
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
      return groups.map((g) => g.toEntity()).toList();
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
      return muscles.map((m) => m.toEntity()).toList();
    });
  }
}
