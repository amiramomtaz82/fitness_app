import 'package:fitness_app/features/chat/data/local/exercises_database.dart';
import 'package:fitness_app/features/chat/data/local/meals_database.dart';
import 'package:fitness_app/features/chat/data/models/exercise_card_model.dart';
import 'package:fitness_app/features/chat/data/models/meal_card_model.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:injectable/injectable.dart';

import 'catalog_local_data_source.dart';

@Injectable(as: CatalogLocalDataSource)
class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  final ExercisesDatabase _exercisesDatabase;
  final MealsDatabase _mealsDatabase;

  const CatalogLocalDataSourceImpl(
    this._exercisesDatabase,
    this._mealsDatabase,
  );

  Future<List<ExerciseCardModel>> _queryExercises(
    String where,
    List<Object?> arguments,
  ) async {
    final database = await _exercisesDatabase.instance;

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
    final conditions = <String>[];
    final arguments = <Object?>[];

    if (params.muscleGroup != null) {
      conditions.add('(mg.name = ? OR mg.name_ar = ?)');
      arguments.addAll([params.muscleGroup, params.muscleGroup]);
    }

    if (params.equipment != null) {
      conditions.add('''(
        e.primary_equipment_id IN (
          SELECT id FROM equipment WHERE name = ? OR name_ar = ?
        )
        OR e.secondary_equipment_id IN (
          SELECT id FROM equipment WHERE name = ? OR name_ar = ?
        )
      )''');
      arguments.addAll([
        params.equipment,
        params.equipment,
        params.equipment,
        params.equipment,
      ]);
    }

    if (params.maxDifficulty != null) {
      conditions.add('e.difficulty_rank <= ?');
      arguments.add(params.maxDifficulty);
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    return _queryExercises(
      '''
      $where
      ORDER BY e.popularity DESC
      LIMIT ?
      ''',
      [...arguments, params.limit],
    );
  }

  @override
  Future<List<ExerciseCardModel>> getExercisesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(',');

    return _queryExercises('WHERE e.id IN ($placeholders)', ids);
  }

  @override
  Future<List<MealCardModel>> getMeals(MealFilterParams params) async {
    final database = await _mealsDatabase.instance;

    final conditions = <String>[];
    final arguments = <Object?>[];

    if (params.category != null) {
      conditions.add('(mc.name = ? OR mc.name_ar = ?)');
      arguments.addAll([params.category, params.category]);
    }

    if (params.minProtein != null) {
      conditions.add('m.protein_g >= ?');
      arguments.add(params.minProtein);
    }

    if (params.maxKcal != null) {
      conditions.add('m.kcal <= ?');
      arguments.add(params.maxKcal);
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

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
      $where
      ORDER BY m.popularity DESC
      LIMIT ?
      ''',
      [...arguments, params.limit],
    );

    return result.map(MealCardModel.fromJson).toList();
  }

  @override
  Future<List<MealCardModel>> getMealsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final database = await _mealsDatabase.instance;

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
