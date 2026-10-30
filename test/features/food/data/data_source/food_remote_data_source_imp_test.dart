import 'package:fitness_app/features/food/data/api/food_api_client.dart';
import 'package:fitness_app/features/food/data/data_source/food_remote_data_source_imp.dart';
import 'package:fitness_app/features/food/data/models/meal_details_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodApiClient extends Mock implements FoodApiClient {}

late MockFoodApiClient client;
late FoodRemoteDataSourceImp dataSource;

void main() {
  setUp(createFoodDataSource);
  registerFoodDataSourceTests();
}

void createFoodDataSource() {
  client = MockFoodApiClient();
  dataSource = FoodRemoteDataSourceImp(client);
}

void registerFoodDataSourceTests() {
  test('returns the meal from the client', returnsClientMeal);
  test('returns an empty lookup from the client', returnsEmptyLookup);
}

Future<void> returnsClientMeal() async {
  final lookup = MealLookupDto.fromJson(const {
    'meals': [
      {'strMeal': 'Baked salmon', 'strIngredient1': 'Fennel'},
    ],
  });
  when(() => client.lookupMeal('52959')).thenAnswer((_) async => lookup);
  final result = await dataSource.lookupMeal('52959');
  expect(result.meal?.name, 'Baked salmon');
  expect(result.meal?.ingredients.single.name, 'Fennel');
}

Future<void> returnsEmptyLookup() async {
  const lookup = MealLookupDto(null);
  when(() => client.lookupMeal('8')).thenAnswer((_) async => lookup);
  final result = await dataSource.lookupMeal('8');
  expect(result.meal, isNull);
}
