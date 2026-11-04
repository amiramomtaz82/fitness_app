import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'package:fitness_app/core/constants/catalog_db_constants.dart';
import 'package:fitness_app/core/local/local_database_service.dart';
import 'package:fitness_app/features/chat/data/data_source/catalog_local_data_source_impl.dart';

import 'catalog_local_data_source_impl_test.mocks.dart';

@GenerateMocks([LocalDatabaseService, Database])
void main() {
  late CatalogLocalDataSourceImpl dataSource;
  late MockLocalDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;

  final exerciseRow = <String, Object?>{
    'id': '1',
    'name': 'Push Up',
    'name_ar': 'ضغط',
    'muscle_group': 'Chest',
    'difficulty': 'Beginner',
    'demo_url': 'https://example.com/demo',
  };

  final mealRow = <String, Object?>{
    'id': '1',
    'name': 'Chicken',
    'name_ar': 'فراخ',
    'kcal': 300.0,
    'protein_g': 30.0,
    'thumb': 'https://example.com/meal',
  };

  setUp(() {
    mockDatabaseService = MockLocalDatabaseService();
    mockDatabase = MockDatabase();

    dataSource = CatalogLocalDataSourceImpl(mockDatabaseService);

    when(
      mockDatabaseService.openLocalDatabase(CatalogDbConstants.exercisesDb),
    ).thenAnswer((_) async => mockDatabase);

    when(
      mockDatabaseService.openLocalDatabase(CatalogDbConstants.mealsDb),
    ).thenAnswer((_) async => mockDatabase);
  });

  group('getExercises', () {
    test('should return exercises when query succeeds', () async {
      // Arrange
      when(
        mockDatabase.rawQuery(any, any),
      ).thenAnswer((_) async => [exerciseRow]);

      // Act
      final result = await dataSource.getExercises(ExerciseFilterParams());

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, '1');
      expect(result.first.name, 'Push Up');

      verify(
        mockDatabaseService.openLocalDatabase(CatalogDbConstants.exercisesDb),
      ).called(1);
    });

    test('should return empty list when no exercises found', () async {
      // Arrange
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

      // Act
      final result = await dataSource.getExercises(ExerciseFilterParams());

      // Assert
      expect(result, isEmpty);
    });

    test('should throw exception when database query fails', () async {
      // Arrange
      when(
        mockDatabase.rawQuery(any, any),
      ).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => dataSource.getExercises(ExerciseFilterParams()),
        throwsException,
      );
    });
  });

  group('getExercisesByIds', () {
    const ids = ['1', '2'];

    test('should return exercises matching given ids', () async {
      // Arrange
      when(
        mockDatabase.rawQuery(any, any),
      ).thenAnswer((_) async => [exerciseRow]);

      // Act
      final result = await dataSource.getExercisesByIds(ids);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, '1');

      verify(
        mockDatabaseService.openLocalDatabase(CatalogDbConstants.exercisesDb),
      ).called(1);
    });

    test('should return empty list when ids are empty', () async {
      // Act
      final result = await dataSource.getExercisesByIds([]);

      // Assert
      expect(result, isEmpty);

      verifyNever(mockDatabaseService.openLocalDatabase(any));
    });
  });

  group('getMeals', () {
    test('should return meals when query succeeds', () async {
      // Arrange
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [mealRow]);

      // Act
      final result = await dataSource.getMeals(MealFilterParams());

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, '1');
      expect(result.first.name, 'Chicken');

      verify(
        mockDatabaseService.openLocalDatabase(CatalogDbConstants.mealsDb),
      ).called(1);
    });

    test('should return empty list when no meals found', () async {
      // Arrange
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

      // Act
      final result = await dataSource.getMeals(MealFilterParams());

      // Assert
      expect(result, isEmpty);
    });

    test('should throw exception when database query fails', () async {
      // Arrange
      when(
        mockDatabase.rawQuery(any, any),
      ).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => dataSource.getMeals(MealFilterParams()), throwsException);
    });
  });

  group('getMealsByIds', () {
    const ids = ['1', '2'];

    test('should return meals matching given ids', () async {
      // Arrange
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [mealRow]);

      // Act
      final result = await dataSource.getMealsByIds(ids);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, '1');

      verify(
        mockDatabaseService.openLocalDatabase(CatalogDbConstants.mealsDb),
      ).called(1);
    });

    test('should return empty list when ids are empty', () async {
      // Act
      final result = await dataSource.getMealsByIds([]);

      // Assert
      expect(result, isEmpty);

      verifyNever(mockDatabaseService.openLocalDatabase(any));
    });
  });
}
