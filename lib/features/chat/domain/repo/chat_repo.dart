import '../../../../core/base_response/base_response.dart';
import '../../data/models/ollama_chat_response_dto.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../entites/chat_entities/chat_session_entity.dart';

abstract interface class ChatRepo {
  Future<BaseResponse<OllamaChatResponseDto>> requestTurnA({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> tools,
  });

  Future<BaseResponse<OllamaChatResponseDto>> requestTurnB({
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> formatSchema,
  });

  Future<BaseResponse<void>> saveMessage(
    String sessionId,
    ChatMessageEntity msg,
    int tokens,
  );
  Future<BaseResponse<List<ChatMessageEntity>>> getMessages(String sessionId);
  Future<BaseResponse<List<ChatSessionEntity>>> getPreviousSessions();
}
