import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

class FakeRegisterParameters extends Fake implements RegisterParameters {}

void main() {
  late MockAuthRepo mockRepo;
  late RegisterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeRegisterParameters());
  });

  setUp(() {
    mockRepo = MockAuthRepo();
    useCase = RegisterUseCase(mockRepo);
  });

  const testParams = RegisterParameters(
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    password: 'Password123',
    gender: 'male',
    age: 25,
    weight: 75,
    height: 175,
    goal: 'Gain weight',
    activityLevel: 'level1',
  );

  const testUser = UserEntity(
    id: '123',
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    gender: 'male',
    age: 25,
    weight: 75,
    height: 175,
    goal: 'Gain weight',
    activityLevel: 'level1',
  );

  group('RegisterUseCase', () {
    test(
      'should return SuccessResponse<UserEntity> when repo succeeds',
      () async {
        const expectedResponse = SuccessResponse<UserEntity>(testUser);
        when(
          () => mockRepo.register(any()),
        ).thenAnswer((_) async => expectedResponse);

        final result = await useCase(testParams);

        expect(result, equals(expectedResponse));
        expect(result, isA<SuccessResponse<UserEntity>>());
        final success = result as SuccessResponse<UserEntity>;
        expect(success.data, equals(testUser));
        verify(() => mockRepo.register(testParams)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test('should return ErrorResponse<UserEntity> when repo fails', () async {
      final expectedResponse = ErrorResponse<UserEntity>(
        failure: const ServerFailure(
          serverMessage: 'User already exists',
          statusCode: 409,
        ),
      );
      when(
        () => mockRepo.register(any()),
      ).thenAnswer((_) async => expectedResponse);

      final result = await useCase(testParams);

      expect(result, equals(expectedResponse));
      expect(result, isA<ErrorResponse<UserEntity>>());
      final error = result as ErrorResponse<UserEntity>;
      expect(error.failure.serverMessage, equals('User already exists'));
      expect(error.failure.statusCode, equals(409));
      verify(() => mockRepo.register(testParams)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
