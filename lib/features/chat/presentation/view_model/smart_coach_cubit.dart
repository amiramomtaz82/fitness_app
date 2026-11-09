import 'package:injectable/injectable.dart';

import '../../../../core/base/base_cubit.dart';
import '../../../../core/base/ui_events.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/resource/resource.dart';
import '../../../profile/domain/use_cases/get_profile_use_case.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';
import '../../domain/entites/chat_entities/chat_session_entity.dart';
import '../../domain/entites/chat_entities/token_status_entity.dart';
import '../../domain/use_cases/create_chat_session_use_case.dart';
import '../../domain/use_cases/get_chat_messages_use_case.dart';
import '../../domain/use_cases/get_previous_sessions_use_case.dart';
import '../../domain/use_cases/send_smart_coach_message_use_case.dart';
import 'smart_coach_intent.dart';
import 'smart_coach_state.dart';

@injectable
class SmartCoachCubit extends BaseCubit<SmartCoachState, BaseUiEvent> {
  final SendSmartCoachMessageUseCase _sendMessageUseCase;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final GetPreviousSessionsUseCase _getPreviousSessionsUseCase;
  final CreateChatSessionUseCase _createChatSessionUseCase;
  final GetProfileUseCase _getProfileUseCase;

  SmartCoachCubit(
    this._sendMessageUseCase,
    this._getChatMessagesUseCase,
    this._getPreviousSessionsUseCase,
    this._createChatSessionUseCase,
    this._getProfileUseCase,
  ) : super(const SmartCoachState());

  void doIntent(SmartCoachIntent intent) {
    switch (intent) {
      case LoadCoachIntent():
        _loadProfile();
      case GetStartedIntent():
        emit(state.copyWith(hasStarted: true));
      case SendMessageIntent(:final text):
        _sendMessage(text);
      case LoadPreviousSessionsIntent():
        _loadPreviousSessions();
      case SelectSessionIntent(:final session):
        _openSession(session);
      case StartNewChatIntent():
        _startNewChat();
    }
  }

  Future<void> _loadProfile() async {
    if (state.profileResource.isLoading || state.profileResource.isSuccess) {
      return;
    }
    emit(state.copyWith(profileResource: const Resource.loading()));
    final result = await _getProfileUseCase();
    if (isClosed) return;
    switch (result) {
      case SuccessResponse(:final data):
        emit(state.copyWith(profileResource: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(profileResource: Resource.error(failure)));
    }
  }

  Future<void> _sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || !state.canSend) return;

    final history = state.messages;
    final pendingMessage = ChatMessageEntity(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      sender: ChatSender.user,
      text: text,
      createdAt: DateTime.now(),
      isPending: true,
    );
    emit(
      state.copyWith(
        hasStarted: true,
        isSending: true,
        messages: [...history, pendingMessage],
      ),
    );

    final sessionId = state.sessionId ?? await _createSession(text);
    if (isClosed) return;
    if (sessionId == null) {
      emit(state.copyWith(isSending: false, messages: history));
      return;
    }

    final profile = state.profile;
    final result = await _sendMessageUseCase(
      sessionId: sessionId,
      userText: text,
      history: history,
      currentSessionTokens: state.tokenStatus.totalTokens,
      userGoal: _nonEmpty(profile?.goal),
      userActivityLevel: _nonEmpty(profile?.activityLevel),
      userWeight: _positive(profile?.weight),
      userHeight: _positive(profile?.height),
      userName: _nonEmpty(profile?.firstName),
      userAge: _positiveAge(profile?.age),
      userGender: _nonEmpty(profile?.gender),
    );
    if (isClosed || state.sessionId != sessionId) return;

    final sentMessage = pendingMessage.copyWith(isPending: false);
    switch (result) {
      case SuccessResponse(:final data):
        emit(
          state.copyWith(
            isSending: false,
            messages: [...history, sentMessage, data.assistantMessage],
            tokenStatus: data.tokenStatus,
          ),
        );
      case ErrorResponse(failure: final ChatTokenLimitFailure failure):
        emit(
          state.copyWith(
            isSending: false,
            messages: history,
            tokenStatus: TokenStatusEntity.fromTotalTokens(
              TokenStatusEntity.lockThreshold,
            ),
          ),
        );
        emitFailure(failure);
      case ErrorResponse(:final failure):
        emit(
          state.copyWith(isSending: false, messages: [...history, sentMessage]),
        );
        emitFailure(failure);
    }
  }

  Future<String?> _createSession(String firstMessage) async {
    final result = await _createChatSessionUseCase(firstMessage);
    if (isClosed) return null;
    switch (result) {
      case SuccessResponse(:final data):
        emit(state.copyWith(sessionId: data.id, sessionTitle: data.title));
        return data.id;
      case ErrorResponse(:final failure):
        emitFailure(failure);
        return null;
    }
  }

  Future<void> _loadPreviousSessions() async {
    if (state.sessionsResource.isLoading) return;
    emit(
      state.copyWith(
        sessionsResource: Resource.loading(data: state.sessionsResource.data),
      ),
    );
    final result = await _getPreviousSessionsUseCase();
    if (isClosed) return;
    switch (result) {
      case SuccessResponse(:final data):
        emit(state.copyWith(sessionsResource: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(
          state.copyWith(
            sessionsResource: Resource.error(
              failure,
              data: state.sessionsResource.data,
            ),
          ),
        );
        emitFailure(failure);
    }
  }

  Future<void> _openSession(ChatSessionEntity session) async {
    if (state.isSending || session.id == state.sessionId) return;

    emit(
      state.copyWith(
        hasStarted: true,
        sessionId: session.id,
        sessionTitle: session.title,
        messages: const [],
        tokenStatus: TokenStatusEntity.fromTotalTokens(session.totalTokens),
        conversationResource: const Resource.loading(),
      ),
    );
    final result = await _getChatMessagesUseCase(session.id);
    if (isClosed || state.sessionId != session.id) return;
    switch (result) {
      case SuccessResponse(:final data):
        emit(
          state.copyWith(
            messages: data,
            conversationResource: Resource.success(data),
          ),
        );
      case ErrorResponse(:final failure):
        emit(state.copyWith(conversationResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  void _startNewChat() {
    if (state.isSending) return;
    emit(
      state.copyWith(
        hasStarted: true,
        clearSessionId: true,
        messages: const [],
        tokenStatus: const TokenStatusEntity.initial(),
        conversationResource: const Resource.initial(),
      ),
    );
  }

  String? _nonEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value;

  num? _positive(num? value) => value == null || value <= 0 ? null : value;

  int? _positiveAge(int? value) => value == null || value <= 0 ? null : value;
}
