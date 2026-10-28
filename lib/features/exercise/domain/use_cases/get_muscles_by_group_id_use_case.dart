import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/muscle_entity.dart';
import '../repo/exercise_repo.dart';

@injectable
class GetMusclesByGroupIdUseCase {
  final ExerciseRepo _exerciseRepo;

  const GetMusclesByGroupIdUseCase(this._exerciseRepo);

  Future<BaseResponse<List<MuscleEntity>>> call(String muscleGroupId) {
    return _exerciseRepo.getMusclesByGroupId(muscleGroupId);
  }
}