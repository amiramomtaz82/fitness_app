import 'package:dio/dio.dart';
import 'package:fitness_app/core/error/error_handler.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps a JSON error message for its status', keepsJsonMessage);
  test('ignores an HTML error body and uses the status', ignoresHtmlBody);
}

void keepsJsonMessage() {
  final failure = ErrorHandler.handle(
    badResponse(404, {'message': 'Missing meal'}),
  );
  expect(failure, isA<NotFoundFailure>());
  expect(failure.serverMessage, 'Missing meal');
  expect(failure.statusCode, 404);
}

void ignoresHtmlBody() {
  final failure = ErrorHandler.handle(badResponse(429, '<html>limit</html>'));
  expect(failure, isA<ServerFailure>());
  expect(failure.serverMessage, isNull);
  expect(failure.statusCode, 429);
  expect(failure.serverMessage, isNot(contains('limit')));
}

DioException badResponse(int statusCode, Object data) {
  final options = RequestOptions(path: '/lookup.php');
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}
