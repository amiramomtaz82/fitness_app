import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'difficulty_level_model.g.dart';

@JsonSerializable()
class DifficultyLevelModel {
  @JsonKey(name: '_id')
  final String? id;

  final String? name;

  const DifficultyLevelModel({this.id, this.name});

  factory DifficultyLevelModel.fromJson(Map<String, dynamic> json) {
    return DifficultyLevelModel(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$DifficultyLevelModelToJson(this);

  DifficultyLevelEntity toDomain() {
    return DifficultyLevelEntity(id: id ?? '', name: name ?? '');
  }

  /// Backwards-compatible alias for the entity mapper.
  DifficultyLevelEntity toEntity() => toDomain();
}
