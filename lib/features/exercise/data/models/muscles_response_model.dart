

import 'package:fitness_app/features/exercise/data/models/muscle_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muscles_response_model.g.dart';

@JsonSerializable()
class MusclesResponseModel {
  final String? message;
  final int? totalMuscles;
  final List<MuscleModel>? muscles;

  const MusclesResponseModel({
    this.message,
    this.totalMuscles,
    this.muscles,
  });

  factory MusclesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MusclesResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MusclesResponseModelToJson(this);
}
