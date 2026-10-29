import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMusclesByGroupIdUseCase {
  final ExerciseRepo _exerciseRepo;

  const GetMusclesByGroupIdUseCase(this._exerciseRepo);

  Future<BaseResponse<List<MuscleEntity>>> call(String muscleGroupId) {
    return _exerciseRepo.getMusclesByGroupId(muscleGroupId);
  }
}
