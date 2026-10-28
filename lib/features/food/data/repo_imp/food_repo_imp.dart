import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../domain/entities/meal_category_entity.dart';
import '../../domain/repo/food_repo.dart';
import '../data_source/food_remote_data_source.dart';
import '../mapper/meal_category_mapper.dart';

@Injectable(as: FoodRepo)
class FoodRepoImp implements FoodRepo {
  final FoodRemoteDataSource _remoteDataSource;

  const FoodRepoImp(this._remoteDataSource);

  @override
  Future<BaseResponse<List<MealCategoryEntity>>> getMealCategories() {
    return safeCall(() async {
      final response = await _remoteDataSource.getMealCategories();
      return response.toEntities();
    });
  }
}
