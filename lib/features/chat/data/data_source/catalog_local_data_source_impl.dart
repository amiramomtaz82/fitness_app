import 'package:fitness_app/core/constants/catalog_db_constants.dart';
import 'package:fitness_app/core/local/local_database_service.dart';
import 'package:fitness_app/features/chat/data/models/exercise_card_model.dart';
import 'package:fitness_app/features/chat/data/models/meal_card_model.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:injectable/injectable.dart';

import 'catalog_local_data_source.dart';

@Injectable(as: CatalogLocalDataSource)
class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  final LocalDatabaseService _databaseService;

  const CatalogLocalDataSourceImpl(this._databaseService);

  Future<List<ExerciseCardModel>> _queryExercises(
    String where,
    List<Object?> arguments,
  ) async {
    final database = await _databaseService.openLocalDatabase(
      CatalogDbConstants.exercisesDb,
    );

    final result = await database.rawQuery('''
      SELECT
        e.id,
        e.name,
        e.name_ar,
        mg.name AS muscle_group,
        dl.name AS difficulty,
        e.demo_url
      FROM exercise e
      LEFT JOIN muscle_group mg
        ON e.muscle_group_id = mg.id
      LEFT JOIN difficulty_level dl
        ON e.difficulty_id = dl.id
      $where
      ''', arguments);

    return result.map(ExerciseCardModel.fromJson).toList();
  }

  @override
  Future<List<ExerciseCardModel>> getExercises(
    ExerciseFilterParams params,
  ) async {
    final result = await _queryExercises(
      '''
      WHERE (? IS NULL OR mg.name = ? OR mg.name_ar = ?)
        AND (
          ? IS NULL
          OR e.primary_equipment_id IN (
            SELECT id FROM equipment WHERE name = ? OR name_ar = ?
          )
          OR e.secondary_equipment_id IN (
            SELECT id FROM equipment WHERE name = ? OR name_ar = ?
          )
        )
        AND (? IS NULL OR e.difficulty_rank <= ?)
      ORDER BY e.popularity DESC
      LIMIT ?
      ''',
      [
        params.muscleGroup,
        params.muscleGroup,
        params.muscleGroup,
        params.equipment,
        params.equipment,
        params.equipment,
        params.equipment,
        params.equipment,
        params.maxDifficulty,
        params.maxDifficulty,
        params.limit,
      ],
    );

    return result;
  }

  @override
  Future<List<ExerciseCardModel>> getExercisesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(',');

    return _queryExercises('WHERE e.id IN ($placeholders)', ids);
  }

  @override
  Future<List<MealCardModel>> getMeals(MealFilterParams params) async {
    final database = await _databaseService.openLocalDatabase(
      CatalogDbConstants.mealsDb,
    );

    final result = await database.rawQuery(
      '''
      SELECT
        m.id,
        m.name,
        m.name_ar,
        m.kcal,
        m.protein_g,
        m.thumb
      FROM meal m
      LEFT JOIN meal_category mc
        ON m.category_id = mc.id
      WHERE (? IS NULL OR mc.name = ? OR mc.name_ar = ?)
        AND (? IS NULL OR m.protein_g >= ?)
        AND (? IS NULL OR m.kcal <= ?)
      ORDER BY m.popularity DESC
      LIMIT ?
      ''',
      [
        params.category,
        params.category,
        params.category,
        params.minProtein,
        params.minProtein,
        params.maxKcal,
        params.maxKcal,
        params.limit,
      ],
    );

    return result.map(MealCardModel.fromJson).toList();
  }

  @override
  Future<List<MealCardModel>> getMealsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final database = await _databaseService.openLocalDatabase(
      CatalogDbConstants.mealsDb,
    );

    final placeholders = List.filled(ids.length, '?').join(',');

    final result = await database.rawQuery('''
      SELECT
        id,
        name,
        name_ar,
        kcal,
        protein_g,
        thumb
      FROM meal
      WHERE id IN ($placeholders)
      ''', ids);

    return result.map(MealCardModel.fromJson).toList();
  }
}
