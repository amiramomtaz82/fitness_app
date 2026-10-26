import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fitness_app/core/contants/endpoints/endpoints.dart';

class MockForgetPasswordInterceptor extends Interceptor {
  MockForgetPasswordInterceptor();

  static const Map<String, String> _mockedPaths = {
    Endpoints.forgotPassword: 'Reset code sent to your email.',
    Endpoints.verifyResetCode: 'Reset code verified successfully.',
    Endpoints.resetPassword: 'Password reset successfully.',
  };

  bool _isMocked(RequestOptions options) =>
      _mockedPaths.containsKey(options.path) &&
      (options.method == 'POST' || options.method == 'PUT');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_isMocked(options)) return handler.next(options);
    debugPrint(
      '[MOCK BACKEND] Intercepted ${options.method} ${options.path} '
      'locally - no network/API call was made.',
    );

    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'message': _mockedPaths[options.path],
        },
      ),
    );
  }
}
