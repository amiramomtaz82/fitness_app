import 'package:fitness_app/features/exercise/data/models/muscle_group_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muscle_group_response.g.dart';

@JsonSerializable(createToJson: false)
class MusclesGroupResponse {
  final String? message;
  final List<MuscleGroupModel>? musclesGroup;

  const MusclesGroupResponse({this.message, this.musclesGroup});

  factory MusclesGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$MusclesGroupResponseFromJson(json);
}
