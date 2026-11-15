import 'package:json_annotation/json_annotation.dart';

part 'meal_category_dto.g.dart';

@JsonSerializable()
class MealCategoryDto {
  @JsonKey(name: 'idCategory')
  final String? id;
  @JsonKey(name: 'strCategory')
  final String? name;
  @JsonKey(name: 'strCategoryThumb')
  final String? thumbnail;
  @JsonKey(name: 'strCategoryDescription')
  final String? description;

  const MealCategoryDto({this.id, this.name, this.thumbnail, this.description});

  factory MealCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$MealCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MealCategoryDtoToJson(this);
}
