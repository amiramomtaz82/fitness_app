import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/meal_categories_response_dto.dart';

part 'food_api_client.g.dart';

@RestApi(baseUrl: Endpoints.mealDbBaseUrl)
abstract class FoodApiClient {
  factory FoodApiClient(Dio dio, {String baseUrl}) = _FoodApiClient;

  @GET(Endpoints.mealCategories)
  Future<MealCategoriesResponseDto> getMealCategories();
}
