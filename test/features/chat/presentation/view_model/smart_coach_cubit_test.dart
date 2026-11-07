import 'dart:async';

import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/token_status_entity.dart';
import 'package:fitness_app/features/chat/domain/use_cases/create_chat_session_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_chat_messages_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_previous_sessions_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/send_smart_coach_message_use_case.dart';
import 'package:fitness_app/features/chat/presentation/view_model/smart_coach_cubit.dart';
import 'package:fitness_app/features/chat/presentation/view_model/smart_coach_intent.dart';
import 'package:fitness_app/features/chat/presentation/view_model/smart_coach_state.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendSmartCoachMessageUseCase extends Mock
    implements SendSmartCoachMessageUseCase {}

class MockGetChatMessagesUseCase extends Mock
    implements GetChatMessagesUseCase {}

class MockGetPreviousSessionsUseCase extends Mock
    implements GetPreviousSessionsUseCase {}

class MockCreateChatSessionUseCase extends Mock
    implements CreateChatSessionUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  late MockSendSmartCoachMessageUseCase mockSend;
  late MockGetChatMessagesUseCase mockGetMessages;
  late MockGetPreviousSessionsUseCase mockGetSessions;
  late MockCreateChatSessionUseCase mockCreateSession;
  late MockGetProfileUseCase mockGetProfile;
  late SmartCoachCubit cubit;

  const tProfile = ProfileEntity(
    id: 'u1',
    firstName: 'Ahmed',
    goal: 'Lose Weight',
    activityLevel: 'level3',
    weight: 80,
    height: 175,
  );

  final tSession = ChatSessionEntity(
    id: 'ses_1',
    title: 'Chest workout',
    updatedAt: DateTime(2026, 1, 1),
    totalTokens: 0,
  );

  final tCoachMessage = ChatMessageEntity(
    id: 'cch_1',
    sender: ChatSender.coach,
    text: 'Try bench press',
    createdAt: DateTime(2026, 1, 1),
  );

  const tTokenStatus = TokenStatusEntity(
    totalTokens: 300,
    level: TokenLimitLevel.normal,
  );

  setUp(() {
    mockSend = MockSendSmartCoachMessageUseCase();
    mockGetMessages = MockGetChatMessagesUseCase();
    mockGetSessions = MockGetPreviousSessionsUseCase();
    mockCreateSession = MockCreateChatSessionUseCase();
    mockGetProfile = MockGetProfileUseCase();
    cubit = SmartCoachCubit(
      mockSend,
      mockGetMessages,
      mockGetSessions,
      mockCreateSession,
      mockGetProfile,
    );
  });

  tearDown(() => cubit.close());

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  void stubProfile() {
    when(
      () => mockGetProfile(),
    ).thenAnswer((_) async => const SuccessResponse<ProfileEntity>(tProfile));
  }

  void stubCreateSession() {
    when(
      () => mockCreateSession(any()),
    ).thenAnswer((_) async => SuccessResponse<ChatSessionEntity>(tSession));
  }

  void stubSend(BaseResponse<SendMessageResult> response) {
    when(
      () => mockSend(
        sessionId: any(named: 'sessionId'),
        userText: any(named: 'userText'),
        history: any(named: 'history'),
        currentSessionTokens: any(named: 'currentSessionTokens'),
        userGoal: any(named: 'userGoal'),
        userActivityLevel: any(named: 'userActivityLevel'),
        userWeight: any(named: 'userWeight'),
        userHeight: any(named: 'userHeight'),
      ),
    ).thenAnswer((_) async => response);
  }

  SuccessResponse<SendMessageResult> sendSuccess() => SuccessResponse(
    SendMessageResult(
      assistantMessage: tCoachMessage,
      tokenStatus: tTokenStatus,
    ),
  );

  Future<List<BaseUiEvent>> collectEvents(
    Future<void> Function() action,
  ) async {
    final events = <BaseUiEvent>[];
    final sub = cubit.eventStream.listen(events.add);
    await action();
    await flush();
    await sub.cancel();
    return events;
  }

  group('SmartCoachCubit initial state', () {
    test('starts on the welcome view with an empty conversation', () {
      expect(cubit.state, const SmartCoachState());
      expect(cubit.state.hasStarted, isFalse);
      expect(cubit.state.canSend, isTrue);
    });
  });

  group('LoadCoachIntent', () {
    test('loads the profile into state', () async {
      stubProfile();

      cubit.doIntent(const LoadCoachIntent());
      expect(cubit.state.profileResource.isLoading, isTrue);
      await flush();

      expect(cubit.state.profileResource, const Resource.success(tProfile));
      expect(cubit.state.profile, tProfile);
    });

    test('keeps the error without emitting a ui event', () async {
      const failure = NetworkFailure();
      when(
        () => mockGetProfile(),
      ).thenAnswer((_) async => ErrorResponse<ProfileEntity>(failure: failure));

      final events = await collectEvents(() async {
        cubit.doIntent(const LoadCoachIntent());
        await flush();
      });

      expect(cubit.state.profileResource.isError, isTrue);
      expect(events, isEmpty);
    });

    test('does not reload once the profile is loaded', () async {
      stubProfile();

      cubit.doIntent(const LoadCoachIntent());
      await flush();
      cubit.doIntent(const LoadCoachIntent());
      await flush();

      verify(() => mockGetProfile()).called(1);
    });
  });

  group('GetStartedIntent', () {
    test('moves to the chat view', () {
      cubit.doIntent(const GetStartedIntent());

      expect(cubit.state.hasStarted, isTrue);
    });
  });

  group('SendMessageIntent', () {
    test('ignores blank messages', () async {
      cubit.doIntent(const SendMessageIntent('   '));
      await flush();

      expect(cubit.state.messages, isEmpty);
      verifyNever(() => mockCreateSession(any()));
    });

    test('shows the user message as pending immediately', () async {
      final completer = Completer<BaseResponse<ChatSessionEntity>>();
      when(() => mockCreateSession(any())).thenAnswer((_) => completer.future);

      cubit.doIntent(const SendMessageIntent('  Chest workout  '));

      expect(cubit.state.isSending, isTrue);
      expect(cubit.state.canSend, isFalse);
      expect(cubit.state.messages.single.text, 'Chest workout');
      expect(cubit.state.messages.single.isPending, isTrue);
      expect(cubit.state.messages.single.sender, ChatSender.user);

      completer.complete(ErrorResponse(failure: const NetworkFailure()));
      await flush();
    });

    test('creates a session on the first message only', () async {
      stubCreateSession();
      stubSend(sendSuccess());

      cubit.doIntent(const SendMessageIntent('Chest workout'));
      await flush();
      cubit.doIntent(const SendMessageIntent('And legs?'));
      await flush();

      verify(() => mockCreateSession('Chest workout')).called(1);
      expect(cubit.state.sessionId, tSession.id);
    });

    test('appends the coach reply and updates tokens on success', () async {
      stubCreateSession();
      stubSend(sendSuccess());

      cubit.doIntent(const SendMessageIntent('Chest workout'));
      await flush();

      final messages = cubit.state.messages;
      expect(messages, hasLength(2));
      expect(messages.first.text, 'Chest workout');
      expect(messages.first.isPending, isFalse);
      expect(messages.last, tCoachMessage);
      expect(cubit.state.tokenStatus, tTokenStatus);
      expect(cubit.state.isSending, isFalse);
    });

    test('passes history, tokens and profile fields to the use case', () async {
      stubProfile();
      stubCreateSession();
      stubSend(sendSuccess());
      cubit.doIntent(const LoadCoachIntent());
      await flush();

      cubit.doIntent(const SendMessageIntent('Chest workout'));
      await flush();
      final historyAfterFirst = cubit.state.messages;
      cubit.doIntent(const SendMessageIntent('And legs?'));
      await flush();

      verify(
        () => mockSend(
          sessionId: tSession.id,
          userText: 'And legs?',
          history: historyAfterFirst,
          currentSessionTokens: tTokenStatus.totalTokens,
          userGoal: tProfile.goal,
          userActivityLevel: tProfile.activityLevel,
          userWeight: tProfile.weight,
          userHeight: tProfile.height,
        ),
      ).called(1);
    });

    test('sends null profile fields when the profile is empty', () async {
      stubCreateSession();
      stubSend(sendSuccess());

      cubit.doIntent(const SendMessageIntent('Hi'));
      await flush();

      verify(
        () => mockSend(
          sessionId: tSession.id,
          userText: 'Hi',
          history: const [],
          currentSessionTokens: 0,
          userGoal: null,
          userActivityLevel: null,
          userWeight: null,
          userHeight: null,
        ),
      ).called(1);
    });

    test('rolls back and reports when session creation fails', () async {
      const failure = NetworkFailure();
      when(() => mockCreateSession(any())).thenAnswer(
        (_) async => ErrorResponse<ChatSessionEntity>(failure: failure),
      );

      final events = await collectEvents(() async {
        cubit.doIntent(const SendMessageIntent('Hi'));
        await flush();
      });

      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.sessionId, isNull);
      expect(events.single, isA<ShowErrorSnackBarEvent>());
      verifyNever(
        () => mockSend(
          sessionId: any(named: 'sessionId'),
          userText: any(named: 'userText'),
          history: any(named: 'history'),
          currentSessionTokens: any(named: 'currentSessionTokens'),
        ),
      );
    });

    test('keeps the sent message and reports when the coach fails', () async {
      const failure = ServerFailure();
      stubCreateSession();
      stubSend(ErrorResponse(failure: failure));

      final events = await collectEvents(() async {
        cubit.doIntent(const SendMessageIntent('Hi'));
        await flush();
      });

      expect(cubit.state.messages.single.text, 'Hi');
      expect(cubit.state.messages.single.isPending, isFalse);
      expect(cubit.state.isSending, isFalse);
      expect((events.single as ShowErrorSnackBarEvent).failure, same(failure));
    });

    test('locks the chat on token limit failure', () async {
      stubCreateSession();
      stubSend(ErrorResponse(failure: const ChatTokenLimitFailure()));

      final events = await collectEvents(() async {
        cubit.doIntent(const SendMessageIntent('Hi'));
        await flush();
      });

      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.tokenStatus.isLocked, isTrue);
      expect(cubit.state.canSend, isFalse);
      expect(
        (events.single as ShowErrorSnackBarEvent).failure,
        isA<ChatTokenLimitFailure>(),
      );
    });

    test('ignores new messages while one is sending', () async {
      final completer = Completer<BaseResponse<ChatSessionEntity>>();
      when(() => mockCreateSession(any())).thenAnswer((_) => completer.future);

      cubit.doIntent(const SendMessageIntent('First'));
      cubit.doIntent(const SendMessageIntent('Second'));

      expect(cubit.state.messages.single.text, 'First');
      verify(() => mockCreateSession(any())).called(1);

      completer.complete(ErrorResponse(failure: const NetworkFailure()));
      await flush();
    });
  });

  group('LoadPreviousSessionsIntent', () {
    test('loads sessions into state', () async {
      when(
        () => mockGetSessions(),
      ).thenAnswer((_) async => SuccessResponse([tSession]));

      cubit.doIntent(const LoadPreviousSessionsIntent());
      expect(cubit.state.sessionsResource.isLoading, isTrue);
      await flush();

      expect(cubit.state.sessionsResource.data, [tSession]);
      expect(cubit.state.sessionsResource.isSuccess, isTrue);
    });

    test('keeps previous data and reports on failure', () async {
      when(
        () => mockGetSessions(),
      ).thenAnswer((_) async => SuccessResponse([tSession]));
      cubit.doIntent(const LoadPreviousSessionsIntent());
      await flush();

      when(() => mockGetSessions()).thenAnswer(
        (_) async => ErrorResponse<List<ChatSessionEntity>>(
          failure: const NetworkFailure(),
        ),
      );
      final events = await collectEvents(() async {
        cubit.doIntent(const LoadPreviousSessionsIntent());
        await flush();
      });

      expect(cubit.state.sessionsResource.isError, isTrue);
      expect(cubit.state.sessionsResource.data, [tSession]);
      expect(events.single, isA<ShowErrorSnackBarEvent>());
    });
  });

  group('SelectSessionIntent', () {
    final oldSession = ChatSessionEntity(
      id: 'ses_old',
      title: 'Old chat',
      updatedAt: DateTime(2026, 1, 1),
      totalTokens: 7200,
    );

    test('opens the session with its messages and token level', () async {
      when(
        () => mockGetMessages(oldSession.id),
      ).thenAnswer((_) async => SuccessResponse([tCoachMessage]));

      cubit.doIntent(SelectSessionIntent(oldSession));
      expect(cubit.state.conversationResource.isLoading, isTrue);
      expect(cubit.state.canSend, isFalse);
      await flush();

      expect(cubit.state.hasStarted, isTrue);
      expect(cubit.state.sessionId, oldSession.id);
      expect(cubit.state.messages, [tCoachMessage]);
      expect(cubit.state.tokenStatus.totalTokens, 7200);
      expect(cubit.state.tokenStatus.isWarning, isTrue);
      expect(cubit.state.canSend, isTrue);
    });

    test('reports when loading messages fails', () async {
      when(() => mockGetMessages(oldSession.id)).thenAnswer(
        (_) async => ErrorResponse<List<ChatMessageEntity>>(
          failure: const ServerFailure(),
        ),
      );

      final events = await collectEvents(() async {
        cubit.doIntent(SelectSessionIntent(oldSession));
        await flush();
      });

      expect(cubit.state.conversationResource.isError, isTrue);
      expect(cubit.state.messages, isEmpty);
      expect(events.single, isA<ShowErrorSnackBarEvent>());
    });

    test('does nothing when selecting the current session', () async {
      stubCreateSession();
      stubSend(sendSuccess());
      cubit.doIntent(const SendMessageIntent('Hi'));
      await flush();

      cubit.doIntent(SelectSessionIntent(tSession));
      await flush();

      verifyNever(() => mockGetMessages(any()));
    });
  });

  group('StartNewChatIntent', () {
    test('clears the conversation but keeps the profile', () async {
      stubProfile();
      stubCreateSession();
      stubSend(sendSuccess());
      cubit.doIntent(const LoadCoachIntent());
      await flush();
      cubit.doIntent(const SendMessageIntent('Hi'));
      await flush();

      cubit.doIntent(const StartNewChatIntent());

      expect(cubit.state.sessionId, isNull);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.tokenStatus, const TokenStatusEntity.initial());
      expect(cubit.state.hasStarted, isTrue);
      expect(cubit.state.profile, tProfile);
    });
  });
}
