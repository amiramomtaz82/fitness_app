import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/chat/data/data_source/catalog_local_data_source.dart';
import 'package:fitness_app/features/chat/domain/repo/catalog_repo.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:injectable/injectable.dart';


@Injectable(as: CatalogRepo)
class CatalogRepoImpl implements CatalogRepo {
  final CatalogLocalDataSource _localDataSource;

  const CatalogRepoImpl(this._localDataSource);

  @override
  Future<BaseResponse<List<ExerciseCardEntity>>> getExercises(
    ExerciseFilterParams params,
  ) async {
    return safeCall(() async {
      final models = await _localDataSource.getExercises(params);

      return models.map((model) => model.toDomain()).toList();
    });
  }

  @override
  Future<BaseResponse<List<MealCardEntity>>> getMeals(
    MealFilterParams params,
  ) async {
    return safeCall(() async {
      final models = await _localDataSource.getMeals(params);

      return models.map((model) => model.toDomain()).toList();
    });
  }

  @override
  Future<BaseResponse<List<ExerciseCardEntity>>> getExercisesByIds(
    List<String> ids,
  ) async {
    return safeCall(() async {
      final models = await _localDataSource.getExercisesByIds(ids);

      return models.map((model) => model.toDomain()).toList();
    });
  }

  @override
  Future<BaseResponse<List<MealCardEntity>>> getMealsByIds(
    List<String> ids,
  ) async {
    return safeCall(() async {
      final models = await _localDataSource.getMealsByIds(ids);

      return models.map((model) => model.toDomain()).toList();
    });
  }
}
