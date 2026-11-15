import 'package:json_annotation/json_annotation.dart';

import 'meal_summary_dto.dart';

part 'meals_response_dto.g.dart';

@JsonSerializable()
class MealsResponseDto {
  final List<MealSummaryDto>? meals;

  const MealsResponseDto({this.meals});

  factory MealsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MealsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MealsResponseDtoToJson(this);
}
