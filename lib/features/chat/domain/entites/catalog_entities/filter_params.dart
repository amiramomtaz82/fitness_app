import 'package:equatable/equatable.dart';

class ExerciseFilterParams extends Equatable {
  final String? muscleGroup;
  final String? equipment;
  final int? maxDifficulty;
  final int limit;
  const ExerciseFilterParams({
    this.muscleGroup,
    this.equipment,
    this.maxDifficulty,
    this.limit = 6,
  });
  @override
  List<Object?> get props => [muscleGroup, equipment, maxDifficulty, limit];
}

class MealFilterParams extends Equatable {
  final String? category;
  final double? minProtein;
  final double? maxKcal;
  final int limit;
  const MealFilterParams({
    this.category,
    this.minProtein,
    this.maxKcal,
    this.limit = 6,
  });
  @override
  List<Object?> get props => [category, minProtein, maxKcal, limit];
}
