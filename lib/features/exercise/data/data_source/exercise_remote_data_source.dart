import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';

abstract interface class ExerciseRemoteDataSource {
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
