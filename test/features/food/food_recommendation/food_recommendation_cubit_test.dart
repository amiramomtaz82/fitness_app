import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_categories_use_case.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_intent.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMealCategoriesUseCase extends Mock
    implements GetMealCategoriesUseCase {}

class MockGetMealsByCategoryUseCase extends Mock
    implements GetMealsByCategoryUseCase {}

const _categories = [
  MealCategoryEntity(
    id: '1',
    name: 'Beef',
    thumbnail: 'beef.png',
    description: '',
  ),
  MealCategoryEntity(
    id: '2',
    name: 'Chicken',
    thumbnail: 'chicken.png',
    description: '',
  ),
];

const _beefMeals = [
  MealSummaryEntity(id: '52874', name: 'Beef Stew', thumbnail: 'stew.jpg'),
];

const _chickenMeals = [
  MealSummaryEntity(id: '52795', name: 'Chicken Curry', thumbnail: 'cur.jpg'),
];

const _loaded = FoodRecommendationState(
  categories: Resource.success(_categories),
  meals: Resource.success(_beefMeals),
);

void main() {
  late MockGetMealCategoriesUseCase mockCategoriesUseCase;
  late MockGetMealsByCategoryUseCase mockMealsUseCase;
  late FoodRecommendationCubit cubit;

  void givenCategories(BaseResponse<List<MealCategoryEntity>> response) {
    when(() => mockCategoriesUseCase()).thenAnswer((_) async => response);
  }

  void givenMeals(
    String category,
    BaseResponse<List<MealSummaryEntity>> response,
  ) {
    when(() => mockMealsUseCase(category)).thenAnswer((_) async => response);
  }

  setUp(() {
    mockCategoriesUseCase = MockGetMealCategoriesUseCase();
    mockMealsUseCase = MockGetMealsByCategoryUseCase();
    cubit = FoodRecommendationCubit(mockCategoriesUseCase, mockMealsUseCase);
  });

  tearDown(() => cubit.close());

  group('FoodRecommendationCubit —', () {
    test('initial state is correct', () {
      expect(cubit.state, const FoodRecommendationState());
    });

    group('LoadFoodRecommendationIntent', () {
      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'loads categories then the meals of the first category',
        build: () {
          givenCategories(const SuccessResponse(_categories));
          givenMeals('Beef', const SuccessResponse(_beefMeals));
          return cubit;
        },
        act: (c) => c.doIntent(const LoadFoodRecommendationIntent()),
        expect: () => [
          const FoodRecommendationState(categories: Resource.loading()),
          const FoodRecommendationState(
            categories: Resource.success(_categories),
          ),
          const FoodRecommendationState(
            categories: Resource.success(_categories),
            meals: Resource.loading(),
          ),
          _loaded,
        ],
        verify: (_) => verify(() => mockMealsUseCase('Beef')).called(1),
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'emits error and skips meals when categories fail',
        build: () {
          givenCategories(ErrorResponse(failure: const NetworkFailure()));
          return cubit;
        },
        act: (c) => c.doIntent(const LoadFoodRecommendationIntent()),
        expect: () => [
          const FoodRecommendationState(categories: Resource.loading()),
          const FoodRecommendationState(
            categories: Resource.error(NetworkFailure()),
          ),
        ],
        verify: (_) => verifyNever(() => mockMealsUseCase(any())),
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'shows an empty meals list when there are no categories',
        build: () {
          givenCategories(const SuccessResponse([]));
          return cubit;
        },
        act: (c) => c.doIntent(const LoadFoodRecommendationIntent()),
        expect: () => [
          const FoodRecommendationState(categories: Resource.loading()),
          const FoodRecommendationState(categories: Resource.success([])),
          const FoodRecommendationState(
            categories: Resource.success([]),
            meals: Resource.success([]),
          ),
        ],
        verify: (_) => verifyNever(() => mockMealsUseCase(any())),
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'ignores the intent while categories are loading',
        build: () => cubit,
        seed: () =>
            const FoodRecommendationState(categories: Resource.loading()),
        act: (c) => c.doIntent(const LoadFoodRecommendationIntent()),
        expect: () => <FoodRecommendationState>[],
        verify: (_) => verifyNever(() => mockCategoriesUseCase()),
      );
    });

    group('SelectCategoryIntent', () {
      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'selects the tab and loads its meals',
        build: () {
          givenMeals('Chicken', const SuccessResponse(_chickenMeals));
          return cubit;
        },
        seed: () => _loaded,
        act: (c) => c.doIntent(const SelectCategoryIntent(1)),
        expect: () => [
          _loaded.copyWith(selectedIndex: 1),
          _loaded.copyWith(selectedIndex: 1, meals: const Resource.loading()),
          _loaded.copyWith(
            selectedIndex: 1,
            meals: const Resource.success(_chickenMeals),
          ),
        ],
        verify: (_) => verify(() => mockMealsUseCase('Chicken')).called(1),
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'emits a meals error when loading the meals fails',
        build: () {
          givenMeals('Chicken', ErrorResponse(failure: const ServerFailure()));
          return cubit;
        },
        seed: () => _loaded,
        act: (c) => c.doIntent(const SelectCategoryIntent(1)),
        skip: 2,
        expect: () => [
          _loaded.copyWith(
            selectedIndex: 1,
            meals: const Resource.error(ServerFailure()),
          ),
        ],
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'ignores the already selected tab and out of range indexes',
        build: () => cubit,
        seed: () => _loaded,
        act: (c) => c
          ..doIntent(const SelectCategoryIntent(0))
          ..doIntent(const SelectCategoryIntent(5))
          ..doIntent(const SelectCategoryIntent(-1)),
        expect: () => <FoodRecommendationState>[],
        verify: (_) => verifyNever(() => mockMealsUseCase(any())),
      );

      test('drops a late response from a previously selected tab', () async {
        final beef = Completer<BaseResponse<List<MealSummaryEntity>>>();
        when(() => mockMealsUseCase('Beef')).thenAnswer((_) => beef.future);
        givenMeals('Chicken', const SuccessResponse(_chickenMeals));
        cubit.emit(_loaded.copyWith(selectedIndex: 1));

        cubit.doIntent(const SelectCategoryIntent(0));
        cubit.doIntent(const SelectCategoryIntent(1));
        await pumpEventQueue();
        beef.complete(const SuccessResponse(_beefMeals));
        await pumpEventQueue();

        expect(cubit.state.selectedIndex, 1);
        expect(cubit.state.meals, const Resource.success(_chickenMeals));
      });
    });

    group('RetryIntent', () {
      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'reloads categories when they failed',
        build: () {
          givenCategories(const SuccessResponse(_categories));
          givenMeals('Beef', const SuccessResponse(_beefMeals));
          return cubit;
        },
        seed: () => const FoodRecommendationState(
          categories: Resource.error(NetworkFailure()),
        ),
        act: (c) => c.doIntent(const RetryIntent()),
        verify: (c) {
          verify(() => mockCategoriesUseCase()).called(1);
          expect(c.state, _loaded);
        },
      );

      blocTest<FoodRecommendationCubit, FoodRecommendationState>(
        'reloads only the meals when categories are loaded',
        build: () {
          givenMeals('Beef', const SuccessResponse(_beefMeals));
          return cubit;
        },
        seed: () =>
            _loaded.copyWith(meals: const Resource.error(NetworkFailure())),
        act: (c) => c.doIntent(const RetryIntent()),
        verify: (c) {
          verifyNever(() => mockCategoriesUseCase());
          expect(c.state, _loaded);
        },
      );
    });

    group('ui events', () {
      test('emits an error snackbar event with the failure', () async {
        givenCategories(ErrorResponse(failure: const NetworkFailure()));
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doIntent(const LoadFoodRecommendationIntent());
        await pumpEventQueue();

        expect(events, [
          isA<ShowErrorSnackBarEvent>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        ]);
      });
    });
  });
}
