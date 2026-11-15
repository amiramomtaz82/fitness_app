import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetExercisesUseCase {
  final ExerciseRepo repo;

  GetExercisesUseCase(this.repo);

  Future<BaseResponse<ExercisesResultEntity>> call({
    required String muscleId,
    required String difficultyId,
    required int page,
  }) {
    return repo.getExercises(
      muscleId: muscleId,
      difficultyId: difficultyId,
      page: page,
    );
  }
}
