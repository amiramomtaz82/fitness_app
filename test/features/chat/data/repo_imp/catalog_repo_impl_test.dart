import 'package:fitness_app/features/chat/data/repo_imp/catalog_repo_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/chat/data/data_source/catalog_local_data_source.dart';
import 'package:fitness_app/features/chat/data/models/exercise_card_model.dart';
import 'package:fitness_app/features/chat/data/models/meal_card_model.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';

import 'catalog_repo_impl_test.mocks.dart';

@GenerateMocks([CatalogLocalDataSource])
void main() {
  late CatalogRepoImpl repository;
  late MockCatalogLocalDataSource mockLocalDataSource;

  final exerciseModel = ExerciseCardModel.fromJson({
    'id': '1',
    'name': 'Push Up',
    'name_ar': 'ضغط',
    'muscle_group': 'Chest',
    'difficulty': 'Beginner',
    'demo_url': 'https://example.com/demo',
  });

  final mealModel = MealCardModel.fromJson({
    'id': '1',
    'name': 'Chicken',
    'name_ar': 'فراخ',
    'kcal': 300.0,
    'protein_g': 30.0,
    'thumb': 'https://example.com/meal',
  });

  setUp(() {
    mockLocalDataSource = MockCatalogLocalDataSource();
    repository = CatalogRepoImpl(mockLocalDataSource);
  });

  group('getExercises', () {
    test('should return SuccessResponse when data source succeeds', () async {
      // Arrange
      when(
        mockLocalDataSource.getExercises(any),
      ).thenAnswer((_) async => [exerciseModel]);

      // Act
      final result = await repository.getExercises(
        const ExerciseFilterParams(),
      );

      // Assert
      expect(result, isA<SuccessResponse<List<ExerciseCardEntity>>>());

      final success = result as SuccessResponse<List<ExerciseCardEntity>>;

      expect(success.data, [exerciseModel.toDomain()]);

      verify(mockLocalDataSource.getExercises(any)).called(1);
    });

    test('should return ErrorResponse when data source throws', () async {
      // Arrange
      when(
        mockLocalDataSource.getExercises(any),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getExercises(
        const ExerciseFilterParams(),
      );

      // Assert
      expect(result, isA<ErrorResponse<List<ExerciseCardEntity>>>());
    });
  });

  group('getMeals', () {
    test('should return SuccessResponse when data source succeeds', () async {
      // Arrange
      when(
        mockLocalDataSource.getMeals(any),
      ).thenAnswer((_) async => [mealModel]);

      // Act
      final result = await repository.getMeals(const MealFilterParams());

      // Assert
      expect(result, isA<SuccessResponse<List<MealCardEntity>>>());

      final success = result as SuccessResponse<List<MealCardEntity>>;

      expect(success.data, [mealModel.toDomain()]);

      verify(mockLocalDataSource.getMeals(any)).called(1);
    });

    test('should return ErrorResponse when data source throws', () async {
      // Arrange
      when(
        mockLocalDataSource.getMeals(any),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getMeals(const MealFilterParams());

      // Assert
      expect(result, isA<ErrorResponse<List<MealCardEntity>>>());
    });
  });

  group('getExercisesByIds', () {
    const ids = ['1', '2'];

    test('should return SuccessResponse when data source succeeds', () async {
      // Arrange
      when(
        mockLocalDataSource.getExercisesByIds(ids),
      ).thenAnswer((_) async => [exerciseModel]);

      // Act
      final result = await repository.getExercisesByIds(ids);

      // Assert
      expect(result, isA<SuccessResponse<List<ExerciseCardEntity>>>());

      final success = result as SuccessResponse<List<ExerciseCardEntity>>;

      expect(success.data, [exerciseModel.toDomain()]);

      verify(mockLocalDataSource.getExercisesByIds(ids)).called(1);
    });

    test('should return ErrorResponse when data source throws', () async {
      // Arrange
      when(
        mockLocalDataSource.getExercisesByIds(ids),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getExercisesByIds(ids);

      // Assert
      expect(result, isA<ErrorResponse<List<ExerciseCardEntity>>>());
    });
  });

  group('getMealsByIds', () {
    const ids = ['1', '2'];

    test('should return SuccessResponse when data source succeeds', () async {
      // Arrange
      when(
        mockLocalDataSource.getMealsByIds(ids),
      ).thenAnswer((_) async => [mealModel]);

      // Act
      final result = await repository.getMealsByIds(ids);

      // Assert
      expect(result, isA<SuccessResponse<List<MealCardEntity>>>());

      final success = result as SuccessResponse<List<MealCardEntity>>;

      expect(success.data, [mealModel.toDomain()]);

      verify(mockLocalDataSource.getMealsByIds(ids)).called(1);
    });

    test('should return ErrorResponse when data source throws', () async {
      // Arrange
      when(
        mockLocalDataSource.getMealsByIds(ids),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getMealsByIds(ids);

      // Assert
      expect(result, isA<ErrorResponse<List<MealCardEntity>>>());
    });
  });
}
