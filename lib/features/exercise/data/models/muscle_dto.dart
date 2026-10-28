import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/muscle_entity.dart';

part 'muscle_dto.g.dart';

@JsonSerializable(createToJson: false)
class MuscleDto {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? image;

  const MuscleDto({this.id, this.name, this.image});

  factory MuscleDto.fromJson(Map<String, dynamic> json) =>
      _$MuscleDtoFromJson(json);

  MuscleEntity toEntity() => MuscleEntity(
    id: id ?? '',
    name: name ?? '',
    imageUrl: image ?? '',
  );
}