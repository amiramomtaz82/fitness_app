import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';

abstract interface class ExerciseRepo {
  Future<BaseResponse<ExercisesResultEntity>> getExercises({
    required String muscleId,
    required String difficultyId,
    required int page,
  });

  Future<BaseResponse<List<DifficultyLevelEntity>>> getDifficultyLevels({
    required String muscleId,
  });
    Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups();
}
