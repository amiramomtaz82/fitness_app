import '../../../../core/base_response/base_response.dart';
import '../entities/meal_category_entity.dart';

abstract interface class FoodRepo {
  Future<BaseResponse<List<MealCategoryEntity>>> getMealCategories();
}
