import 'package:fitness_app/features/exercise/data/models/levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';

import '../models/muscle_group_detail_response_dto.dart';
import '../models/muscles_group_response_dto.dart';

abstract interface class ExerciseRemoteDataSource {
  Future<MusclesGroupResponseDto> getMuscleGroups();

  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
    String muscleGroupId,
  );

  Future<MusclesResponseModel> getRandomMuscles();

  Future<LevelsResponseModel> getDifficultyLevels();

  Future<ExercisesResponseModel> getExercisesByMuscleDifficulty({
    required String primeMoverMuscleId,
    required String difficultyLevelId,
  });
}