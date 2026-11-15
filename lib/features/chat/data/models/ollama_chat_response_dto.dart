import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/catalog_entities/exercise_card_entity.dart';
import '../../domain/entites/catalog_entities/meal_card_entity.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';
import 'ollama_message_dto.dart';

part 'ollama_chat_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class OllamaChatResponseDto {
  final String? model;
  final OllamaMessageDto? message;
  @JsonKey(name: 'prompt_eval_count')
  final int? promptEvalCount;
  @JsonKey(name: 'prompt_eval_cached_count')
  final int? promptEvalCachedCount;
  @JsonKey(name: 'eval_count')
  final int? evalCount;
  final bool? done;

  const OllamaChatResponseDto({
    this.model,
    this.message,
    this.promptEvalCount,
    this.promptEvalCachedCount,
    this.evalCount,
    this.done,
  });

  factory OllamaChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaChatResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaChatResponseDtoToJson(this);

  int get totalTokens => (promptEvalCount ?? 0) + (evalCount ?? 0);

  int get cachedTokens => promptEvalCachedCount ?? 0;

  bool get hasToolCalls =>
      message?.toolCalls != null && message!.toolCalls!.isNotEmpty;

  /// Directly converts coach direct response to Domain Entity
  ChatMessageEntity toEntity({
    required String id,
    required DateTime createdAt,
    List<ExerciseCardEntity> exercises = const [],
    List<MealCardEntity> meals = const [],
  }) {
    return ChatMessageEntity(
      id: id,
      sender: ChatSender.coach,
      text: message?.content ?? '',
      createdAt: createdAt,
      exercises: exercises,
      meals: meals,
    );
  }
}
