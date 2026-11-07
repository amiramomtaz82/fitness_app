import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/coach_tool_call_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/coach_turn_results.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/token_status_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/catalog_repo.dart';
import 'package:fitness_app/features/chat/domain/repo/chat_repo.dart';
import 'package:fitness_app/features/chat/domain/use_cases/send_smart_coach_message_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepo extends Mock implements ChatRepo {}

class MockCatalogRepo extends Mock implements CatalogRepo {}

void main() {
  late MockChatRepo mockChatRepo;
  late MockCatalogRepo mockCatalogRepo;
  late SendSmartCoachMessageUseCase useCase;

  const tSessionId = 's_100';

  setUpAll(() {
    registerFallbackValue(
      ChatMessageEntity(
        id: 'fb_msg',
        sender: ChatSender.user,
        text: 'fb',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(const ExerciseFilterParams());
    registerFallbackValue(const MealFilterParams());
  });

  setUp(() {
    mockChatRepo = MockChatRepo();
    mockCatalogRepo = MockCatalogRepo();
    useCase = SendSmartCoachMessageUseCase(mockChatRepo, mockCatalogRepo);
  });

  group('SendSmartCoachMessageUseCase —', () {
    test(
      'returns ChatTokenLimitFailure when currentSessionTokens >= 8000',
      () async {
        final result = await useCase(
          sessionId: tSessionId,
          userText: 'Hello',
          history: const [],
          currentSessionTokens: 8000,
        );

        expect(result, isA<ErrorResponse<SendMessageResult>>());
        final failure = (result as ErrorResponse).failure;
        expect(failure, isA<ChatTokenLimitFailure>());
        verifyNever(
          () => mockChatRepo.requestTurnA(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
          ),
        );
      },
    );

    test(
      'returns direct assistant response and saves user/coach messages',
      () async {
        const turnAResult = CoachTurnAResultEntity(
          text: 'You can do this!',
          toolCalls: [],
          totalTokens: 80,
        );

        when(
          () => mockChatRepo.saveMessage(any(), any(), any()),
        ).thenAnswer((_) async => const SuccessResponse(null));
        when(
          () => mockChatRepo.requestTurnA(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
            toolResults: any(named: 'toolResults'),
            userGoal: any(named: 'userGoal'),
            userActivityLevel: any(named: 'userActivityLevel'),
            userWeight: any(named: 'userWeight'),
            userHeight: any(named: 'userHeight'),
          ),
        ).thenAnswer((_) async => const SuccessResponse(turnAResult));

        final result = await useCase(
          sessionId: tSessionId,
          userText: 'Inspire me',
          history: const [],
          currentSessionTokens: 1000,
        );

        expect(result, isA<SuccessResponse<SendMessageResult>>());
        final data = (result as SuccessResponse<SendMessageResult>).data;
        expect(data.assistantMessage.text, equals('You can do this!'));
        expect(data.tokenStatus.level, equals(TokenLimitLevel.normal));
        verify(() => mockChatRepo.saveMessage(tSessionId, any(), 0)).called(1);
        verify(() => mockChatRepo.saveMessage(tSessionId, any(), 80)).called(1);
      },
    );

    test(
      'calculates token warning level when total tokens reach 7000',
      () async {
        const turnAResult = CoachTurnAResultEntity(
          text: 'Almost full!',
          toolCalls: [],
          totalTokens: 150,
        );

        when(
          () => mockChatRepo.saveMessage(any(), any(), any()),
        ).thenAnswer((_) async => const SuccessResponse(null));
        when(
          () => mockChatRepo.requestTurnA(
            history: any(named: 'history'),
            userText: any(named: 'userText'),
            toolResults: any(named: 'toolResults'),
            userGoal: any(named: 'userGoal'),
            userActivityLevel: any(named: 'userActivityLevel'),
            userWeight: any(named: 'userWeight'),
            userHeight: any(named: 'userHeight'),
          ),
        ).thenAnswer((_) async => const SuccessResponse(turnAResult));

        final result = await useCase(
          sessionId: tSessionId,
          userText: 'Inspire me',
          history: const [],
          currentSessionTokens: 6900,
        );

        expect(result, isA<SuccessResponse<SendMessageResult>>());
        final data = (result as SuccessResponse<SendMessageResult>).data;
        expect(data.tokenStatus.level, equals(TokenLimitLevel.warning7k));
      },
    );

    test('returns ErrorResponse when Turn A fails', () async {
      const failure = ServerFailure(serverMessage: 'Ollama server 500');
      when(
        () => mockChatRepo.saveMessage(any(), any(), any()),
      ).thenAnswer((_) async => const SuccessResponse(null));
      when(
        () => mockChatRepo.requestTurnA(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Hello',
        history: const [],
        currentSessionTokens: 0,
      );

      expect(result, isA<ErrorResponse<SendMessageResult>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });

    test('executes tool calling and hydrates catalog cards', () async {
      const toolCall1 = SearchExercisesToolCall(
        toolCallId: 'call_1',
        muscleGroup: 'Chest',
      );
      const toolCall2 = SearchMealsToolCall(
        toolCallId: 'call_2',
        minProtein: 25.0,
      );

      const turnAResultWithTools = CoachTurnAResultEntity(
        text: '',
        toolCalls: [toolCall1, toolCall2],
        totalTokens: 50,
      );

      const turnAResultFinished = CoachTurnAResultEntity(
        text: 'All tools done',
        toolCalls: [],
        totalTokens: 30,
      );

      const turnBResult = CoachTurnBResultEntity(
        reply: 'Try bench press and eggs!',
        exerciseIds: ['bench-press'],
        mealIds: ['egg-toast'],
        totalTokens: 60,
      );

      const exCard = ExerciseCardEntity(id: 'bench-press', name: 'Bench Press');
      const mlCard = MealCardEntity(id: 'egg-toast', name: 'Egg Toast');

      when(
        () => mockChatRepo.saveMessage(any(), any(), any()),
      ).thenAnswer((_) async => const SuccessResponse(null));

      var turnACallCount = 0;
      when(
        () => mockChatRepo.requestTurnA(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async {
        turnACallCount++;
        if (turnACallCount == 1) {
          return const SuccessResponse(turnAResultWithTools);
        }
        return const SuccessResponse(turnAResultFinished);
      });

      when(
        () => mockCatalogRepo.getExercises(any()),
      ).thenAnswer((_) async => const SuccessResponse([exCard]));
      when(
        () => mockCatalogRepo.getMeals(any()),
      ).thenAnswer((_) async => const SuccessResponse([mlCard]));
      when(
        () => mockChatRepo.requestTurnB(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(turnBResult));
      when(
        () => mockCatalogRepo.getExercisesByIds(['bench-press']),
      ).thenAnswer((_) async => const SuccessResponse([exCard]));
      when(
        () => mockCatalogRepo.getMealsByIds(['egg-toast']),
      ).thenAnswer((_) async => const SuccessResponse([mlCard]));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Chest workout and protein meal',
        history: const [],
        currentSessionTokens: 500,
      );

      expect(result, isA<SuccessResponse<SendMessageResult>>());
      final data = (result as SuccessResponse<SendMessageResult>).data;
      expect(data.assistantMessage.text, equals('Try bench press and eggs!'));
      expect(data.assistantMessage.exercises, equals([exCard]));
      expect(data.assistantMessage.meals, equals([mlCard]));
      verify(() => mockChatRepo.saveMessage(tSessionId, any(), 60)).called(1);
    });

    test('returns ErrorResponse when Turn B fails', () async {
      const toolCall1 = SearchExercisesToolCall(
        toolCallId: 'call_1',
        muscleGroup: 'Glutes',
      );
      const turnAResultWithTools = CoachTurnAResultEntity(
        text: '',
        toolCalls: [toolCall1],
        totalTokens: 30,
      );
      const turnAResultFinished = CoachTurnAResultEntity(
        text: '',
        toolCalls: [],
        totalTokens: 20,
      );

      const failure = ServerFailure(serverMessage: 'Turn B timeout');
      when(
        () => mockChatRepo.saveMessage(any(), any(), any()),
      ).thenAnswer((_) async => const SuccessResponse(null));

      var turnACallCount = 0;
      when(
        () => mockChatRepo.requestTurnA(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async {
        turnACallCount++;
        if (turnACallCount == 1) {
          return const SuccessResponse(turnAResultWithTools);
        }
        return const SuccessResponse(turnAResultFinished);
      });

      when(
        () => mockCatalogRepo.getExercises(any()),
      ).thenAnswer((_) async => const SuccessResponse([]));
      when(
        () => mockChatRepo.requestTurnB(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Glute exercises',
        history: const [],
        currentSessionTokens: 0,
      );

      expect(result, isA<ErrorResponse<SendMessageResult>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });

    test('forwards user profile metadata to chat repository', () async {
      const turnAResult = CoachTurnAResultEntity(
        text: 'Personalized!',
        toolCalls: [],
        totalTokens: 50,
      );

      when(
        () => mockChatRepo.saveMessage(any(), any(), any()),
      ).thenAnswer((_) async => const SuccessResponse(null));
      when(
        () => mockChatRepo.requestTurnA(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: any(named: 'userGoal'),
          userActivityLevel: any(named: 'userActivityLevel'),
          userWeight: any(named: 'userWeight'),
          userHeight: any(named: 'userHeight'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(turnAResult));

      await useCase(
        sessionId: tSessionId,
        userText: 'How should I start?',
        history: const [],
        currentSessionTokens: 0,
        userGoal: 'fat_loss',
        userActivityLevel: 'moderate',
        userWeight: 80,
        userHeight: 175,
      );

      verify(
        () => mockChatRepo.requestTurnA(
          history: any(named: 'history'),
          userText: any(named: 'userText'),
          toolResults: any(named: 'toolResults'),
          userGoal: 'fat_loss',
          userActivityLevel: 'moderate',
          userWeight: 80,
          userHeight: 175,
        ),
      ).called(1);
    });
  });
}
