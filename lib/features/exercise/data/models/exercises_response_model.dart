import 'package:fitness_app/features/exercise/data/models/exercise_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercises_response_model.g.dart';

@JsonSerializable()
class ExercisesResponseModel {
  final String? message;
  final int? totalExercises;
  final int? totalPages;
  final int? currentPage;
  final List<ExerciseModel>? exercises;

  const ExercisesResponseModel({
    this.message,
    this.totalExercises,
    this.totalPages,
    this.currentPage,
    this.exercises,
  });

  factory ExercisesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExercisesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExercisesResponseModelToJson(this);
}
