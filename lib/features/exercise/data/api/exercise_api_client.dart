
import 'package:dio/dio.dart';
import 'package:fitness_app/core/contants/endpoints/endpoints.dart';
import 'package:fitness_app/features/exercise/data/models/muscles_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'exercise_api_client.g.dart';

@RestApi()
abstract class ExerciseApiClient {
  factory ExerciseApiClient(Dio dio, {String baseUrl}) =
      _ExerciseApiClient;

  @GET(Endpoints.musclesRandom)
  Future<MusclesResponseModel> getRandomMuscles();
}
