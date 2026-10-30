import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ExerciseRepo)
class ExerciseRepoImp implements ExerciseRepo {
  final ExerciseRemoteDataSource _exerciseRemoteDataSource;

  const ExerciseRepoImp(this._exerciseRemoteDataSource);

  @override
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles() {
    return safeCall(() async {
      final response = await _exerciseRemoteDataSource.getRandomMuscles();

      return response.muscles?.map((muscle) => muscle.toDomain()).toList() ??
          [];
    });
  }
}
