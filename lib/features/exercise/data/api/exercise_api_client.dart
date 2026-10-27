
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'exercise_api_client.g.dart';

@RestApi()
abstract class ExerciseApiClient {
  factory ExerciseApiClient(Dio dio, {String baseUrl}) = _ExerciseApiClient;
}