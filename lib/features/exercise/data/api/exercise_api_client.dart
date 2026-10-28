
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/muscle_group_detail_response_dto.dart';
import '../models/muscles_group_response_dto.dart';

part 'exercise_api_client.g.dart';

@RestApi()
abstract class ExerciseApiClient {
  factory ExerciseApiClient(Dio dio, {String baseUrl}) = _ExerciseApiClient;
  @GET(Endpoints.muscles)
  Future<MusclesGroupResponseDto> getMuscleGroups();
  @GET('${Endpoints.musclesGroup}/{muscleGroupId}')
  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
      @Path('muscleGroupId') String muscleGroupId,
      );
}