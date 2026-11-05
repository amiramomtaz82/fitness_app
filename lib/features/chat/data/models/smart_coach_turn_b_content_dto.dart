import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/catalog_entities/exercise_card_entity.dart';
import '../../domain/entites/catalog_entities/meal_card_entity.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';

part 'smart_coach_turn_b_content_dto.g.dart';

@JsonSerializable()
class SmartCoachTurnBContentDto {
  final String reply;
  @JsonKey(name: 'exercise_ids', defaultValue: [])
  final List<String> exerciseIds;
  @JsonKey(name: 'meal_ids', defaultValue: [])
  final List<String> mealIds;

  const SmartCoachTurnBContentDto({
    required this.reply,
    this.exerciseIds = const [],
    this.mealIds = const [],
  });

  factory SmartCoachTurnBContentDto.fromJson(Map<String, dynamic> json) =>
      _$SmartCoachTurnBContentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SmartCoachTurnBContentDtoToJson(this);

  /// Directly converts Turn B structured output to Domain Entity with catalog items
  ChatMessageEntity toEntity({
    required String id,
    required DateTime createdAt,
    List<ExerciseCardEntity> exercises = const [],
    List<MealCardEntity> meals = const [],
  }) {
    return ChatMessageEntity(
      id: id,
      sender: ChatSender.coach,
      text: reply,
      createdAt: createdAt,
      exercises: exercises,
      meals: meals,
    );
  }
}