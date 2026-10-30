import '../models/muscles_response_model.dart';

abstract interface class ExerciseRemoteDataSource {
  Future<MusclesResponseModel> getRandomMuscles();
}
