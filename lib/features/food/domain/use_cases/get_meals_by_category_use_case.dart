import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/meal_summary_entity.dart';
import '../repo/food_repo.dart';

@injectable
class GetMealsByCategoryUseCase {
  final FoodRepo _foodRepo;

  const GetMealsByCategoryUseCase(this._foodRepo);

  Future<BaseResponse<List<MealSummaryEntity>>> call(String category) {
    return _foodRepo.getMealsByCategory(category);
  }
}
