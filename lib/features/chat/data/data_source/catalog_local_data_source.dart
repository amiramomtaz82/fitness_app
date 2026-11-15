import 'package:fitness_app/features/chat/data/models/exercise_card_model.dart';
import 'package:fitness_app/features/chat/data/models/meal_card_model.dart';

import '../../domain/entites/catalog_entities/filter_params.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<ExerciseCardModel>> getExercises(ExerciseFilterParams params);

  Future<List<MealCardModel>> getMeals(MealFilterParams params);

  Future<List<ExerciseCardModel>> getExercisesByIds(List<String> ids);

  Future<List<MealCardModel>> getMealsByIds(List<String> ids);
}
