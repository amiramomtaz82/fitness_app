import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/food/domain/entities/meal_details_entity.dart';
import 'package:fitness_app/features/food/domain/repo/food_repo.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_details_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRepo extends Mock implements FoodRepo {}

void main() {
  late MockFoodRepo repo;
  late GetMealDetailsUseCase useCase;

  setUp(() {
    repo = MockFoodRepo();
    useCase = GetMealDetailsUseCase(repo);
  });

  test('returns the repository success response', () {
    return returnsMealSuccess(repo, useCase);
  });
  test('returns the repository error response', () {
    return returnsMealError(repo, useCase);
  });
}

Future<void> returnsMealSuccess(
  MockFoodRepo repo,
  GetMealDetailsUseCase useCase,
) async {
  const response = SuccessResponse<MealDetailsEntity?>(
    MealDetailsEntity(id: '52959'),
  );
  when(
    () => repo.getMealDetails('52959'),
  ).thenAnswer((invocation) async => response);
  final result = await useCase.call('52959');
  expect(result, same(response));
  verify(() => repo.getMealDetails('52959')).called(1);
}

Future<void> returnsMealError(
  MockFoodRepo repo,
  GetMealDetailsUseCase useCase,
) async {
  final response = ErrorResponse<MealDetailsEntity?>(errMessage: 'offline');
  when(
    () => repo.getMealDetails('52959'),
  ).thenAnswer((invocation) async => response);
  final result = await useCase.call('52959');
  expect(result, same(response));
  verify(() => repo.getMealDetails('52959')).called(1);
}
