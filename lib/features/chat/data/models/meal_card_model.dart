import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:json_annotation/json_annotation.dart';


part 'meal_card_model.g.dart';

@JsonSerializable()
class MealCardModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'name_ar')
  final String? nameAr;

  @JsonKey(name: 'kcal')
  final double? kcal;

  @JsonKey(name: 'protein_g')
  final double? proteinG;

  @JsonKey(name: 'thumb')
  final String? thumb;

  const MealCardModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.kcal,
    this.proteinG,
    this.thumb,
  });

  factory MealCardModel.fromJson(Map<String, dynamic> json) =>
      _$MealCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealCardModelToJson(this);

  MealCardEntity toDomain() {
    return MealCardEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      kcal: kcal,
      proteinG: proteinG,
      thumb: thumb,
    );
  }
}
