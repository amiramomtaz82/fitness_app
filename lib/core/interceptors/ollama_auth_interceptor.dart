import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../secure_storage/secure_storage.dart';

@injectable
class OllamaAuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  static const String ollamaApiKey = 'OLLAMA_API_KEY';

  OllamaAuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.read(key: ollamaApiKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}