import 'package:dio/dio.dart';
import 'package:fitness_app/core/contants/endpoints/endpoints.dart';
import 'package:fitness_app/core/interceptors/mock_forget_password_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fails any request that reaches it: if the mock interceptor really mocks,
/// the adapter is never invoked and the test passes without touching the
/// network.
class _ExplodingAdapter implements HttpClientAdapter {
  bool called = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    called = true;
    throw AssertionError('Network reached for ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _ExplodingAdapter adapter;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl))
      ..interceptors.add(MockForgetPasswordInterceptor());
    adapter = _ExplodingAdapter();
    dio.httpClientAdapter = adapter;
  });

  group('MockForgetPasswordInterceptor', () {
    test(
      'forgotPassword is answered with success without any network call',
      () async {
        final response = await dio.post<Map<String, dynamic>>(
          Endpoints.forgotPassword,
          data: {'email': 'user@mail.com'},
        );

        expect(response.statusCode, 200);
        expect(response.data?['success'], isTrue);
        expect(adapter.called, isFalse);
      },
    );

    test('verifyResetCode accepts any code without any network call', () async {
      final random = await dio.post<Map<String, dynamic>>(
        Endpoints.verifyResetCode,
        data: {'resetCode': '1234'},
      );
      final other = await dio.post<Map<String, dynamic>>(
        Endpoints.verifyResetCode,
        data: {'resetCode': '0000'},
      );

      expect(random.data?['success'], isTrue);
      expect(other.data?['success'], isTrue);
      expect(adapter.called, isFalse);
    });

    test('resetPassword (PUT) is answered with success offline', () async {
      final response = await dio.put<Map<String, dynamic>>(
        Endpoints.resetPassword,
        data: {'email': 'user@mail.com', 'newPassword': 'NewPass1'},
      );

      expect(response.statusCode, 200);
      expect(response.data?['success'], isTrue);
      expect(adapter.called, isFalse);
    });

    test('other endpoints are not mocked and reach the adapter', () async {
      // Dio wraps adapter failures into a DioException: what matters here is
      // that the request actually left the interceptor chain.
      await expectLater(
        dio.get<Map<String, dynamic>>(Endpoints.signin),
        throwsA(isA<DioException>()),
      );
      expect(adapter.called, isTrue);
    });
  });
}
