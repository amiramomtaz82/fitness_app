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
    String? userName,
    String? userGender,
    int? userAge,
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
  });

  /// Model gives final reply formatted as structured JSON
  Future<BaseResponse<CoachStructuredResultEntity>>
  requestStructuredCoachResponse({
    required List<ChatMessageEntity> history,
    required String userText,
    required List<ToolExecutionResultEntity> toolResults,
    String? userName,
    String? userGender,
    int? userAge,
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
