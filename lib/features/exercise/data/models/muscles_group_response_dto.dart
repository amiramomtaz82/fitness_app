import 'package:json_annotation/json_annotation.dart';
import 'muscle_group_dto.dart';

part 'muscles_group_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class MusclesGroupResponseDto {
  final String? message;
  final List<MuscleGroupDto>? musclesGroup;

  const MusclesGroupResponseDto({this.message, this.musclesGroup});

  factory MusclesGroupResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MusclesGroupResponseDtoFromJson(json);
}
