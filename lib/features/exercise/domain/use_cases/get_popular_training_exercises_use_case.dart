import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPopularTrainingExercisesUseCase {
  final ExerciseRepo _exerciseRepo;

  GetPopularTrainingExercisesUseCase(this._exerciseRepo);

  Future<BaseResponse<List<ExerciseEntity>>> call({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
  }) {
    return _exerciseRepo.getExercisesByMuscleDifficulty(
      primeMoverMuscleId: primeMoverMuscleId ?? '',
      difficultyLevelId: difficultyLevelId ?? '',
    );
  }
}
