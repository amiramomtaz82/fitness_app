import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/catalog_entities/exercise_card_entity.dart';
import '../../domain/entites/catalog_entities/meal_card_entity.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';

part 'chat_message_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatMessageDto {
  final String id;
  final String sender; // 'user' or 'coach'
  final String text;
  final int createdAtMillis;
  final List<String> exerciseRefs;
  final List<String> mealRefs;
  final int tokens;

  const ChatMessageDto({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAtMillis,
    this.exerciseRefs = const [],
    this.mealRefs = const [],
    this.tokens = 0,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageDtoToJson(this);

  /// Converts DTO to Domain Entity directly without external mapper
  ChatMessageEntity toEntity({
    List<ExerciseCardEntity> exercises = const [],
    List<MealCardEntity> meals = const [],
    bool isPending = false,
  }) {
    return ChatMessageEntity(
      id: id,
      sender: sender == 'user' ? ChatSender.user : ChatSender.coach,
      text: text,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      exercises: exercises,
      meals: meals,
      isPending: isPending,
    );
  }

  /// Converts Domain Entity to Firestore DTO
  factory ChatMessageDto.fromEntity(ChatMessageEntity entity, int tokens) {
    return ChatMessageDto(
      id: entity.id,
      sender: entity.sender == ChatSender.user ? 'user' : 'coach',
      text: entity.text,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      exerciseRefs: entity.exercises.map((e) => e.id).toList(),
      mealRefs: entity.meals.map((m) => m.id).toList(),
      tokens: tokens,
    );
  }
}