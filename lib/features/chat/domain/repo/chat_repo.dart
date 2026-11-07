import '../../../../core/base_response/base_response.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../entites/chat_entities/chat_session_entity.dart';
import '../entites/chat_entities/coach_turn_results.dart';

abstract interface class ChatRepo {
  /// Turn A: Model conversation with tools enabled
  Future<BaseResponse<CoachTurnAResultEntity>> requestTurnA({
    required List<ChatMessageEntity> history,
    required String userText,
    List<ToolExecutionResultEntity> toolResults = const [],
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
  });

  /// Turn B: Model gives final reply formatted as structured JSON
  Future<BaseResponse<CoachTurnBResultEntity>> requestTurnB({
    required List<ChatMessageEntity> history,
    required String userText,
    required List<ToolExecutionResultEntity> toolResults,
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
  });

  Future<BaseResponse<void>> saveMessage(
      String sessionId,
      ChatMessageEntity msg,
      int tokens,
      );

  Future<BaseResponse<List<ChatMessageEntity>>> getMessages(String sessionId);

  Future<BaseResponse<List<ChatSessionEntity>>> getPreviousSessions({
    int limit = 20,
    int? lastUpdatedAtMillis,
  });
}