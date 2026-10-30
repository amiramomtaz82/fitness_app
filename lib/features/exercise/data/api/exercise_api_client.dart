import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:fitness_app/core/contants/endpoints/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../models/muscle_group_detail_response_dto.dart';
import '../models/muscles_group_response_dto.dart';

part 'exercise_api_client.g.dart';

@RestApi()
@injectable
abstract class ExerciseApiClient {
  @factoryMethod
  factory ExerciseApiClient(Dio dio) = _ExerciseApiClient;

  @GET(Endpoints.muscles)
  Future<MusclesGroupResponseDto> getMuscleGroups();

  @GET(Endpoints.musclesGroupByGroupId)
  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
    @Path() String muscleGroupId,
  );
}
