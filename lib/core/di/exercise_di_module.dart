import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/exercise/data/api/exercise_api_client.dart';

@module
abstract class ExerciseDiModule {
  @lazySingleton
  ExerciseApiClient exerciseApiClient(Dio dio) => ExerciseApiClient(dio);
}
