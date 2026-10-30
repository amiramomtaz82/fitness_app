import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';

abstract interface class ExerciseRepo {
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles();
}