import '../../domain/entities/meal_category_entity.dart';
import '../models/meal_categories_response_dto.dart';
import '../models/meal_category_dto.dart';

extension MealCategoryDtoMapper on MealCategoryDto {
  MealCategoryEntity toEntity() {
    return MealCategoryEntity(
      id: id ?? '',
      name: name?.trim() ?? '',
      thumbnail: thumbnail ?? '',
      description: description?.trim() ?? '',
    );
  }
}

extension MealCategoriesResponseDtoMapper on MealCategoriesResponseDto {
  List<MealCategoryEntity> toEntities() {
    return (categories ?? const [])
        .where((dto) => dto.id?.isNotEmpty ?? false)
        .map((dto) => dto.toEntity())
        .toList();
  }
}
