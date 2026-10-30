import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';

abstract interface class ExerciseRepo {
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles();

  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups();
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(
    String muscleGroupId,
  );
}
