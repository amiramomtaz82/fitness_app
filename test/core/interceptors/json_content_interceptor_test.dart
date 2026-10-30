import 'package:dio/dio.dart';
import 'package:fitness_app/core/interceptors/json_content_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('passes a JSON success response through', passesJson);
  test('rejects a non-JSON success response', rejectsHtml);
}

void passesJson() {
  final response = lookupResponse(
    data: const {'meals': []},
    contentType: 'application/json',
  );
  final handler = RecordingResponseHandler();
  JsonContentInterceptor().onResponse(response, handler);
  expect(handler.nexted, response);
  expect(handler.rejected, isNull);
}

void rejectsHtml() {
  final response = lookupResponse(
    data: '<html>rate limit</html>',
    contentType: 'text/html',
  );
  final handler = RecordingResponseHandler();
  JsonContentInterceptor().onResponse(response, handler);
  expect(handler.nexted, isNull);
  expect(handler.rejected?.type, DioExceptionType.badResponse);
  expect(handler.rejected?.response?.data, '<html>rate limit</html>');
}

Response<dynamic> lookupResponse({
  required Object data,
  required String contentType,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/lookup.php'),
    statusCode: 200,
    data: data,
    headers: Headers.fromMap({
      Headers.contentTypeHeader: [contentType],
    }),
  );
}

class RecordingResponseHandler extends ResponseInterceptorHandler {
  Response<dynamic>? nexted;
  DioException? rejected;

  @override
  void next(Response<dynamic> response) {
    nexted = response;
  }

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {
    rejected = error;
  }
}
