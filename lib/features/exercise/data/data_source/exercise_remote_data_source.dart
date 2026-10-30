import '../models/muscle_group_detail_response_dto.dart';
import '../models/muscles_group_response_dto.dart';

abstract interface class ExerciseRemoteDataSource {
  Future<MusclesGroupResponseDto> getMuscleGroups();
  Future<MuscleGroupDetailResponseDto> getMusclesByGroupId(
    String muscleGroupId,
  );
}
