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
// workout_intent.dart
class MuscleSelectedIntent extends WorkoutIntent {
  final String muscleId;
  const MuscleSelectedIntent(this.muscleId);
}