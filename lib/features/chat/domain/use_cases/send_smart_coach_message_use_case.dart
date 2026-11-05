import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/ollama_chat_response_dto.dart';
import '../../data/models/smart_coach_turn_b_content_dto.dart';
import '../entites/catalog_entities/exercise_card_entity.dart';
import '../entites/catalog_entities/filter_params.dart';
import '../entites/catalog_entities/meal_card_entity.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../entites/chat_entities/token_status_entity.dart';
import '../repo/catalog_repo.dart';
import '../repo/chat_repo.dart';

class SendMessageResult {
  final ChatMessageEntity assistantMessage;
  final TokenStatusEntity tokenStatus;
  const SendMessageResult({required this.assistantMessage, required this.tokenStatus});
}

@lazySingleton
class SendSmartCoachMessageUseCase {
  final ChatRepo _chatRepo;
  final CatalogRepo _catalogRepo;

  const SendSmartCoachMessageUseCase(this._chatRepo, this._catalogRepo);

  Future<BaseResponse<SendMessageResult>> call({
    required String sessionId,
    required String userText,
    required List<ChatMessageEntity> history,
    required int currentSessionTokens,
    String? userGoal,
    String? userActivityLevel,
    num? userWeight,
    num? userHeight,
  }) async {
    // 1. Guard Token Limit
    if (currentSessionTokens >= 8000) {
      return ErrorResponse(failure: const ChatTokenLimitFailure());
    }

    // 2. Persist user message
    final userMsg = ChatMessageEntity(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.user,
      text: userText,
      createdAt: DateTime.now(),
    );
    await _chatRepo.saveMessage(sessionId, userMsg, 0);

    // 3. Turn A Execution
    final messagesPayload = _buildInitialPayload(
      history,
      userText,
      goal: userGoal,
      activityLevel: userActivityLevel,
      weight: userWeight,
      height: userHeight,
    );
    final turnARes = await _chatRepo.requestTurnA(
      messages: messagesPayload,
      tools: _toolsSchema,
    );

    if (turnARes is ErrorResponse<OllamaChatResponseDto>) {
      return ErrorResponse(failure: turnARes.failure);
    }

    final aDto = (turnARes as SuccessResponse<OllamaChatResponseDto>).data;

    // Fast-path: Answered directly without needing tool calling
    if (!aDto.hasToolCalls) {
      return _handleDirectResponse(sessionId, aDto, currentSessionTokens);
    }

    // Two-turn tool-calling path
    return _handleToolCallingTurn(
      sessionId: sessionId,
      aDto: aDto,
      messagesPayload: messagesPayload,
      currentTokens: currentSessionTokens,
    );
  }
///======================path one=========================
  ///(1-convert message to entity and 2- save it with total tokens to fire store
  ///3-return message to user and new token status)
  Future<BaseResponse<SendMessageResult>> _handleDirectResponse(
      String sessionId,
      OllamaChatResponseDto aDto,
      int currentTokens,
      ) async {
    final totalTokens = currentTokens + aDto.totalTokens;
    final coachMsg = aDto.toEntity(
      id: 'cch_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    await _chatRepo.saveMessage(sessionId, coachMsg, aDto.totalTokens);
    return SuccessResponse(
      SendMessageResult(
        assistantMessage: coachMsg,
        tokenStatus: _calculateTokenStatus(totalTokens),
      ),
    );
  }
///========================= path two ==================================================
  Future<BaseResponse<SendMessageResult>> _handleToolCallingTurn({
    required String sessionId,
    required OllamaChatResponseDto aDto,
    required List<Map<String, dynamic>> messagesPayload,
    required int currentTokens,
  }) async {
    final candidateBlocks = <String>[];
    final toolCalls = aDto.message!.toolCalls!;

    // 1. Loop through tool calls requested by the AI & query local database
    for (final call in toolCalls) {
      final fn = call.function?.name;
      final args = call.function?.arguments ?? {};
      await _processToolCall(fn, args, candidateBlocks);
    }

    // 2. Add search results to message history with role: 'tool'
    messagesPayload.add(aDto.message!.toJson());
    messagesPayload.add({'role': 'tool', 'content': candidateBlocks.join('\n\n')});

    // 3. Execute Turn B: Send search results to AI and enforce JSON output schema
    final turnBRes = await _chatRepo.requestTurnB(
      messages: messagesPayload,
      formatSchema: _formatSchema,
    );

    if (turnBRes is ErrorResponse<OllamaChatResponseDto>) {
      return ErrorResponse(failure: turnBRes.failure);
    }

    // 4. Parse JSON response to extract exercise_ids & meal_ids
    final bDto = (turnBRes as SuccessResponse<OllamaChatResponseDto>).data;
    final totalTurnTokens = aDto.totalTokens + bDto.totalTokens;
    final parsedJson = jsonDecode(bDto.message?.content ?? '{}') as Map<String, dynamic>;
    final turnBDto = SmartCoachTurnBContentDto.fromJson(parsedJson);

    // 5. Hydrate: Fetch complete exercise & meal card entities from database by ID
    final exercises = turnBDto.exerciseIds.isNotEmpty
        ? (await _catalogRepo.getExercisesByIds(turnBDto.exerciseIds)).data ?? []
        : const <ExerciseCardEntity>[];
    final meals = turnBDto.mealIds.isNotEmpty
        ? (await _catalogRepo.getMealsByIds(turnBDto.mealIds)).data ?? []
        : const <MealCardEntity>[];

    final coachMsg = turnBDto.toEntity(
      id: 'cch_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      exercises: exercises,
      meals: meals,
    );

    // 6. Save final coach message to DB & return result to UI
    await _chatRepo.saveMessage(sessionId, coachMsg, totalTurnTokens);
    return SuccessResponse(
      SendMessageResult(
        assistantMessage: coachMsg,
        tokenStatus: _calculateTokenStatus(currentTokens + totalTurnTokens),
      ),
    );
  }

  Future<void> _processToolCall(
      String? fn,
      Map<String, dynamic> args,
      List<String> candidateBlocks,
      ) async {
    if (fn == 'search_exercises') {
      final res = await _catalogRepo.getExercises(ExerciseFilterParams(
        muscleGroup: args['muscle_group'] as String?,
        equipment: args['equipment'] as String?,
        maxDifficulty: args['max_difficulty'] as int?,
      ));
      if (res is SuccessResponse<List<ExerciseCardEntity>>) {
        candidateBlocks.add(_formatExerciseBlock(res.data));
      }
    } else if (fn == 'search_meals') {
      final res = await _catalogRepo.getMeals(MealFilterParams(
        category: args['category'] as String?,
        minProtein: (args['min_protein'] as num?)?.toDouble(),
        maxKcal: (args['max_kcal'] as num?)?.toDouble(),
      ));
      if (res is SuccessResponse<List<MealCardEntity>>) {
        candidateBlocks.add(_formatMealBlock(res.data));
      }
    }
  }

  TokenStatusEntity _calculateTokenStatus(int totalTokens) {
    if (totalTokens >= 8000) {
      return TokenStatusEntity(totalTokens: totalTokens, level: TokenLimitLevel.locked8k);
    }
    if (totalTokens >= 7000) {
      return TokenStatusEntity(totalTokens: totalTokens, level: TokenLimitLevel.warning7k);
    }
    return TokenStatusEntity(totalTokens: totalTokens, level: TokenLimitLevel.normal);
  }

  String _formatExerciseBlock(List<ExerciseCardEntity> items) {
    final lines = items.map((e) => 'id=${e.id} | ${e.name} | ${e.muscleGroup ?? '-'}').join('\n');
    return 'CANDIDATE EXERCISES:\n$lines';
  }

  String _formatMealBlock(List<MealCardEntity> items) {
    final lines = items.map((m) => 'id=${m.id} | ${m.name} | ~${m.proteinG ?? 0}g protein').join('\n');
    return 'CANDIDATE MEALS:\n$lines';
  }

  List<Map<String, dynamic>> _buildInitialPayload(
    List<ChatMessageEntity> h,
    String userText, {
    String? goal,
    String? activityLevel,
    num? weight,
    num? height,
  }) {
    return [
      {
        'role': 'system',
        'content': _buildSystemPrompt(
          goal: goal,
          activityLevel: activityLevel,
          weight: weight,
          height: height,
        ),
      },
      ...h.map((m) => {'role': m.sender == ChatSender.user ? 'user' : 'assistant', 'content': m.text}),
      {'role': 'user', 'content': userText},
    ];
  }
///=======================Ai configuration ==================================================
  String _buildSystemPrompt({
    String? goal,
    String? activityLevel,
    num? weight,
    num? height,
  }) {
    final buffer = StringBuffer(_baseSystemPrompt);
    if (goal != null || activityLevel != null || weight != null || height != null) {
      buffer.write('\nUSER PROFILE: ');
      if (goal != null && goal.isNotEmpty) buffer.write('Goal: $goal. ');
      if (activityLevel != null && activityLevel.isNotEmpty) buffer.write('Level: $activityLevel. ');
      if (weight != null) buffer.write('Weight: ${weight}kg. ');
      if (height != null) buffer.write('Height: ${height}cm. ');
    }
    return buffer.toString();
  }

  static const String _baseSystemPrompt =
      'You are the in-app fitness coach for Fitness App. Reply in user locale. '
      'GROUND RULES: 1. Before recommending exercises or meals, call search_exercises or search_meals. '
      'Recommend ONLY items from candidate results. Never invent an id. CATALOG VOCABULARY: '
      'muscle_group: Abdominals | Chest | Glutes | Hamstrings | Shoulders. '
      'equipment: Bodyweight | Dumbbell | Barbell | Cable. '
      'max_difficulty: Beginner=1 | Novice=2 | Intermediate=3 | Advanced=4.';
//-----------------------------------------------------------------------------
  static const List<Map<String, dynamic>> _toolsSchema = [
    {
      'type': 'function',
      'function': {
        'name': 'search_exercises',
        'description': 'Find exercises in catalog using exact vocabulary values.',
        'parameters': {
          'type': 'object',
          'properties': {
            'muscle_group': {'type': 'string'},
            'equipment': {'type': 'string'},
            'max_difficulty': {'type': 'integer', 'minimum': 1, 'maximum': 8},
            'limit': {'type': 'integer', 'default': 6},
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'search_meals',
        'description': 'Find meals in catalog.',
        'parameters': {
          'type': 'object',
          'properties': {
            'category': {'type': 'string'},
            'min_protein': {'type': 'number'},
            'max_kcal': {'type': 'number'},
            'limit': {'type': 'integer', 'default': 6},
          },
        },
      },
    },
  ];
//----------------------------------------------------------------
  static const Map<String, dynamic> _formatSchema = {
    'type': 'object',
    'properties': {
      'reply': {'type': 'string'},
      'exercise_ids': {'type': 'array', 'items': {'type': 'string'}},
      'meal_ids': {'type': 'array', 'items': {'type': 'string'}},
    },
    'required': ['reply', 'exercise_ids', 'meal_ids'],
  };
}