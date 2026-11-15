import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muscle_group_model.g.dart';

@JsonSerializable(createToJson: false)
class MuscleGroupModel {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const MuscleGroupModel({this.id, this.name});

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupModelFromJson(json);

  MuscleGroupEntity toEntity() =>
      MuscleGroupEntity(id: id ?? '', name: name ?? '');
}