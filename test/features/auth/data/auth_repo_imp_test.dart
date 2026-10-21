import 'package:dio/dio.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/data/data_source/local/local_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/models/login_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/login_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/user_dto.dart';
import 'package:fitness_app/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fitness_app/features/auth/domain/entities/login_params.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

const _params = LoginParams(email: 'test@test.com', password: 'Pass1234');

const _testUser = UserEntity(
  id: 'user-id',
  firstName: 'Test',
  email: 'test@test.com',
);

const _successResponse = LoginResponseDto(
  message: 'success',
  token: 'abc123',
  user: UserDto(id: 'user-id', firstName: 'Test', email: 'test@test.com'),
);

DioException _dioError(DioExceptionType type, {int? statusCode}) {
  return DioException(
    requestOptions: RequestOptions(),
    type: type,
    response: statusCode == null
        ? null
        : Response(
            requestOptions: RequestOptions(),
            statusCode: statusCode,
            data: {'error': 'incorrect email or password'},
          ),
  );
}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late AuthRepoImp repo;

  setUpAll(() {
    registerFallbackValue(const LoginRequestDto(email: '', password: ''));
    registerFallbackValue(const UserEntity());
  });

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repo = AuthRepoImp(mockRemote, mockLocal);
    when(() => mockLocal.saveToken(any())).thenAnswer((_) async {});
    when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});
  });

  group('AuthRepoImp —', () {
    group('login', () {
      test('returns the user entity on success', () async {
        when(
          () => mockRemote.login(any()),
        ).thenAnswer((_) async => _successResponse);

        final result = await repo.login(_params);

        expect((result as SuccessResponse<UserEntity>).data, _testUser);
      });

      test('sends the email and password to the remote', () async {
        when(
          () => mockRemote.login(any()),
        ).thenAnswer((_) async => _successResponse);

        await repo.login(_params);

        final request =
            verify(() => mockRemote.login(captureAny())).captured.single
                as LoginRequestDto;
        expect(request.email, _params.email);
        expect(request.password, _params.password);
      });

      test('caches the token and the user on success', () async {
        when(
          () => mockRemote.login(any()),
        ).thenAnswer((_) async => _successResponse);

        await repo.login(_params);

        verify(() => mockLocal.saveToken('abc123')).called(1);
        verify(() => mockLocal.saveUser(_testUser)).called(1);
      });

      test('returns an unauthorized error on wrong credentials', () async {
        when(
          () => mockRemote.login(any()),
        ).thenThrow(_dioError(DioExceptionType.badResponse, statusCode: 401));

        final result = await repo.login(_params);

        expect(
          result,
          isA<ErrorResponse<UserEntity>>()
              .having((e) => e.failure, 'failure', isA<UnauthorizedFailure>())
              .having(
                (e) => e.errMessage,
                'errMessage',
                'incorrect email or password',
              ),
        );
        verifyNever(() => mockLocal.saveToken(any()));
        verifyNever(() => mockLocal.saveUser(any()));
      });

      test('returns a network error when there is no connection', () async {
        when(
          () => mockRemote.login(any()),
        ).thenThrow(_dioError(DioExceptionType.connectionError));

        final result = await repo.login(_params);

        expect(
          result,
          isA<ErrorResponse<UserEntity>>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        );
      });
    });
  });
}
