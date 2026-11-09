import '../../../../core/base_response/base_response.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../entites/chat_entities/chat_session_entity.dart';
import '../entites/chat_entities/coach_turn_results.dart';

abstract interface class ChatRepo {
  /// Model conversation with tools enabled
  Future<BaseResponse<CoachResponseWithToolsEntity>>
  requestCoachResponseWithTools({
    required List<ChatMessageEntity> history,
    required String userText,
    List<ToolExecutionResultEntity> toolResults = const [],
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
    String? userName,
    int? userAge,
    String? userGender,
  });

  /// Model gives final reply formatted as structured JSON
  Future<BaseResponse<CoachStructuredResultEntity>>
  requestStructuredCoachResponse({
    required List<ChatMessageEntity> history,
    required String userText,
    required List<ToolExecutionResultEntity> toolResults,
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
    String? userName,
    int? userAge,
    String? userGender,
  });

  Future<BaseResponse<ChatSessionEntity>> createSession(
    ChatSessionEntity session,
  );

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
