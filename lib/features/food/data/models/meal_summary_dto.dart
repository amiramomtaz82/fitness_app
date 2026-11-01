import 'package:json_annotation/json_annotation.dart';

part 'meal_summary_dto.g.dart';

@JsonSerializable()
class MealSummaryDto {
  @JsonKey(name: 'idMeal')
  final String? id;
  @JsonKey(name: 'strMeal')
  final String? name;
  @JsonKey(name: 'strMealThumb')
  final String? thumbnail;

  const MealSummaryDto({this.id, this.name, this.thumbnail});

  factory MealSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MealSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MealSummaryDtoToJson(this);
}
