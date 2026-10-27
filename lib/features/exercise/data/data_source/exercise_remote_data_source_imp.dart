import 'package:injectable/injectable.dart';

import '../api/exercise_api_client.dart';
import 'exercise_remote_data_source.dart';

@Injectable(as: ExerciseRemoteDataSource)
class ExerciseRemoteDataSourceImp implements ExerciseRemoteDataSource {
final ExerciseApiClient _client;

const ExerciseRemoteDataSourceImp(this._client);

}