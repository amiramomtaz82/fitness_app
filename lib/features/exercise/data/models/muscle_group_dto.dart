import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/muscle_group_entity.dart';

part 'muscle_group_dto.g.dart';

@JsonSerializable(createToJson: false)
class MuscleGroupDto {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const MuscleGroupDto({this.id, this.name});

  factory MuscleGroupDto.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupDtoFromJson(json);

  MuscleGroupEntity toEntity() => MuscleGroupEntity(
    id: id ?? '',
    name: name ?? '',
  );
}