import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/meal_category_entity.dart';
import '../repo/food_repo.dart';

@injectable
class GetMealCategoriesUseCase {
  final FoodRepo _foodRepo;

  const GetMealCategoriesUseCase(this._foodRepo);

  Future<BaseResponse<List<MealCategoryEntity>>> call() {
    return _foodRepo.getMealCategories();
  }
}
