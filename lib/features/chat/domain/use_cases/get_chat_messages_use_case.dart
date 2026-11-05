import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../repo/chat_repo.dart';

@lazySingleton
class GetChatMessagesUseCase {
  final ChatRepo _chatRepo;
  const GetChatMessagesUseCase(this._chatRepo);

  Future<BaseResponse<List<ChatMessageEntity>>> call(String sessionId) {
    return _chatRepo.getMessages(sessionId);
  }
}
