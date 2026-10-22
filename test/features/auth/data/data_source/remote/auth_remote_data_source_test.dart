import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_app/features/auth/data/client/auth_client.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source_imp.dart';
import 'package:fitness_app/features/auth/data/models/register_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/register_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/user_dto.dart';

class MockAuthClient extends Mock implements AuthClient {}

class FakeRegisterRequestDto extends Fake implements RegisterRequestDto {}

late MockAuthClient mockClient;
late AuthRemoteDataSourceImp dataSource;

void main() {
  setUpAll(registerRemoteFallback);
  setUp(createRemoteSource);
  group('AuthRemoteDataSourceImp.register', remoteRegisterTests);
}

void registerRemoteFallback() {
  registerFallbackValue(FakeRegisterRequestDto());
}

void createRemoteSource() {
  mockClient = MockAuthClient();
  dataSource = AuthRemoteDataSourceImp(mockClient);
}

void remoteRegisterTests() {
  returnsTheClientResponse();
  rethrowsClientFailure();
}

void returnsTheClientResponse() {
  test('should return RegisterResponseDto when client call succeeds', () async {
    when(
      () => mockClient.register(any()),
    ).thenAnswer((_) async => testResponse);
    final result = await dataSource.register(testRequest);
    expect(result, equals(testResponse));
    expect(result.message, equals('success'));
    expect(result.user?.firstName, equals('Ahmed'));
    expect(result.token, equals('jwt-token-xyz'));
    verify(() => mockClient.register(testRequest)).called(1);
  });
}

void rethrowsClientFailure() {
  test('should rethrow exception when client call fails', () async {
    final exception = Exception('Network error');
    when(() => mockClient.register(any())).thenThrow(exception);
    expect(() => dataSource.register(testRequest), throwsA(equals(exception)));
    verify(() => mockClient.register(testRequest)).called(1);
  });
}

const testRequest = RegisterRequestDto(
  firstName: 'Ahmed',
  lastName: 'Ali',
  email: 'ahmed@test.com',
  password: 'Password123',
  rePassword: 'Password123',
  gender: 'male',
  height: 175,
  weight: 75,
  age: 25,
  goal: 'Gain weight',
  activityLevel: 'level1',
);

const testResponse = RegisterResponseDto(
  message: 'success',
  user: UserDto(
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
  ),
  token: 'jwt-token-xyz',
);
