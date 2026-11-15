import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDifficultyLevelsUseCase {
  final ExerciseRepo repo;

  GetDifficultyLevelsUseCase(this.repo);

  Future<BaseResponse<List<DifficultyLevelEntity>>> call({
    required String muscleId,
  }) {
    return repo.getDifficultyLevels(muscleId: muscleId);
  }
}
