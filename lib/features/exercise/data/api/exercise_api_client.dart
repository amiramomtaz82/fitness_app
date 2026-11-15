import 'package:dio/dio.dart';
import 'package:fitness_app/core/contants/endpoints/api_request_params.dart';
import 'package:fitness_app/core/contants/endpoints/endpoints.dart';
import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:retrofit/retrofit.dart';

part 'exercise_api_client.g.dart';

@RestApi()
abstract class ExerciseApiClient {
  factory ExerciseApiClient(Dio dio, {String baseUrl}) = _ExerciseApiClient;

  @GET(Endpoints.exercisesByMuscleDifficulty)
  Future<ExercisesResponseModel> getExercisesByMuscleDifficulty({
    @Query(ApiRequestParams.primeMoverMuscleId)
    required String primeMoverMuscleId,
    @Query(ApiRequestParams.difficultyLevelId)
    required String difficultyLevelId,
    @Query(ApiRequestParams.page) int page = 1,
    @Query(ApiRequestParams.pageSize) int pageSize = 10,
  });

  @GET(Endpoints.exercisesRandom)
  Future<ExercisesResponseModel> getRandomExercises({
    @Query('targetMuscleGroupId') required String targetMuscleGroupId,
    @Query('difficultyLevelId') required String difficultyLevelId,
  });

  @GET(Endpoints.levels)
  Future<DifficultyLevelsResponseModel> getDifficultyLevels({
    @Query(ApiRequestParams.primeMoverMuscleId) required String primeMoverMuscleId,
  });

  @GET('/levels')
  Future<DifficultyLevelsResponseModel> getAllDifficultyLevels();

  @GET(Endpoints.muscles)
  Future<MusclesGroupResponse> getMuscleGroups();
}
