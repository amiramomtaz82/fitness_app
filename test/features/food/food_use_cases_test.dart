import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:fitness_app/features/food/domain/repo/food_repo.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_categories_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRepo extends Mock implements FoodRepo {}

void main() {
  late MockFoodRepo repo;

  setUp(() => repo = MockFoodRepo());

  group('GetMealCategoriesUseCase', () {
    test('delegates to the repo and returns its categories', () async {
      const response = SuccessResponse([
        MealCategoryEntity(
          id: '1',
          name: 'Beef',
          thumbnail: 'beef.png',
          description: 'Beef desc',
        ),
      ]);
      when(() => repo.getMealCategories()).thenAnswer((_) async => response);

      final result = await GetMealCategoriesUseCase(repo)();

      expect(result, response);
      verify(() => repo.getMealCategories()).called(1);
    });

    test('returns the error response from the repo as is', () async {
      final response = ErrorResponse<List<MealCategoryEntity>>(
        failure: const NetworkFailure(),
      );
      when(() => repo.getMealCategories()).thenAnswer((_) async => response);

      final result = await GetMealCategoriesUseCase(repo)();

      expect(result, response);
    });
  });

  group('GetMealsByCategoryUseCase', () {
    test('delegates to the repo with the given category', () async {
      const response = SuccessResponse([
        MealSummaryEntity(
          id: '52959',
          name: 'Baked salmon',
          thumbnail: 'a.jpg',
        ),
      ]);
      when(
        () => repo.getMealsByCategory(any()),
      ).thenAnswer((_) async => response);

      final result = await GetMealsByCategoryUseCase(repo)('Seafood');

      expect(result, response);
      verify(() => repo.getMealsByCategory('Seafood')).called(1);
    });

    test('returns the error response from the repo as is', () async {
      final response = ErrorResponse<List<MealSummaryEntity>>(
        failure: const NetworkFailure(),
      );
      when(
        () => repo.getMealsByCategory(any()),
      ).thenAnswer((_) async => response);

      final result = await GetMealsByCategoryUseCase(repo)('Seafood');

      expect(result, response);
    });
  });
}
