import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/data/data_source/local/local_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/models/register_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/register_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/user_dto.dart';
import 'package:fitness_app/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

class FakeRegisterRequestDto extends Fake implements RegisterRequestDto {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late AuthRepoImp repo;

  setUpAll(() {
    registerFallbackValue(FakeRegisterRequestDto());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repo = AuthRepoImp(mockRemoteDataSource, mockLocalDataSource);
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

  const testUserDto = UserDto(
    id: '123',
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    gender: 'male',
    age: 25,
    weight: 75,
    height: 175,
    activityLevel: 'level1',
    goal: 'Gain weight',
  );

  const testResponse = RegisterResponseDto(
    message: 'success',
    user: testUserDto,
    token: 'jwt-token-xyz',
  );

  group('AuthRepoImp.register', () {
    test(
      'returns SuccessResponse with UserEntity when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.register(any()),
        ).thenAnswer((_) async => testResponse);

        final result = await repo.register(testParams);

        expect(result, isA<SuccessResponse<UserEntity>>());
        final success = result as SuccessResponse<UserEntity>;
        expect(success.data.id, equals('123'));
        expect(success.data.firstName, equals('Ahmed'));
        expect(success.data.email, equals('ahmed@test.com'));
        verify(() => mockRemoteDataSource.register(any())).called(1);
      },
    );

    test(
      'returns ErrorResponse when remote call throws an exception',
      () async {
        when(
          () => mockRemoteDataSource.register(any()),
        ).thenThrow(Exception('Server unreachable'));

        final result = await repo.register(testParams);

        expect(result, isA<ErrorResponse<UserEntity>>());
        final error = result as ErrorResponse<UserEntity>;
        expect(error.failure, isNotNull);
        verify(() => mockRemoteDataSource.register(any())).called(1);
      },
    );
  });

  group('AuthRepoImp local data source delegation', () {
    test('getToken returns token from local data source', () async {
      when(
        () => mockLocalDataSource.getToken(),
      ).thenAnswer((_) async => 'saved-token');
      final result = await repo.getToken();
      expect(result, equals('saved-token'));
      verify(() => mockLocalDataSource.getToken()).called(1);
    });

    test('isLoggedIn returns bool from local data source', () async {
      when(
        () => mockLocalDataSource.isLoggedIn(),
      ).thenAnswer((_) async => true);
      final result = await repo.isLoggedIn();
      expect(result, isTrue);
      verify(() => mockLocalDataSource.isLoggedIn()).called(1);
    });

    test('getSavedUser returns user entity from local data source', () async {
      const user = UserEntity(id: '123', email: 'test@test.com');
      when(() => mockLocalDataSource.getUser()).thenAnswer((_) async => user);
      final result = await repo.getSavedUser();
      expect(result, equals(user));
      verify(() => mockLocalDataSource.getUser()).called(1);
    });

    test('logout deletes token and user from local data source', () async {
      when(() => mockLocalDataSource.deleteToken()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.deleteUser()).thenAnswer((_) async {});

      await repo.logout();

      verify(() => mockLocalDataSource.deleteToken()).called(1);
      verify(() => mockLocalDataSource.deleteUser()).called(1);
    });
  });
}
