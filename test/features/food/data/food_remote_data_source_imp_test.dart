import 'package:fitness_app/features/food/data/api/food_api_client.dart';
import 'package:fitness_app/features/food/data/data_source/food_remote_data_source_imp.dart';
import 'package:fitness_app/features/food/data/models/meal_categories_response_dto.dart';
import 'package:fitness_app/features/food/data/models/meal_category_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodApiClient extends Mock implements FoodApiClient {}

void main() {
  late MockFoodApiClient mockClient;
  late FoodRemoteDataSourceImp dataSource;

  setUp(() {
    mockClient = MockFoodApiClient();
    dataSource = FoodRemoteDataSourceImp(mockClient);
  });

  group('FoodRemoteDataSourceImp —', () {
    group('getMealCategories', () {
      test('returns the client response on success', () async {
        const response = MealCategoriesResponseDto(
          categories: [MealCategoryDto(id: '1', name: 'Beef')],
        );
        when(
          () => mockClient.getMealCategories(),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getMealCategories();

        expect(result, response);
        verify(() => mockClient.getMealCategories()).called(1);
      });

      test('rethrows when the client throws', () async {
        when(() => mockClient.getMealCategories()).thenThrow(Exception('boom'));

        expect(() => dataSource.getMealCategories(), throwsException);
      });
    });
  });
}
