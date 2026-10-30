import 'package:dio/dio.dart';

class JsonContentInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final header = response.headers.value(Headers.contentTypeHeader);
    if (header != null && header.toLowerCase().contains('json')) {
      handler.next(response);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Expected a JSON response',
      ),
    );
  }
}
