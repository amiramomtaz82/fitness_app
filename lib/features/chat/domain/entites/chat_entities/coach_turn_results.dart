import 'package:equatable/equatable.dart';
import 'coach_tool_call_entity.dart';

/// Entity returned to the UseCase from Turn A (tools ON)
class CoachTurnAResultEntity extends Equatable {
  final String text;
  final List<CoachToolCallEntity> toolCalls;
  final int totalTokens;

  const CoachTurnAResultEntity({
    required this.text,
    this.toolCalls = const [],
    required this.totalTokens,
  });

  bool get hasToolCalls => toolCalls.isNotEmpty;

  @override
  List<Object?> get props => [text, toolCalls, totalTokens];
}

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

/// Entity returned to the UseCase from Turn B (format ON, structured JSON)
class CoachTurnBResultEntity extends Equatable {
  final String reply;
  final List<String> exerciseIds;
  final List<String> mealIds;
  final int totalTokens;

  const CoachTurnBResultEntity({
    required this.reply,
    this.exerciseIds = const [],
    this.mealIds = const [],
    required this.totalTokens,
  });

  @override
  List<Object?> get props => [reply, exerciseIds, mealIds, totalTokens];
}