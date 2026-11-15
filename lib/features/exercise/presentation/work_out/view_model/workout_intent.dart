import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';

sealed class WorkoutIntent {
  const WorkoutIntent();
}

final class InitWorkoutsIntent extends WorkoutIntent {
  const InitWorkoutsIntent();
}

final class SelectMuscleGroupIntent extends WorkoutIntent {
  final MuscleGroupEntity group;
  const SelectMuscleGroupIntent(this.group);
}

final class RetryFetchMusclesIntent extends WorkoutIntent {
  const RetryFetchMusclesIntent();
}

class MuscleSelectedIntent extends WorkoutIntent {
  final String muscleId;
  final String? muscleName;
  const MuscleSelectedIntent(this.muscleId, {this.muscleName});
}
