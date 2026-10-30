import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';

abstract interface class ExerciseRepo {
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles();

  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups();

  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(
    String muscleGroupId,
  );

  Future<BaseResponse<List<DifficultyLevelEntity>>> getDifficultyLevels();

  Future<BaseResponse<List<ExerciseEntity>>> getExercisesByMuscleDifficulty({
    required String primeMoverMuscleId,
    required String difficultyLevelId,
  });
}
