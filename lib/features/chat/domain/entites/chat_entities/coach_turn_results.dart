import 'package:equatable/equatable.dart';
import 'coach_tool_call_entity.dart';

/// Entity returned to the UseCase when requesting coach response with tools enabled
class CoachResponseWithToolsEntity extends Equatable {
  final String text;
  final List<CoachToolCallEntity> toolCalls;
  final int totalTokens;

  const CoachResponseWithToolsEntity({
    required this.text,
    this.toolCalls = const [],
    required this.totalTokens,
  });

  bool get hasToolCalls => toolCalls.isNotEmpty;

  @override
  List<Object?> get props => [text, toolCalls, totalTokens];
}

/// Backward compatibility typedef
typedef CoachTurnAResultEntity = CoachResponseWithToolsEntity;

/// Entity representing the result of executing a tool call
class ToolExecutionResultEntity extends Equatable {
  final String toolCallId;
  final String toolName;
  final String content;

  const ToolExecutionResultEntity({
    required this.toolCallId,
    required this.toolName,
    required this.content,
  });

  @override
  List<Object?> get props => [toolCallId, toolName, content];
}

/// Entity returned to the UseCase for structured coach recommendation
class CoachStructuredResultEntity extends Equatable {
  final String reply;
  final List<String> exerciseIds;
  final List<String> mealIds;
  final int totalTokens;

  const CoachStructuredResultEntity({
    required this.reply,
    this.exerciseIds = const [],
    this.mealIds = const [],
    required this.totalTokens,
  });

  @override
  List<Object?> get props => [reply, exerciseIds, mealIds, totalTokens];
}

/// Backward compatibility typedef
typedef CoachTurnBResultEntity = CoachStructuredResultEntity;
