import 'package:fitness_app/features/food/data/api/food_api_client.dart';
import 'package:fitness_app/features/food/data/data_source/food_remote_data_source_imp.dart';
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
  test('parses a meal object returned by the client', parsesMealObject);
  test(
    'throws when the client response is not an object',
    throwsWhenBodyIsNotAnObject,
  );
}

Future<void> parsesMealObject() async {
  when(() => client.lookupMeal('52959')).thenAnswer(salmonLookupBody);
  final result = await dataSource.lookupMeal('52959');
  expect(result.meal?.name, 'Baked salmon');
  expect(result.meal?.ingredients.single.name, 'Fennel');
}

Future<Map<String, dynamic>> salmonLookupBody(Invocation invocation) async {
  return {
    'meals': [
      {'strMeal': 'Baked salmon', 'strIngredient1': 'Fennel'},
    ],
  };
}

Future<void> throwsWhenBodyIsNotAnObject() async {
  when(
    () => client.lookupMeal('52959'),
  ).thenAnswer((invocation) async => ['meals']);
  expect(() => dataSource.lookupMeal('52959'), throwsA(isA<FormatException>()));
}
