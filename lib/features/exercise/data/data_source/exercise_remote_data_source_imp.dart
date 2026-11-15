import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:injectable/injectable.dart';

import '../api/exercise_api_client.dart';
import 'exercise_remote_data_source.dart';

@Injectable(as: ExerciseRemoteDataSource)
class ExerciseRemoteDataSourceImp implements ExerciseRemoteDataSource {
  final ExerciseApiClient _client;

  const ExerciseRemoteDataSourceImp(this._client);

  @override
  Future<ExercisesResponseModel> getExercises({
    required String muscleId,
    required String difficultyId,
    required int page,
  }) async {
    try {
      final response = await _client.getExercisesByMuscleDifficulty(
        primeMoverMuscleId: muscleId,
        difficultyLevelId: difficultyId,
        page: page,
      );
      if (response.exercises != null && response.exercises!.isNotEmpty) {
        return response;
      }
    } catch (_) {}

    return _client.getRandomExercises(
      targetMuscleGroupId: muscleId,
      difficultyLevelId: difficultyId,
    );
  }

  @override
  Future<DifficultyLevelsResponseModel> getDifficultyLevels({
    required String muscleId,
  }) async {
    try {
      final response = await _client.getDifficultyLevels(
        primeMoverMuscleId: muscleId,
      );
      if (response.difficultyLevels != null &&
          response.difficultyLevels!.isNotEmpty) {
        return response;
      }
    } catch (_) {}

    return _client.getAllDifficultyLevels();
  }

  @override
  Future<MusclesGroupResponse> getMuscleGroups() {
    return _client.getMuscleGroups();
  }
}
