import 'package:dio/dio.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/data/data_source/local/local_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/firestore_user_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/social_auth_data_source.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/forget_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/register_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/register_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/registered_user_dto.dart';
import 'package:fitness_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/user_dto.dart';
import 'package:fitness_app/features/auth/data/models/verify_otp_request_dto.dart';
import 'package:fitness_app/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

class MockFirestoreUserService extends Mock implements FirestoreUserService {}

class FakeRegisterRequestDto extends Fake implements RegisterRequestDto {}

class FakeRegisteredUserDto extends Fake implements RegisteredUserDto {}

class FakeForgetPasswordRequestDto extends Fake
    implements ForgetPasswordRequestDto {}

class FakeVerifyOtpRequestDto extends Fake implements VerifyOtpRequestDto {}

class FakeResetPasswordRequestDto extends Fake
    implements ResetPasswordRequestDto {}

RequestOptions testOptions() => RequestOptions(path: '/auth/test');

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

void main() {
  const okDto = AuthActionResponseDto(success: true, message: 'done');

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockSocialAuthService mockSocialAuthService;
  late MockFirestoreUserService mockFirestoreUserService;
  late AuthRepoImp repo;

  setUpAll(() {
    registerFallbackValue(FakeRegisterRequestDto());
    registerFallbackValue(FakeRegisteredUserDto());
    registerFallbackValue(FakeForgetPasswordRequestDto());
    registerFallbackValue(FakeVerifyOtpRequestDto());
    registerFallbackValue(FakeResetPasswordRequestDto());
    registerFallbackValue(const UserEntity());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockSocialAuthService = MockSocialAuthService();
    mockFirestoreUserService = MockFirestoreUserService();

    when(() => mockLocalDataSource.saveToken(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.saveUser(any())).thenAnswer((_) async {});
    when(
      () => mockFirestoreUserService.getProviderPassword(any()),
    ).thenAnswer((_) async => 'Google123!');
    when(
      () => mockFirestoreUserService.saveUser(any()),
    ).thenAnswer((_) async {});

    repo = AuthRepoImp(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockSocialAuthService,
      mockFirestoreUserService,
    );
  });

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

  group('AuthRepoImp forget password mapping', () {
    test(
      'sendResetCode converts the entity to a dto and maps the result back',
      () async {
        when(
          () => mockRemoteDataSource.sendResetCode(any()),
        ).thenAnswer((_) async => okDto);

        final response = await repo.sendResetCode(
          const ForgetPasswordRequest(email: 'user@mail.com'),
        );

        expect(response, isA<SuccessResponse<AuthActionResult>>());
        final data = (response as SuccessResponse<AuthActionResult>).data;
        expect(data.success, isTrue);
        expect(data.message, 'done');
        verify(
          () => mockRemoteDataSource.sendResetCode(
            any(that: isA<ForgetPasswordRequestDto>()),
          ),
        ).called(1);
      },
    );

    test(
      'verifyResetCode surfaces a rejected code as a failed entity',
      () async {
        when(() => mockRemoteDataSource.verifyResetCode(any())).thenAnswer(
          (_) async => const AuthActionResponseDto(
            success: false,
            message: 'Invalid reset code.',
          ),
        );

        final response = await repo.verifyResetCode(
          const VerifyOtpRequest(resetCode: '0000'),
        );

        final entity = (response as SuccessResponse<AuthActionResult>).data;
        expect(entity.success, isFalse);
        expect(entity.message, 'Invalid reset code.');
        verify(
          () => mockRemoteDataSource.verifyResetCode(
            any(that: isA<VerifyOtpRequestDto>()),
          ),
        ).called(1);
      },
    );

    test(
      'resetPassword converts the entity to a dto and maps the result back',
      () async {
        when(
          () => mockRemoteDataSource.resetPassword(any()),
        ).thenAnswer((_) async => okDto);

        final response = await repo.resetPassword(
          const ResetPasswordRequest(
            email: 'user@mail.com',
            newPassword: 'NewPass1',
          ),
        );

        expect(
          (response as SuccessResponse<AuthActionResult>).data.success,
          isTrue,
        );
        verify(
          () => mockRemoteDataSource.resetPassword(
            any(that: isA<ResetPasswordRequestDto>()),
          ),
        ).called(1);
      },
    );
  });

  group('AuthRepoImp forget password error handling', () {
    test('wraps a network dio error into a network failure', () async {
      when(() => mockRemoteDataSource.sendResetCode(any())).thenThrow(
        DioException.connectionError(
          requestOptions: testOptions(),
          reason: 'offline',
        ),
      );

      final response = await repo.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(response, isA<ErrorResponse<AuthActionResult>>());
      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NetworkFailure>(),
      );
      verify(() => mockRemoteDataSource.sendResetCode(any())).called(1);
    });

    test('wraps a 500 bad response into a server failure', () async {
      when(() => mockRemoteDataSource.sendResetCode(any())).thenThrow(
        DioException.badResponse(
          statusCode: 500,
          requestOptions: testOptions(),
          response: Response(
            requestOptions: testOptions(),
            statusCode: 500,
            data: {'message': 'Internal error'},
          ),
        ),
      );

      final response = await repo.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      final failure = (response as ErrorResponse<AuthActionResult>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.serverMessage, 'Internal error');
      expect(failure.statusCode, 500);
      verify(() => mockRemoteDataSource.sendResetCode(any())).called(1);
    });

    test('wraps a 404 into a not found failure', () async {
      when(() => mockRemoteDataSource.resetPassword(any())).thenThrow(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: testOptions(),
          response: Response(requestOptions: testOptions(), statusCode: 404),
        ),
      );

      final response = await repo.resetPassword(
        const ResetPasswordRequest(
          email: 'user@mail.com',
          newPassword: 'NewPass1',
        ),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NotFoundFailure>(),
      );
      verify(() => mockRemoteDataSource.resetPassword(any())).called(1);
    });

    test('wraps any other error into an unknown failure', () async {
      when(
        () => mockRemoteDataSource.verifyResetCode(any()),
      ).thenThrow(StateError('boom'));

      final response = await repo.verifyResetCode(
        const VerifyOtpRequest(resetCode: '7542'),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<UnknownFailure>(),
      );
      verify(() => mockRemoteDataSource.verifyResetCode(any())).called(1);
    });
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

      expect(await repo.getSavedUser(), equals(user));
      verify(() => mockLocalDataSource.getUser()).called(1);
    });

    test('logout clears both token and user', () async {
      when(() => mockLocalDataSource.deleteToken()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.deleteUser()).thenAnswer((_) async {});

      await repo.logout();

      verifyInOrder([
        () => mockLocalDataSource.deleteToken(),
        () => mockLocalDataSource.deleteUser(),
      ]);
      verifyNever(() => mockLocalDataSource.saveToken(any()));
      verifyNever(() => mockLocalDataSource.saveUser(any()));
    });
  });
}