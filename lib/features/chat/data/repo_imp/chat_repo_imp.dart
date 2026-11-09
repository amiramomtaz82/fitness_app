import 'dart:convert';
import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../../../core/contants/chat_prompts_and_schemas.dart';
import '../../../../core/contants/ollama_constants.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';
import '../../domain/entites/chat_entities/chat_session_entity.dart';
import '../../domain/entites/chat_entities/coach_tool_call_entity.dart';
import '../../domain/entites/chat_entities/coach_turn_results.dart';
import '../../domain/repo/chat_repo.dart';

import '../data_source/chat_firestore_data_source.dart';
import '../data_source/chat_remote_data_source.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_session_dto.dart';
import '../models/ollama_chat_request_dto.dart';
import '../models/ollama_message_dto.dart';
import '../models/smart_coach_turn_b_content_dto.dart';

@Injectable(as: ChatRepo)
class ChatRepoImp implements ChatRepo {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatFirestoreDataSource _fireStoreDataSource;

  const ChatRepoImp(this._remoteDataSource, this._fireStoreDataSource);

  ///------------------ Coach Response (tools ON, format OFF) --------------------
  @override
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
  }) => safeCall(() async {
    final messages = _buildMessagesPayload(
      history: history,
      userText: userText,
      toolResults: toolResults,
      goal: userGoal,
      activityLevel: userActivityLevel,
      weight: userWeight,
      height: userHeight,
      name: userName,
      age: userAge,
      gender: userGender,
    );

    final dto = await _remoteDataSource.chat(
      OllamaChatRequestDto(
        messages: messages,
        tools: ChatPromptsAndSchemas.toolsSchema,
      ),
    );

    // Map DTO to Domain Entity (including mapping tool calls to sealed class)
    final toolCalls = <CoachToolCallEntity>[];
    if (dto.message?.toolCalls != null) {
      for (final tc in dto.message!.toolCalls!) {
        final mapped = _mapToolCallDtoToEntity(tc);
        if (mapped != null) toolCalls.add(mapped);
      }
    }

    return CoachResponseWithToolsEntity(
      text: dto.message?.content ?? '',
      toolCalls: toolCalls,
      totalTokens: dto.totalTokens,
    );
  });

  ///------------------ Structured Response (tools OFF, format ON) --------------------
  @override
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
  }) => safeCall(() async {
    final messages = _buildMessagesPayload(
      history: history,
      userText: userText,
      toolResults: toolResults,
      goal: userGoal,
      activityLevel: userActivityLevel,
      weight: userWeight,
      height: userHeight,
      name: userName,
      age: userAge,
      gender: userGender,
    );

    final dto = await _remoteDataSource.chat(
      OllamaChatRequestDto(
        messages: [
          ...messages,
          OllamaMessageDto(
            role: 'user',
            content:
                'Convert your previous answer to JSON matching this schema '
                'exactly: ${jsonEncode(ChatPromptsAndSchemas.formatSchema)}. '
                'Return only the JSON object, with no extra text.',
          ),
        ],
        format: ChatPromptsAndSchemas.formatSchema,
        options: OllamaConstants.structuredOptions,
      ),
    );

    final content = dto.message?.content ?? '';
    final turnBDto = _parseStructuredContent(content);

    return CoachStructuredResultEntity(
      reply: turnBDto.reply,
      exerciseIds: turnBDto.exerciseIds,
      mealIds: turnBDto.mealIds,
      totalTokens: dto.totalTokens,
    );
  });

  SmartCoachTurnBContentDto _parseStructuredContent(String content) {
    final json = _decodeJsonObject(content);
    final reply = json?['reply'];
    if (json == null || reply is! String) {
      return SmartCoachTurnBContentDto(
        reply: _replyFromTruncatedJson(content) ?? content.trim(),
      );
    }
    return SmartCoachTurnBContentDto(
      reply: reply,
      exerciseIds: _idsFrom(json['exercise_ids']),
      mealIds: _idsFrom(json['meal_ids']),
    );
  }

  String? _replyFromTruncatedJson(String content) {
    final match = RegExp(
      r'"reply"\s*:\s*"((?:[^"\\]|\\.)*)',
    ).firstMatch(content);
    final raw = match?.group(1);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return (jsonDecode('"$raw"') as String).trim();
    } on FormatException {
      return raw.replaceAll(r'\n', '\n').replaceAll(r'\"', '"').trim();
    }
  }

  List<String> _idsFrom(Object? value) => value is List
      ? value.where((id) => id != null).map((id) => id.toString()).toList()
      : const [];

  Map<String, dynamic>? _decodeJsonObject(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end <= start) return null;
    try {
      final decoded = jsonDecode(content.substring(start, end + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  ///------------------ Persistence --------------------
  @override
  Future<BaseResponse<ChatSessionEntity>> createSession(
    ChatSessionEntity session,
  ) => safeCall(() async {
    await _fireStoreDataSource.saveSession(ChatSessionDto.fromEntity(session));
    return session;
  });

  @override
  Future<BaseResponse<void>> saveMessage(
    String sessionId,
    ChatMessageEntity msg,
    int tokens,
  ) => safeCall(
    () => _fireStoreDataSource.saveMessage(
      sessionId,
      ChatMessageDto.fromEntity(msg, tokens),
    ),
  );

  @override
  Future<BaseResponse<List<ChatMessageEntity>>> getMessages(String sessionId) =>
      safeCall(() async {
        final dtos = await _fireStoreDataSource.getMessages(sessionId);
        return dtos.map((d) => d.toEntity()).toList();
      });

  @override
  Future<BaseResponse<List<ChatSessionEntity>>> getPreviousSessions({
    int limit = 20,
    int? lastUpdatedAtMillis,
  }) => safeCall(() async {
    final dtos = await _fireStoreDataSource.getSessions(
      limit: limit,
      lastUpdatedAtMillis: lastUpdatedAtMillis,
    );
    return dtos.map((d) => d.toEntity()).toList();
  });

  // ------------------ Helper Mappers ------------------
  List<OllamaMessageDto> _buildMessagesPayload({
    required List<ChatMessageEntity> history,
    required String userText,
    required List<ToolExecutionResultEntity> toolResults,
    String? goal,
    String? activityLevel,
    num? weight,
    num? height,
    String? name,
    int? age,
    String? gender,
  }) {
    final list = <OllamaMessageDto>[
      OllamaMessageDto(
        role: 'system',
        content: ChatPromptsAndSchemas.buildSystemPrompt(
          goal: goal,
          activityLevel: activityLevel,
          weight: weight,
          height: height,
          name: name,
          age: age,
          gender: gender,
        ),
      ),
      ...history.map(
        (m) => OllamaMessageDto(
          role: m.sender == ChatSender.user ? 'user' : 'assistant',
          content: m.text,
        ),
      ),
      OllamaMessageDto(role: 'user', content: userText),
    ];

    // ✅ Each tool execution result is a SEPARATE message with tool_name & tool_call_id
    for (final tr in toolResults) {
      list.add(
        OllamaMessageDto(
          role: 'tool',
          toolName: tr.toolName,
          toolCallId: tr.toolCallId,
          content: tr.content,
        ),
      );
    }

    return list;
  }

  CoachToolCallEntity? _mapToolCallDtoToEntity(OllamaToolCallDto dto) {
    final name = dto.function?.name;
    final args = dto.function?.arguments ?? {};
    final id =
        dto.id ?? name ?? 'call_${DateTime.now().millisecondsSinceEpoch}';

    if (name == 'search_exercises') {
      return SearchExercisesToolCall(
        toolCallId: id,
        muscleGroup: args['muscle_group'] as String?,
        equipment: args['equipment'] as String?,
        maxDifficulty: args['max_difficulty'] as int?,
        limit: (args['limit'] as int?) ?? 6,
      );
    } else if (name == 'search_meals') {
      return SearchMealsToolCall(
        toolCallId: id,
        category: args['category'] as String?,
        minProtein: (args['min_protein'] as num?)?.toDouble(),
        maxKcal: (args['max_kcal'] as num?)?.toDouble(),
        limit: (args['limit'] as int?) ?? 6,
      );
    }
    return null;
  }
}
