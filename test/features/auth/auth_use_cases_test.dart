import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/login_params.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo repo;

  const params = LoginParams(email: 'test@test.com', password: 'Pass1234');

  setUpAll(() => registerFallbackValue(params));

  setUp(() => repo = MockAuthRepo());

  group('LoginUseCase', () {
    test('delegates to the repo with the given params', () async {
      const response = SuccessResponse(UserEntity(id: 'user-id'));
      when(() => repo.login(any())).thenAnswer((_) async => response);

      final result = await LoginUseCase(repo)(params);

      expect(result, response);
      verify(() => repo.login(params)).called(1);
    });

    test('returns the error response from the repo as is', () async {
      final response = ErrorResponse<UserEntity>(errMessage: 'boom');
      when(() => repo.login(any())).thenAnswer((_) async => response);

      final result = await LoginUseCase(repo)(params);

      expect(result, response);
    });
  });
}
