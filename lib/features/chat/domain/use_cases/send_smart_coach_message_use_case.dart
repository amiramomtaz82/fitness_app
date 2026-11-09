import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../../../../core/error/failures.dart';
import '../entites/catalog_entities/exercise_card_entity.dart';
import '../entites/catalog_entities/filter_params.dart';
import '../entites/catalog_entities/meal_card_entity.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../entites/chat_entities/coach_tool_call_entity.dart';
import '../entites/chat_entities/coach_turn_results.dart';
import '../entites/chat_entities/token_status_entity.dart';
import '../repo/catalog_repo.dart';
import '../repo/chat_repo.dart';

class SendMessageResult {
  final ChatMessageEntity assistantMessage;
  final TokenStatusEntity tokenStatus;

  const SendMessageResult({
    required this.assistantMessage,
    required this.tokenStatus,
  });
}

@injectable
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
    String? userName,
    int? userAge,
    String? userGender,
  }) async {
    // 1. Guard Token Limit
    if (currentSessionTokens >= TokenStatusEntity.lockThreshold) {
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

    // -------------------------------------------------------------------------
    // 3. Coach Response Loop: (tools ON, format OFF)
    // -------------------------------------------------------------------------
    final accumulatedToolResults = <ToolExecutionResultEntity>[];
    int totalTokens = currentSessionTokens;
    CoachResponseWithToolsEntity? latestCoachResponse;

    const maxIterations = 5; // Safety guard
    int iteration = 0;

    while (iteration < maxIterations) {
      iteration++;

      final responseWithToolsRes = await _chatRepo
          .requestCoachResponseWithTools(
            history: history,
            userText: userText,
            toolResults: accumulatedToolResults,
            userGoal: userGoal,
            userActivityLevel: userActivityLevel,
            userWeight: userWeight,
            userHeight: userHeight,
            userName: userName,
            userAge: userAge,
            userGender: userGender,
          );

      // ✅ Use switch pattern matching on BaseResponse
      switch (responseWithToolsRes) {
        case ErrorResponse(:final failure):
          return ErrorResponse(failure: failure);

        case SuccessResponse(:final data):
          latestCoachResponse = data;
          totalTokens += data.totalTokens;

          // If the model does not require any tool calls, exit loop!
          if (!data.hasToolCalls) {
            break;
          }

          // Execute each tool call requested by the model
          for (final toolCall in data.toolCalls) {
            final result = await _executeToolCall(toolCall);
            accumulatedToolResults.add(result);
          }
      }

      // Exit loop if coach response has no tool calls
      if (!latestCoachResponse.hasToolCalls) {
        break;
      }
    }

    // -------------------------------------------------------------------------
    // Fast-path: Answered directly without needing any tools
    // -------------------------------------------------------------------------
    if (accumulatedToolResults.isEmpty && latestCoachResponse != null) {
      final coachMsg = ChatMessageEntity(
        id: 'cch_${DateTime.now().millisecondsSinceEpoch}',
        sender: ChatSender.coach,
        text: latestCoachResponse.text,
        createdAt: DateTime.now(),
      );

      await _chatRepo.saveMessage(
        sessionId,
        coachMsg,
        latestCoachResponse.totalTokens,
      );

      return SuccessResponse(
        SendMessageResult(
          assistantMessage: coachMsg,
          tokenStatus: _calculateTokenStatus(totalTokens),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // 4. Structured Response: (tools OFF, format ON) -> Enforce structured JSON for UI Cards
    // -------------------------------------------------------------------------
    final structuredRes = await _chatRepo.requestStructuredCoachResponse(
      history: history,
      userText: userText,
      toolResults: accumulatedToolResults,
      userGoal: userGoal,
      userActivityLevel: userActivityLevel,
      userWeight: userWeight,
      userHeight: userHeight,
      userName: userName,
      userAge: userAge,
      userGender: userGender,
    );

    // ✅ Use switch pattern matching on BaseResponse
    switch (structuredRes) {
      case ErrorResponse(:final failure):
        return ErrorResponse(failure: failure);

      case SuccessResponse(:final data):
        totalTokens += data.totalTokens;

        // Fetch card entities for UI display
        final exercises = data.exerciseIds.isNotEmpty
            ? (await _catalogRepo.getExercisesByIds(data.exerciseIds)).data ??
                  []
            : const <ExerciseCardEntity>[];

        final meals = data.mealIds.isNotEmpty
            ? (await _catalogRepo.getMealsByIds(data.mealIds)).data ?? []
            : const <MealCardEntity>[];

        final coachMsg = ChatMessageEntity(
          id: 'cch_${DateTime.now().millisecondsSinceEpoch}',
          sender: ChatSender.coach,
          text: data.reply,
          createdAt: DateTime.now(),
          exerciseRefs: data.exerciseIds,
          mealRefs: data.mealIds,
          exercises: exercises,
          meals: meals,
        );

        await _chatRepo.saveMessage(sessionId, coachMsg, data.totalTokens);

        return SuccessResponse(
          SendMessageResult(
            assistantMessage: coachMsg,
            tokenStatus: _calculateTokenStatus(totalTokens),
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Tool Execution via Exhaustive Sealed Class Matching
  // ---------------------------------------------------------------------------
  Future<ToolExecutionResultEntity> _executeToolCall(
    CoachToolCallEntity toolCall,
  ) async {
    // ✅ Exhaustive Dart 3 switch on the sealed class
    switch (toolCall) {
      case SearchExercisesToolCall(
        :final toolCallId,
        :final toolName,
        :final muscleGroup,
        :final equipment,
        :final maxDifficulty,
      ):
        final res = await _catalogRepo.getExercises(
          ExerciseFilterParams(
            muscleGroup: muscleGroup,
            equipment: equipment,
            maxDifficulty: maxDifficulty,
          ),
        );

        // ✅ Handle error gracefully: Provide feedback to the AI model
        final content = switch (res) {
          SuccessResponse(:final data) when data.isNotEmpty =>
            _formatExerciseBlock(data),
          SuccessResponse() => 'No matching exercises found in the catalog.',
          ErrorResponse(:final failure) =>
            'Catalog search error: ${failure.serverMessage ?? 'Unknown error'}.',
        };

        return ToolExecutionResultEntity(
          toolCallId: toolCallId,
          toolName: toolName,
          content: content,
        );

      case SearchMealsToolCall(
        :final toolCallId,
        :final toolName,
        :final category,
        :final minProtein,
        :final maxKcal,
      ):
        final res = await _catalogRepo.getMeals(
          MealFilterParams(
            category: category,
            minProtein: minProtein,
            maxKcal: maxKcal,
          ),
        );

        // ✅ Handle error gracefully: Provide feedback to the AI model
        final content = switch (res) {
          SuccessResponse(:final data) when data.isNotEmpty => _formatMealBlock(
            data,
          ),
          SuccessResponse() => 'No matching meals found in the catalog.',
          ErrorResponse(:final failure) =>
            'Catalog search error: ${failure.serverMessage ?? 'Unknown error'}.',
        };

        return ToolExecutionResultEntity(
          toolCallId: toolCallId,
          toolName: toolName,
          content: content,
        );
    }
  }

  TokenStatusEntity _calculateTokenStatus(int totalTokens) =>
      TokenStatusEntity.fromTotalTokens(totalTokens);

  String _formatExerciseBlock(List<ExerciseCardEntity> items) {
    final lines = items
        .map((e) => 'id=${e.id} | ${e.name} | ${e.muscleGroup ?? '-'}')
        .join('\n');
    return 'CANDIDATE EXERCISES:\n$lines';
  }

  String _formatMealBlock(List<MealCardEntity> items) {
    final lines = items
        .map((m) => 'id=${m.id} | ${m.name} | ~${m.proteinG ?? 0}g protein')
        .join('\n');
    return 'CANDIDATE MEALS:\n$lines';
  }
}
