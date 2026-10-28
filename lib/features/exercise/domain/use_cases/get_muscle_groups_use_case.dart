import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/muscle_group_entity.dart';
import '../repo/exercise_repo.dart';

@injectable
class GetMuscleGroupsUseCase {
  final ExerciseRepo _exerciseRepo;

  const GetMuscleGroupsUseCase(this._exerciseRepo);

  Future<BaseResponse<List<MuscleGroupEntity>>> call() {
    return _exerciseRepo.getMuscleGroups();
  }
}