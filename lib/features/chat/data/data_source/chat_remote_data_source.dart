import '../models/ollama_chat_request_dto.dart';
import '../models/ollama_chat_response_dto.dart';

abstract interface class ChatRemoteDataSource {
  Future<OllamaChatResponseDto> chat(OllamaChatRequestDto request);
}
