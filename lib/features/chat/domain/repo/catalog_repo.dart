import '../../../../core/base_response/base_response.dart';
import '../entites/catalog_entities/exercise_card_entity.dart';
import '../entites/catalog_entities/filter_params.dart';
import '../entites/catalog_entities/meal_card_entity.dart';

abstract interface class CatalogRepo {
  Future<BaseResponse<List<ExerciseCardEntity>>> getExercises(
    ExerciseFilterParams params,
  );
  Future<BaseResponse<List<MealCardEntity>>> getMeals(MealFilterParams params);
  Future<BaseResponse<List<ExerciseCardEntity>>> getExercisesByIds(
    List<String> ids,
  );
  Future<BaseResponse<List<MealCardEntity>>> getMealsByIds(List<String> ids);
}
