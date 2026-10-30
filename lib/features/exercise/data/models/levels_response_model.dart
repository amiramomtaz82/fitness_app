import 'package:fitness_app/features/exercise/data/models/difficulty_level_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'levels_response_model.g.dart';

@JsonSerializable()
class LevelsResponseModel {
  final String? message;

  final List<DifficultyLevelModel>? levels;

  const LevelsResponseModel({this.message, this.levels});

  factory LevelsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LevelsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LevelsResponseModelToJson(this);
}
