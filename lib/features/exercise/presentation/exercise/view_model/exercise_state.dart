import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';

class ExerciseDetailsState extends Equatable {
  final Resource<List<DifficultyLevelEntity>> difficultyLevels;

  final Resource<ExercisesResultEntity> exercises;

  final String? selectedDifficultyId;

  const ExerciseDetailsState({
    this.difficultyLevels = const Resource.initial(),
    this.exercises = const Resource.initial(),
    this.selectedDifficultyId,
  });

  List<DifficultyLevelEntity> get difficultyLevelsList =>
      difficultyLevels.data ?? [];

  List<ExerciseEntity> get exercisesList => exercises.data?.exercises ?? [];

  int get currentPage => exercises.data?.currentPage ?? 1;

  int get totalPages => exercises.data?.totalPages ?? 1;

  int get totalExercises => exercises.data?.totalExercises ?? 0;

  bool get hasMorePages => currentPage < totalPages;

  DifficultyLevelEntity? get selectedDifficulty {
    for (final level in difficultyLevelsList) {
      if (level.id == selectedDifficultyId) {
        return level;
      }
    }
    return null;
  }

  ExerciseDetailsState copyWith({
    Resource<List<DifficultyLevelEntity>>? difficultyLevels,
    Resource<ExercisesResultEntity>? exercises,
    String? selectedDifficultyId,
  }) {
    return ExerciseDetailsState(
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      exercises: exercises ?? this.exercises,
      selectedDifficultyId: selectedDifficultyId ?? this.selectedDifficultyId,
    );
  }

  @override
  List<Object?> get props => [
    difficultyLevels,
    exercises,
    selectedDifficultyId,
  ];
}
