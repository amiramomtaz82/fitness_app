import 'package:injectable/injectable.dart';

import '../api/exercise_api_client.dart';
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
}
