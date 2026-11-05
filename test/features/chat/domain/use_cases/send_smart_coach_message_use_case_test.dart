import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_response_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_message_dto.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/filter_params.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
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
    test('returns ChatTokenLimitFailure when currentSessionTokens >= 8000', () async {
      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Hello',
        history: const [],
        currentSessionTokens: 8000,
      );

      expect(result, isA<ErrorResponse<SendMessageResult>>());
      final failure = (result as ErrorResponse).failure;
      expect(failure, isA<ChatTokenLimitFailure>());
      verifyNever(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')));
    });

    test('returns direct assistant response and saves user/coach messages', () async {
      const aDto = OllamaChatResponseDto(
        message: OllamaMessageDto(role: 'assistant', content: 'You can do this!'),
        promptEvalCount: 50,
        evalCount: 30,
      );

      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => const SuccessResponse(aDto));

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
    });

    test('calculates token warning level when total tokens reach 7000', () async {
      const aDto = OllamaChatResponseDto(
        message: OllamaMessageDto(role: 'assistant', content: 'Almost full!'),
        promptEvalCount: 100,
        evalCount: 50,
      );

      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => const SuccessResponse(aDto));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Inspire me',
        history: const [],
        currentSessionTokens: 6900,
      );

      expect(result, isA<SuccessResponse<SendMessageResult>>());
      final data = (result as SuccessResponse<SendMessageResult>).data;
      expect(data.tokenStatus.level, equals(TokenLimitLevel.warning7k));
    });

    test('returns ErrorResponse when Turn A fails', () async {
      const failure = ServerFailure(serverMessage: 'Ollama server 500');
      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Hello',
        history: const [],
        currentSessionTokens: 0,
      );

      expect(result, isA<ErrorResponse<SendMessageResult>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });

    test('executes two-turn tool calling and hydrates catalog cards', () async {
      const aDto = OllamaChatResponseDto(
        message: OllamaMessageDto(
          role: 'assistant',
          toolCalls: [
            OllamaToolCallDto(
              function: OllamaFunctionCallDto(
                name: 'search_exercises',
                arguments: {'muscle_group': 'Chest'},
              ),
            ),
            OllamaToolCallDto(
              function: OllamaFunctionCallDto(
                name: 'search_meals',
                arguments: {'min_protein': 25.0},
              ),
            ),
          ],
        ),
        promptEvalCount: 20,
        evalCount: 30,
      );

      const bDto = OllamaChatResponseDto(
        message: OllamaMessageDto(
          role: 'assistant',
          content: '{"reply":"Try bench press and eggs!","exercise_ids":["bench-press"],"meal_ids":["egg-toast"]}',
        ),
        promptEvalCount: 40,
        evalCount: 20,
      );

      const exCard = ExerciseCardEntity(id: 'bench-press', name: 'Bench Press');
      const mlCard = MealCardEntity(id: 'egg-toast', name: 'Egg Toast');

      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => const SuccessResponse(aDto));
      when(() => mockCatalogRepo.getExercises(any()))
          .thenAnswer((_) async => const SuccessResponse([exCard]));
      when(() => mockCatalogRepo.getMeals(any()))
          .thenAnswer((_) async => const SuccessResponse([mlCard]));
      when(() => mockChatRepo.requestTurnB(messages: any(named: 'messages'), formatSchema: any(named: 'formatSchema')))
          .thenAnswer((_) async => const SuccessResponse(bDto));
      when(() => mockCatalogRepo.getExercisesByIds(['bench-press']))
          .thenAnswer((_) async => const SuccessResponse([exCard]));
      when(() => mockCatalogRepo.getMealsByIds(['egg-toast']))
          .thenAnswer((_) async => const SuccessResponse([mlCard]));

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
      verify(() => mockChatRepo.saveMessage(tSessionId, any(), 110)).called(1);
    });

    test('returns ErrorResponse when Turn B fails', () async {
      const aDto = OllamaChatResponseDto(
        message: OllamaMessageDto(
          role: 'assistant',
          toolCalls: [
            OllamaToolCallDto(
              function: OllamaFunctionCallDto(
                name: 'search_exercises',
                arguments: {'muscle_group': 'Glutes'},
              ),
            ),
          ],
        ),
      );

      const failure = ServerFailure(serverMessage: 'Turn B timeout');
      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => const SuccessResponse(aDto));
      when(() => mockCatalogRepo.getExercises(any()))
          .thenAnswer((_) async => const SuccessResponse([]));
      when(() => mockChatRepo.requestTurnB(messages: any(named: 'messages'), formatSchema: any(named: 'formatSchema')))
          .thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(
        sessionId: tSessionId,
        userText: 'Glute exercises',
        history: const [],
        currentSessionTokens: 0,
      );

      expect(result, isA<ErrorResponse<SendMessageResult>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });

    test('injects user profile metadata into system prompt', () async {
      const aDto = OllamaChatResponseDto(
        message: OllamaMessageDto(role: 'assistant', content: 'Personalized!'),
      );

      when(() => mockChatRepo.saveMessage(any(), any(), any()))
          .thenAnswer((_) async => const SuccessResponse(null));
      when(() => mockChatRepo.requestTurnA(messages: any(named: 'messages'), tools: any(named: 'tools')))
          .thenAnswer((_) async => const SuccessResponse(aDto));

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

      final captured = verify(
        () => mockChatRepo.requestTurnA(
          messages: captureAny(named: 'messages'),
          tools: any(named: 'tools'),
        ),
      ).captured.first as List<Map<String, dynamic>>;

      final systemContent = captured.first['content'] as String;
      expect(systemContent, contains('Goal: fat_loss'));
      expect(systemContent, contains('Level: moderate'));
      expect(systemContent, contains('Weight: 80kg'));
      expect(systemContent, contains('Height: 175cm'));
    });
  });
}
