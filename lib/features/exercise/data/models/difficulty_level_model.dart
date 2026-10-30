import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'difficulty_level_model.g.dart';

@JsonSerializable()
class DifficultyLevelModel {
  @JsonKey(name: '_id')
  final String? id;

  final String? name;

  const DifficultyLevelModel({this.id, this.name});

  factory DifficultyLevelModel.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$DifficultyLevelModelToJson(this);

  DifficultyLevelEntity toDomain() {
    return DifficultyLevelEntity(id: id ?? '', name: name ?? '');
  }
}
