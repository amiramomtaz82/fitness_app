import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMuscleGroupsUseCase {
  final ExerciseRepo _exerciseRepo;

  const GetMuscleGroupsUseCase(this._exerciseRepo);

  Future<BaseResponse<List<MuscleGroupEntity>>> call() {
    return _exerciseRepo.getMuscleGroups();
  }
}
