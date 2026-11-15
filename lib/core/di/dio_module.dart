import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../contants/endpoints/endpoints.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/json_content_interceptor.dart';
import '../interceptors/local_interceptor.dart';
import '../interceptors/mock_forget_password_interceptor.dart';
import '../interceptors/ollama_auth_interceptor.dart';

/// Names used with `@Named` to tell the app's Dio instances apart.
abstract final class DioNames {
  DioNames._();

  static const String mealDb = 'mealDbDio';
  static const String ollama = 'ollamaDio';
}

@module
abstract class DioModule {
  @singleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LocaleInterceptor localeInterceptor,
  ) {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dioInstance.interceptors.add(authInterceptor);
    dioInstance.interceptors.add(localeInterceptor);
    dioInstance.interceptors.add(MockForgetPasswordInterceptor());
    dioInstance.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    return dioInstance;
  }

  @Named(DioNames.ollama)
  @lazySingleton
  Dio ollamaDio(OllamaAuthInterceptor ollamaAuthInterceptor) {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: Endpoints.ollamaBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    // ✅ Attaches API Key to Ollama requests automatically
    dioInstance.interceptors.add(ollamaAuthInterceptor);
    dioInstance.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
      ),
    );
    return dioInstance;
  }

  @Named(DioNames.mealDb)
  @lazySingleton
  Dio mealDbDio() {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: Endpoints.mealDbBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    // Public API: no auth interceptor needed
    dioInstance.interceptors.add(JsonContentInterceptor());
    dioInstance.interceptors.add(PrettyDioLogger(responseBody: false));
    return dioInstance;
  }
}
