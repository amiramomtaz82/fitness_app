import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'difficulty_level_model.dart';

part 'difficulty_levels_response_model.g.dart';

@JsonSerializable()
class DifficultyLevelsResponseModel {
  final String? message;
  final int? totalLevels;

  @JsonKey(name: 'difficulty_levels')
  final List<DifficultyLevelModel>? difficultyLevels;

  const DifficultyLevelsResponseModel({
    this.message,
    this.totalLevels,
    this.difficultyLevels,
  });

  factory DifficultyLevelsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['difficulty_levels'] ?? json['levels'];
    final parsed = (rawList as List<dynamic>?)
        ?.map(
          (level) =>
              DifficultyLevelModel.fromJson(level as Map<String, dynamic>),
        )
        .toList();
    return DifficultyLevelsResponseModel(
      message: json['message'] as String?,
      totalLevels: (json['totalLevels'] as num?)?.toInt() ?? parsed?.length,
      difficultyLevels: parsed,
    );
  }

  Map<String, dynamic> toJson() => _$DifficultyLevelsResponseModelToJson(this);

  List<DifficultyLevelEntity> toEntities() {
    return difficultyLevels
            ?.map(
              (level) => DifficultyLevelEntity(
                id: level.id ?? '',
                name: level.name ?? '',
              ),
            )
            .toList() ??
        [];
  }
}
