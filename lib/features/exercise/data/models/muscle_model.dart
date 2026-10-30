
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muscle_model.g.dart';

@JsonSerializable()
class MuscleModel {
  @JsonKey(name: '_id')
  final String? id;

  final String? name;
  final String? image;

  const MuscleModel({
    this.id,
    this.name,
    this.image,
  });

  factory MuscleModel.fromJson(Map<String, dynamic> json) =>
      _$MuscleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleModelToJson(this);

  MuscleEntity toDomain() => MuscleEntity(
        id: id ?? '',
        name: name ?? '',
        image: image,
      );
}
