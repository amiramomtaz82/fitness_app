import 'package:json_annotation/json_annotation.dart';
import '../../domain/entites/chat_entities/chat_session_entity.dart';

part 'chat_session_dto.g.dart';

@JsonSerializable()
class ChatSessionDto {
  final String id;
  final String title;
  final int updatedAtMillis;
  final int totalTokens;

  const ChatSessionDto({
    required this.id,
    required this.title,
    required this.updatedAtMillis,
    required this.totalTokens,
  });

  factory ChatSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionDtoToJson(this);

  /// Converts DTO to Domain Entity directly without external mapper
  ChatSessionEntity toEntity() {
    return ChatSessionEntity(
      id: id,
      title: title,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
      totalTokens: totalTokens,
    );
  }

  /// Converts Domain Entity to Firestore DTO
  factory ChatSessionDto.fromEntity(ChatSessionEntity entity) {
    return ChatSessionDto(
      id: entity.id,
      title: entity.title,
      updatedAtMillis: entity.updatedAt.millisecondsSinceEpoch,
      totalTokens: entity.totalTokens,
    );
  }
}
