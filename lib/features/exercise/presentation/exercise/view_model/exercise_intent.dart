sealed class ExerciseDetailsIntent {
  const ExerciseDetailsIntent();
}

class LoadExerciseDetailsIntent extends ExerciseDetailsIntent {
  final String muscleId;
  final String? muscleName;

  const LoadExerciseDetailsIntent(this.muscleId, {this.muscleName});
}

class SelectDifficultyIntent extends ExerciseDetailsIntent {
  final String difficultyId;

  const SelectDifficultyIntent(this.difficultyId);
}

class LoadMoreExercisesIntent extends ExerciseDetailsIntent {
  const LoadMoreExercisesIntent();
}

class RetryExerciseDetailsIntent extends ExerciseDetailsIntent {
  const RetryExerciseDetailsIntent();
}

class RefreshExercisesIntent extends ExerciseDetailsIntent {
  const RefreshExercisesIntent();
}
