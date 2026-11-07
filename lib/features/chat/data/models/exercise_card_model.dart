import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_card_model.g.dart';

@JsonSerializable()
class ExerciseCardModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'name_ar')
  final String? nameAr;

  @JsonKey(name: 'muscle_group')
  final String? muscleGroup;

  @JsonKey(name: 'difficulty')
  final String? difficulty;

  @JsonKey(name: 'demo_url')
  final String? demoUrl;

  const ExerciseCardModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.muscleGroup,
    this.difficulty,
    this.demoUrl,
  });

  factory ExerciseCardModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseCardModelToJson(this);

  ExerciseCardEntity toDomain() {
    return ExerciseCardEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      muscleGroup: muscleGroup,
      difficulty: difficulty,
      demoUrl: demoUrl,
    );
  }
}
