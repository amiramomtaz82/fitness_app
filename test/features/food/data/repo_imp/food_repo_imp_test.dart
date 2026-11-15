import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food/data/data_source/food_remote_data_source.dart';
import 'package:fitness_app/features/food/data/models/meal_details_dto.dart';
import 'package:fitness_app/features/food/data/repo_imp/food_repo_imp.dart';
import 'package:fitness_app/features/food/domain/entities/meal_details_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRemoteDataSource extends Mock implements FoodRemoteDataSource {}

late MockFoodRemoteDataSource remote;
late FoodRepoImp repo;

void main() {
  setUp(createFoodRepo);
  registerFoodRepoTests();
}

void createFoodRepo() {
  remote = MockFoodRemoteDataSource();
  repo = FoodRepoImp(remote);
}

void registerFoodRepoTests() {
  test('returns the mapped meal when lookup succeeds', returnsMappedMeal);
  test(
    'returns an empty success when the payload has no meal',
    returnsEmptySuccess,
  );
  test('returns an error response when lookup throws', returnsLookupError);
}

Future<void> returnsMappedMeal() async {
  const dto = MealDto(
    id: '52959',
    name: 'Baked salmon',
    ingredients: [MealIngredientDto(name: 'Fennel', measure: '2 medium')],
  );
  when(
    () => remote.lookupMeal('52959'),
  ).thenAnswer((invocation) async => const MealLookupDto(dto));
  final result = await repo.getMealDetails('52959');
  expectMappedSalmon(result);
  verify(() => remote.lookupMeal('52959')).called(1);
}

void expectMappedSalmon(BaseResponse<MealDetailsEntity?> result) {
  final success = result as SuccessResponse<MealDetailsEntity?>;
  expect(success.data?.id, '52959');
  expect(success.data?.name, 'Baked salmon');
  expect(success.data?.ingredients.single.name, 'Fennel');
  expect(success.data?.ingredients.single.measure, '2 medium');
}

Future<void> returnsEmptySuccess() async {
  when(
    () => remote.lookupMeal('52959'),
  ).thenAnswer((invocation) async => const MealLookupDto(null));
  final result = await repo.getMealDetails('52959');
  expect(result, isA<SuccessResponse<MealDetailsEntity?>>());
  expect((result as SuccessResponse<MealDetailsEntity?>).data, isNull);
}

Future<void> returnsLookupError() async {
  when(() => remote.lookupMeal('52959')).thenThrow(Exception('offline'));
  final result = await repo.getMealDetails('52959');
  expectLookupFailure(result);
  verify(() => remote.lookupMeal('52959')).called(1);
}

void expectLookupFailure(BaseResponse<MealDetailsEntity?> result) {
  final error = result as ErrorResponse<MealDetailsEntity?>;
  expect(error.failure, isA<UnknownFailure>());
  expect(error.failure.serverMessage, contains('offline'));
}
