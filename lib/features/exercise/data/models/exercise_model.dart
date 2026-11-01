import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'exercise')
  final String? name;

  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;

  const ExerciseModel({this.id, this.name, this.difficultyLevel});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id ?? '',
      name: name ?? '',
      difficultyLevel: difficultyLevel,
    );
  }
}
