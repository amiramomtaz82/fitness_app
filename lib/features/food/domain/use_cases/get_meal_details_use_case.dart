import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/meal_details_entity.dart';
import '../repo/food_repo.dart';

@injectable
class GetMealDetailsUseCase {
  final FoodRepo foodRepo;

  const GetMealDetailsUseCase(this.foodRepo);

  Future<BaseResponse<MealDetailsEntity?>> call(String mealId) {
    return foodRepo.getMealDetails(mealId);
  }
}
