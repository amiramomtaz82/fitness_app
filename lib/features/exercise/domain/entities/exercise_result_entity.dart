import 'package:equatable/equatable.dart';

import 'exercise_entity.dart';

class ExercisesResultEntity extends Equatable {
  final int totalExercises;
  final int totalPages;
  final int currentPage;
  final List<ExerciseEntity> exercises;

  const ExercisesResultEntity({
    required this.totalExercises,
    required this.totalPages,
    required this.currentPage,
    required this.exercises,
  });
  @override
  List<Object> get props => [
    totalExercises,
    totalPages,
    currentPage,
    exercises,
  ];
}
