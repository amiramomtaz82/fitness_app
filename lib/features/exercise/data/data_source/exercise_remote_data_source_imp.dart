import 'package:injectable/injectable.dart';
import '../api/exercise_api_client.dart';
import '../models/muscle_group_detail_response_dto.dart';
import '../models/muscles_group_response_dto.dart';
import 'exercise_remote_data_source.dart';

import '../models/muscles_response_model.dart';

@Injectable(as: ExerciseRemoteDataSource)
class ExerciseRemoteDataSourceImp implements ExerciseRemoteDataSource {
  final ExerciseApiClient _client;

  const ExerciseRemoteDataSourceImp(this._client);

  @override
  Future<MusclesResponseModel> getRandomMuscles() {
    return _client.getRandomMuscles();
  }
  @override
  Future<MusclesGroupResponseDto> getMuscleGroups() {
    return _client.getMuscleGroups();
  }

  @override
  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
    String muscleGroupId,
  ) {
    return _client.getMusclesByGroupId(muscleGroupId);
  }
}

