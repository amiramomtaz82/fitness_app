import '../models/meal_categories_response_dto.dart';
import '../models/meals_response_dto.dart';

abstract interface class FoodRemoteDataSource {
  Future<MealCategoriesResponseDto> getMealCategories();
  Future<MealsResponseDto> getMealsByCategory(String category);
}
