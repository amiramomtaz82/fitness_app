import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/token_status_entity.dart';
import 'package:fitness_app/features/chat/domain/use_cases/create_chat_session_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_chat_messages_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_previous_sessions_use_case.dart';
import 'package:fitness_app/features/chat/domain/use_cases/send_smart_coach_message_use_case.dart';
import 'package:fitness_app/features/chat/presentation/view/screens/smart_coach_screen.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/chat_bubble.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/coach_chat_view.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/coach_recommendations.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/coach_welcome_view.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/previous_conversations_drawer.dart';
import 'package:fitness_app/features/chat/presentation/view_model/smart_coach_cubit.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';

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

  const tProfile = ProfileEntity(id: 'u1', firstName: 'Ahmed', goal: 'Gain');

  final tSession = ChatSessionEntity(
    id: 'ses_1',
    title: 'Chest workout',
    updatedAt: DateTime(2026, 1, 1),
    totalTokens: 0,
  );

  final tOldSession = ChatSessionEntity(
    id: 'ses_old',
    title: 'Leg day plan',
    updatedAt: DateTime(2026, 1, 1),
    totalTokens: 100,
  );

  final tCoachReply = ChatMessageEntity(
    id: 'cch_1',
    sender: ChatSender.coach,
    text: 'Try these moves',
    createdAt: DateTime(2026, 1, 1),
    exercises: const [ExerciseCardEntity(id: 'ex1', name: 'Bench Press')],
    meals: const [MealCardEntity(id: 'ml1', name: 'Chicken Rice')],
  );

  setUp(() {
    mockSend = MockSendSmartCoachMessageUseCase();
    mockGetMessages = MockGetChatMessagesUseCase();
    mockGetSessions = MockGetPreviousSessionsUseCase();
    mockCreateSession = MockCreateChatSessionUseCase();
    mockGetProfile = MockGetProfileUseCase();
    when(
      () => mockGetProfile(),
    ).thenAnswer((_) async => const SuccessResponse<ProfileEntity>(tProfile));
    when(
      () => mockCreateSession(any()),
    ).thenAnswer((_) async => SuccessResponse<ChatSessionEntity>(tSession));
    cubit = SmartCoachCubit(
      mockSend,
      mockGetMessages,
      mockGetSessions,
      mockCreateSession,
      mockGetProfile,
    );
    addTearDown(cubit.close);
  });

  void stubSend(TokenStatusEntity tokenStatus) {
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
    ).thenAnswer(
      (_) async => SuccessResponse(
        SendMessageResult(
          assistantMessage: tCoachReply,
          tokenStatus: tokenStatus,
        ),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpLocalizedScreen(
      tester,
      BlocProvider.value(value: cubit, child: const SmartCoachScreen()),
    );
  }

  Future<void> getStarted(WidgetTester tester) async {
    await tester.tap(find.text('Get Started'));
    await settleUi(tester);
  }

  Future<void> sendMessage(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('chat_input_field')), text);
    await tester.tap(find.byKey(const Key('chat_send_button')));
    await settleUi(tester);
  }

  group('SmartCoachScreen welcome view', () {
    testWidgets('greets the user by first name', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(CoachWelcomeView), findsOneWidget);
      expect(find.text('Hi Ahmed ,'), findsOneWidget);
      expect(find.text('I Am Your Smart Coach'), findsOneWidget);
      expect(find.text('How Can I Assist You Today ?'), findsOneWidget);
    });

    testWidgets('hides the greeting line when the profile fails', (
      tester,
    ) async {
      when(() => mockGetProfile()).thenAnswer(
        (_) async =>
            ErrorResponse<ProfileEntity>(failure: const NetworkFailure()),
      );

      await pumpScreen(tester);

      expect(find.textContaining('Hi'), findsNothing);
      expect(find.text('I Am Your Smart Coach'), findsOneWidget);
    });

    testWidgets('get started opens the chat with a coach greeting', (
      tester,
    ) async {
      await pumpScreen(tester);

      await getStarted(tester);

      expect(find.byType(CoachChatView), findsOneWidget);
      expect(find.text('Smart Coach'), findsOneWidget);
      expect(find.text('Hello How Can I Assist You Today ?'), findsOneWidget);
    });
  });

  group('SmartCoachScreen chat view', () {
    testWidgets('sends a message and shows the reply with cards', (
      tester,
    ) async {
      stubSend(const TokenStatusEntity.initial());
      await pumpScreen(tester);
      await getStarted(tester);

      await sendMessage(tester, 'Chest workout');

      expect(find.text('Chest workout'), findsOneWidget);
      expect(find.text('Try these moves'), findsOneWidget);
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.byType(CoachRecommendations), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Chicken Rice'), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const Key('chat_input_field')),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('shows the warning banner near the token limit', (
      tester,
    ) async {
      stubSend(TokenStatusEntity.fromTotalTokens(7100));
      await pumpScreen(tester);
      await getStarted(tester);

      await sendMessage(tester, 'Hi');

      expect(
        find.text(
          'You are approaching the conversation limit. Please start a new session soon.',
        ),
        findsOneWidget,
      );
      final send = tester.widget<IconButton>(
        find.byKey(const Key('chat_send_button')),
      );
      expect(send.onPressed, isNotNull);
    });

    testWidgets('locks input at the limit and new chat unlocks it', (
      tester,
    ) async {
      stubSend(TokenStatusEntity.fromTotalTokens(8100));
      await pumpScreen(tester);
      await getStarted(tester);

      await sendMessage(tester, 'Hi');

      expect(
        find.text('Conversation limit reached. Please start a new session.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('chat_send_button')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat_input_field')))
            .enabled,
        isFalse,
      );

      await tester.tap(find.byKey(const Key('banner_new_chat_button')));
      await settleUi(tester);

      expect(find.byType(ChatBubble), findsNothing);
      expect(find.text('Hello How Can I Assist You Today ?'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat_input_field')))
            .enabled,
        isTrue,
      );
    });
  });

  group('SmartCoachScreen previous conversations drawer', () {
    Future<void> openDrawer(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_previous_conversations')));
      await settleUi(tester, steps: 8);
    }

    testWidgets('lists sessions and opens the selected one', (tester) async {
      when(
        () => mockGetSessions(),
      ).thenAnswer((_) async => SuccessResponse([tOldSession]));
      when(
        () => mockGetMessages(tOldSession.id),
      ).thenAnswer((_) async => SuccessResponse([tCoachReply]));
      await pumpScreen(tester);
      await getStarted(tester);

      await openDrawer(tester);

      expect(find.byType(PreviousConversationsDrawer), findsOneWidget);
      expect(find.text('Previous Conversations'), findsOneWidget);
      expect(find.text('Leg day plan'), findsOneWidget);

      await tester.tap(find.text('Leg day plan'));
      await settleUi(tester, steps: 8);

      expect(find.byType(PreviousConversationsDrawer), findsNothing);
      expect(find.text('Try these moves'), findsOneWidget);
      expect(cubit.state.sessionId, tOldSession.id);
    });

    testWidgets('shows an empty message when there are no sessions', (
      tester,
    ) async {
      when(
        () => mockGetSessions(),
      ).thenAnswer((_) async => const SuccessResponse(<ChatSessionEntity>[]));
      await pumpScreen(tester);
      await getStarted(tester);

      await openDrawer(tester);

      expect(find.text('No previous conversations yet'), findsOneWidget);
    });

    testWidgets('offers retry when loading sessions fails', (tester) async {
      when(() => mockGetSessions()).thenAnswer(
        (_) async => ErrorResponse<List<ChatSessionEntity>>(
          failure: const NetworkFailure(),
        ),
      );
      await pumpScreen(tester);
      await getStarted(tester);

      await openDrawer(tester);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await settleUi(tester);

      verify(() => mockGetSessions()).called(2);
    });
  });
}
