import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';

import '../models/muscle_group_detail_response_dto.dart';

abstract interface class ExerciseRemoteDataSource {
  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
    String muscleGroupId,
  );

  Future<MusclesResponseModel> getRandomMuscles();
  Future<ExercisesResponseModel> getExercisesByMuscleDifficulty({
    required String primeMoverMuscleId,
    required String difficultyLevelId,
  });

  Future<ExercisesResponseModel> getExercises({
    required String muscleId,
    required String difficultyId,
    required int page,
  });

  Future<DifficultyLevelsResponseModel> getDifficultyLevels({
    required String muscleId,
  });

  Future<MusclesGroupResponse> getMuscleGroups();
}
