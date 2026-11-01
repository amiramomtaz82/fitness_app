import '../../domain/entities/meal_summary_entity.dart';
import '../models/meal_summary_dto.dart';
import '../models/meals_response_dto.dart';

extension MealSummaryDtoMapper on MealSummaryDto {
  MealSummaryEntity toEntity() {
    return MealSummaryEntity(
      id: id ?? '',
      name: name?.trim() ?? '',
      thumbnail: thumbnail ?? '',
    );
  }
}

extension MealsResponseDtoMapper on MealsResponseDto {
  List<MealSummaryEntity> toEntities() {
    return (meals ?? const [])
        .where((dto) => dto.id?.isNotEmpty ?? false)
        .map((dto) => dto.toEntity())
        .toList();
  }
}
