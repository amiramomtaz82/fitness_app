import 'package:injectable/injectable.dart';

import '../api/food_api_client.dart';
import '../models/meal_categories_response_dto.dart';
import '../models/meal_details_dto.dart';
import '../models/meals_response_dto.dart';
import 'food_remote_data_source.dart';

@Injectable(as: FoodRemoteDataSource)
class FoodRemoteDataSourceImp implements FoodRemoteDataSource {
  final FoodApiClient _client;

  const FoodRemoteDataSourceImp(this._client);

  @override
  Future<MealCategoriesResponseDto> getMealCategories() {
    return _client.getMealCategories();
  }

  @override
  Future<MealsResponseDto> getMealsByCategory(String category) {
    return _client.getMealsByCategory(category);
  }

  @override
  Future<MealLookupDto> lookupMeal(String mealId) {
    return _client.lookupMeal(mealId);
  }
}
