import 'package:json_annotation/json_annotation.dart';
import 'muscle_dto.dart';
import 'muscle_group_dto.dart';

part 'muscle_group_detail_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class MuscleGroupDetailResponseDto {
  final String? message;
  final MuscleGroupDto? muscleGroup;
  final List<MuscleDto>? muscles;

  const MuscleGroupDetailResponseDto({
    this.message,
    this.muscleGroup,
    this.muscles,
  });

  factory MuscleGroupDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupDetailResponseDtoFromJson(json);
}