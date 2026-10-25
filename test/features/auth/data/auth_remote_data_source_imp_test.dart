import 'package:fitness_app/features/auth/data/client/auth_client.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source_imp.dart';
import 'package:fitness_app/features/auth/data/models/login_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/login_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/user_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthClient extends Mock implements AuthClient {}

void main() {
  late MockAuthClient mockClient;
  late AuthRemoteDataSourceImp dataSource;

  const request = LoginRequestDto(email: 'test@test.com', password: 'Pass1234');

  setUp(() {
    mockClient = MockAuthClient();
    dataSource = AuthRemoteDataSourceImp(mockClient);
  });

  group('AuthRemoteDataSourceImp —', () {
    group('login', () {
      test('returns the client response on success', () async {
        const response = LoginResponseDto(
          message: 'success',
          token: 'abc123',
          user: UserDto(id: 'user-id'),
        );
        when(() => mockClient.login(request)).thenAnswer((_) async => response);

        final result = await dataSource.login(request);

        expect(result, response);
        verify(() => mockClient.login(request)).called(1);
      });

      test('rethrows when the client throws', () async {
        when(() => mockClient.login(request)).thenThrow(Exception('boom'));

        expect(() => dataSource.login(request), throwsException);
      });
    });
  });
}
