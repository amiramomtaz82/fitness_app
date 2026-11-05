import 'package:injectable/injectable.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../client/chat_api_client.dart';
import '../models/ollama_chat_response_dto.dart';

@lazySingleton
class ChatRemoteDataSource {
  final ChatApiClient _apiClient;
  final SecureStorage _secureStorage;

  const ChatRemoteDataSource(this._apiClient, this._secureStorage);

  Future<String> _resolveBearer() async {
    final key = await _secureStorage.read(key: 'OLLAMA_API_KEY');
    return 'Bearer ${key ?? ''}';
  }

  //------------------turn A----------------------------------------------------
  Future<OllamaChatResponseDto> sendTurnA({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> tools,
  }) async {
    final bearer = await _resolveBearer();
    return _apiClient.chat(bearer, {
      'model': 'gemma4:31b',
      'messages': messages,
      'tools': tools,
      'stream': false,
      'think': false,
      'options': {'temperature': 0.6, 'num_predict': 512},
    });
  }

  //------------------turn B----------------------------------------------------
  Future<OllamaChatResponseDto> sendTurnB({
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> formatSchema,
  }) async {
    final bearer = await _resolveBearer();
    return _apiClient.chat(bearer, {
      'model': 'gemma4:31b',
      'messages': messages,
      'format': formatSchema,
      'stream': false,
      'think': false,
      'options': {'temperature': 0.6, 'num_predict': 512},
    });
  }
}
