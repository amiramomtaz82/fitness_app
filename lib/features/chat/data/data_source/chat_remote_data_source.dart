import 'package:injectable/injectable.dart';

import '../client/chat_api_client.dart';
import '../models/ollama_chat_request_dto.dart';
import '../models/ollama_chat_response_dto.dart';

@lazySingleton
class ChatRemoteDataSource {
  final ChatApiClient _apiClient;

  const ChatRemoteDataSource(this._apiClient);


  Future<OllamaChatResponseDto> chat(OllamaChatRequestDto request) {
    return _apiClient.chat(request);
  }
}