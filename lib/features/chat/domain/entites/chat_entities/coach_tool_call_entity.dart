import 'package:equatable/equatable.dart';

/// Sealed class for all supported coach tools.
/// Using a sealed class allows exhaustive compile-time pattern matching with `switch`.
sealed class CoachToolCallEntity extends Equatable {
  final String toolCallId;
  final String toolName;

  const CoachToolCallEntity({
    required this.toolCallId,
    required this.toolName,
  });

  @override
  List<Object?> get props => [toolCallId, toolName];
}

class SearchExercisesToolCall extends CoachToolCallEntity {
  final String? muscleGroup;
  final String? equipment;
  final int? maxDifficulty;
  final int limit;

  const SearchExercisesToolCall({
    required super.toolCallId,
    super.toolName = 'search_exercises',
    this.muscleGroup,
    this.equipment,
    this.maxDifficulty,
    this.limit = 6,
  });

  @override
  List<Object?> get props => [
    toolCallId,
    toolName,
    muscleGroup,
    equipment,
    maxDifficulty,
    limit,
  ];
}

class SearchMealsToolCall extends CoachToolCallEntity {
  final String? category;
  final double? minProtein;
  final double? maxKcal;
  final int limit;

  const SearchMealsToolCall({
    required super.toolCallId,
    super.toolName = 'search_meals',
    this.category,
    this.minProtein,
    this.maxKcal,
    this.limit = 6,
  });

  @override
  List<Object?> get props => [
    toolCallId,
    toolName,
    category,
    minProtein,
    maxKcal,
    limit,
  ];
}