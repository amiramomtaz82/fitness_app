import 'dart:async';

import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_categories_use_case.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view_model/food_browse_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view_model/food_browse_intent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMealCategoriesUseCase extends Mock
    implements GetMealCategoriesUseCase {}

class MockGetMealsByCategoryUseCase extends Mock
    implements GetMealsByCategoryUseCase {}

const seafood = MealCategoryEntity(
  id: '1',
  name: 'Seafood',
  thumbnail: 'seafood.png',
  description: 'Fish',
);

const beef = MealCategoryEntity(
  id: '2',
  name: 'Beef',
  thumbnail: 'beef.png',
  description: 'Meat',
);

const salmon = MealSummaryEntity(
  id: '52959',
  name: 'Baked salmon',
  thumbnail: 'salmon.jpg',
);

const stew = MealSummaryEntity(id: '52874', name: 'Beef stew', thumbnail: '');

void main() {
  late MockGetMealCategoriesUseCase categories;
  late MockGetMealsByCategoryUseCase meals;
  late FoodBrowseCubit cubit;

  setUp(() {
    categories = MockGetMealCategoriesUseCase();
    meals = MockGetMealsByCategoryUseCase();
    cubit = FoodBrowseCubit(categories, meals);
  });

  tearDown(() => cubit.close());

  test('loads the first category meals after categories succeed', () async {
    when(() => categories.call()).thenAnswer((_) async {
      return const SuccessResponse([seafood, beef]);
    });
    when(() => meals.call('Seafood')).thenAnswer((_) async {
      return const SuccessResponse([salmon]);
    });

    cubit.doIntent(const LoadFoodBrowseIntent());
    await cubit.stream.firstWhere((state) => state.meals.isSuccess);

    expect(cubit.state.selectedCategory, 'Seafood');
    expect(cubit.state.meals.data, [salmon]);
    verify(() => meals.call('Seafood')).called(1);
  });

  test('does not request meals when no category has a name', () async {
    when(() => categories.call()).thenAnswer((_) async {
      return const SuccessResponse([
        MealCategoryEntity(id: '', name: ' ', thumbnail: '', description: ''),
      ]);
    });

    cubit.doIntent(const LoadFoodBrowseIntent());
    await cubit.stream.firstWhere((state) => state.categories.isSuccess);

    expect(cubit.state.meals.isInitial, isTrue);
    verifyNever(() => meals.call(any()));
  });

  test('keeps a category failure off the meals list', () async {
    when(() => categories.call()).thenAnswer((_) async {
      return ErrorResponse(
        failure: const NetworkFailure(serverMessage: 'offline'),
      );
    });

    cubit.doIntent(const LoadFoodBrowseIntent());
    await cubit.stream.firstWhere((state) => state.categories.isError);

    expect(cubit.state.categories.failure?.serverMessage, 'offline');
    expect(cubit.state.meals.isInitial, isTrue);
  });

  test('passes the selected category name to the meals use case', () async {
    when(() => meals.call('Beef')).thenAnswer((_) async {
      return const SuccessResponse([stew]);
    });

    cubit.doIntent(const SelectFoodCategoryIntent('Beef'));
    await cubit.stream.firstWhere((state) => state.meals.isSuccess);

    expect(cubit.state.selectedCategory, 'Beef');
    expect(cubit.state.meals.data, [stew]);
  });

  test('ignores a meals response from an older category', () async {
    final older = Completer<BaseResponse<List<MealSummaryEntity>>>();
    when(() => meals.call('Seafood')).thenAnswer((_) => older.future);
    when(() => meals.call('Beef')).thenAnswer((_) async {
      return const SuccessResponse([stew]);
    });

    cubit.doIntent(const SelectFoodCategoryIntent('Seafood'));
    cubit.doIntent(const SelectFoodCategoryIntent('Beef'));
    await cubit.stream.firstWhere((state) => state.meals.isSuccess);
    older.complete(const SuccessResponse([salmon]));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.selectedCategory, 'Beef');
    expect(cubit.state.meals.data, [stew]);
  });
}
