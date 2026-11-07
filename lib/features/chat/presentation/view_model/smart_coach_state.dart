import 'package:equatable/equatable.dart';

import '../../../../core/resource/resource.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';
import '../../domain/entites/chat_entities/chat_session_entity.dart';
import '../../domain/entites/chat_entities/token_status_entity.dart';

class SmartCoachState extends Equatable {
  final Resource<ProfileEntity> profileResource;
  final bool hasStarted;
  final String? sessionId;
  final List<ChatMessageEntity> messages;
  final bool isSending;
  final TokenStatusEntity tokenStatus;
  final Resource<List<ChatSessionEntity>> sessionsResource;
  final Resource<List<ChatMessageEntity>> conversationResource;

  const SmartCoachState({
    this.profileResource = const Resource.initial(),
    this.hasStarted = false,
    this.sessionId,
    this.messages = const [],
    this.isSending = false,
    this.tokenStatus = const TokenStatusEntity.initial(),
    this.sessionsResource = const Resource.initial(),
    this.conversationResource = const Resource.initial(),
  });

  ProfileEntity? get profile => profileResource.data;

  bool get canSend =>
      !isSending && !tokenStatus.isLocked && !conversationResource.isLoading;

  SmartCoachState copyWith({
    Resource<ProfileEntity>? profileResource,
    bool? hasStarted,
    String? sessionId,
    bool clearSessionId = false,
    List<ChatMessageEntity>? messages,
    bool? isSending,
    TokenStatusEntity? tokenStatus,
    Resource<List<ChatSessionEntity>>? sessionsResource,
    Resource<List<ChatMessageEntity>>? conversationResource,
  }) {
    return SmartCoachState(
      profileResource: profileResource ?? this.profileResource,
      hasStarted: hasStarted ?? this.hasStarted,
      sessionId: clearSessionId ? null : sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      tokenStatus: tokenStatus ?? this.tokenStatus,
      sessionsResource: sessionsResource ?? this.sessionsResource,
      conversationResource: conversationResource ?? this.conversationResource,
    );
  }

  @override
  List<Object?> get props => [
    profileResource,
    hasStarted,
    sessionId,
    messages,
    isSending,
    tokenStatus,
    sessionsResource,
    conversationResource,
  ];
}
