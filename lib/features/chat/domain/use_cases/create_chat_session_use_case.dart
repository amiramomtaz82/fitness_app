import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entites/chat_entities/chat_session_entity.dart';
import '../repo/chat_repo.dart';

@injectable
class CreateChatSessionUseCase {
  static const int maxTitleLength = 40;

  final ChatRepo _chatRepo;

  const CreateChatSessionUseCase(this._chatRepo);

  Future<BaseResponse<ChatSessionEntity>> call(String firstMessage) {
    final now = DateTime.now();
    return _chatRepo.createSession(
      ChatSessionEntity(
        id: 'ses_${now.millisecondsSinceEpoch}',
        title: _buildTitle(firstMessage),
        updatedAt: now,
        totalTokens: 0,
      ),
    );
  }

  String _buildTitle(String message) {
    final normalized = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= maxTitleLength) return normalized;
    return '${normalized.substring(0, maxTitleLength).trimRight()}…';
  }
}
