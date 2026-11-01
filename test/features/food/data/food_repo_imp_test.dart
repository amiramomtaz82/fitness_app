import 'package:dio/dio.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food/data/data_source/food_remote_data_source.dart';
import 'package:fitness_app/features/food/data/models/meal_categories_response_dto.dart';
import 'package:fitness_app/features/food/data/models/meal_category_dto.dart';
import 'package:fitness_app/features/food/data/models/meal_summary_dto.dart';
import 'package:fitness_app/features/food/data/models/meals_response_dto.dart';
import 'package:fitness_app/features/food/data/repo_imp/food_repo_imp.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRemoteDataSource extends Mock implements FoodRemoteDataSource {}

const _beefDto = MealCategoryDto(
  id: '1',
  name: 'Beef',
  thumbnail: 'https://www.themealdb.com/images/category/beef.png',
  description: 'Beef desc',
);

const _beefEntity = MealCategoryEntity(
  id: '1',
  name: 'Beef',
  thumbnail: 'https://www.themealdb.com/images/category/beef.png',
  description: 'Beef desc',
);

void main() {
  late MockFoodRemoteDataSource mockRemote;
  late FoodRepoImp repo;

  setUp(() {
    mockRemote = MockFoodRemoteDataSource();
    repo = FoodRepoImp(mockRemote);
  });

  group('FoodRepoImp —', () {
    group('getMealCategories', () {
      test('returns the mapped categories on success', () async {
        when(() => mockRemote.getMealCategories()).thenAnswer(
          (_) async => const MealCategoriesResponseDto(categories: [_beefDto]),
        );

        final result = await repo.getMealCategories();

        expect((result as SuccessResponse<List<MealCategoryEntity>>).data, [
          _beefEntity,
        ]);
      });

      test('returns an empty list when categories is null', () async {
        when(
          () => mockRemote.getMealCategories(),
        ).thenAnswer((_) async => const MealCategoriesResponseDto());

        final result = await repo.getMealCategories();

        expect(
          (result as SuccessResponse<List<MealCategoryEntity>>).data,
          isEmpty,
        );
      });

      test('returns a network error when there is no connection', () async {
        when(() => mockRemote.getMealCategories()).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repo.getMealCategories();

        expect(
          result,
          isA<ErrorResponse<List<MealCategoryEntity>>>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        );
      });
    });

    group('getMealsByCategory', () {
      test('requests the category and returns the mapped meals', () async {
        when(() => mockRemote.getMealsByCategory(any())).thenAnswer(
          (_) async => const MealsResponseDto(
            meals: [
              MealSummaryDto(
                id: '52959',
                name: 'Baked salmon with fennel & tomatoes',
                thumbnail: 'salmon.jpg',
              ),
            ],
          ),
        );

        final result = await repo.getMealsByCategory('Seafood');

        expect((result as SuccessResponse<List<MealSummaryEntity>>).data, [
          const MealSummaryEntity(
            id: '52959',
            name: 'Baked salmon with fennel & tomatoes',
            thumbnail: 'salmon.jpg',
          ),
        ]);
        verify(() => mockRemote.getMealsByCategory('Seafood')).called(1);
      });

      test('returns an empty list for an unknown category', () async {
        when(
          () => mockRemote.getMealsByCategory(any()),
        ).thenAnswer((_) async => const MealsResponseDto());

        final result = await repo.getMealsByCategory('NotACategory');

        expect(
          (result as SuccessResponse<List<MealSummaryEntity>>).data,
          isEmpty,
        );
      });

      test('returns a network error when there is no connection', () async {
        when(() => mockRemote.getMealsByCategory(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repo.getMealsByCategory('Seafood');

        expect(
          result,
          isA<ErrorResponse<List<MealSummaryEntity>>>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        );
      });
    });
  });
}
