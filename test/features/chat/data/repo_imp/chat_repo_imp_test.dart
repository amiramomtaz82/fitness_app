import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_firestore_data_source.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:fitness_app/features/chat/data/models/chat_message_dto.dart';
import 'package:fitness_app/features/chat/data/models/chat_session_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_response_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_message_dto.dart';
import 'package:fitness_app/features/chat/data/repo_imp/chat_repo_imp.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/catalog_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockChatFirestoreDataSource extends Mock
    implements ChatFirestoreDataSource {}

class MockCatalogRepo extends Mock implements CatalogRepo {}

void main() {
  late MockChatRemoteDataSource mockRemote;
  late MockChatFirestoreDataSource mockFirestore;
  late MockCatalogRepo mockCatalog;
  late ChatRepoImp repo;

  const tOllamaResponse = OllamaChatResponseDto(
    model: 'gemma4:31b',
    message: OllamaMessageDto(role: 'assistant', content: 'Coach reply'),
    promptEvalCount: 10,
    evalCount: 20,
    done: true,
  );

  setUpAll(() {
    registerFallbackValue(
      const ChatMessageDto(
        id: 'fallback_msg',
        sender: 'user',
        text: 'msg',
        createdAtMillis: 0,
      ),
    );
  });

  setUp(() {
    mockRemote = MockChatRemoteDataSource();
    mockFirestore = MockChatFirestoreDataSource();
    mockCatalog = MockCatalogRepo();
    repo = ChatRepoImp(mockRemote, mockFirestore, mockCatalog);
  });

  group('ChatRepoImp —', () {
    group('requestTurnA', () {
      final messages = [
        {'role': 'user', 'content': 'Hello'},
      ];
      final tools = [
        {'type': 'function'},
      ];

      test('returns SuccessResponse on remote success', () async {
        when(
          () => mockRemote.chatWithTools(messages: messages, tools: tools),
        ).thenAnswer((_) async => tOllamaResponse);

        final result = await repo.requestTurnA(
          messages: messages,
          tools: tools,
        );

        expect(result, isA<SuccessResponse<OllamaChatResponseDto>>());
        expect((result as SuccessResponse).data, equals(tOllamaResponse));
      });

      test('returns ErrorResponse on remote error', () async {
        when(
          () => mockRemote.chatWithTools(
            messages: any(named: 'messages'),
            tools: any(named: 'tools'),
          ),
        ).thenThrow(Exception('Turn A Failed'));

        final result = await repo.requestTurnA(
          messages: messages,
          tools: tools,
        );

        expect(result, isA<ErrorResponse<OllamaChatResponseDto>>());
      });
    });

    group('requestTurnB', () {
      final messages = [
        {'role': 'user', 'content': 'Hello'},
      ];
      final format = {'type': 'object'};

      test('returns SuccessResponse on remote success', () async {
        when(
          () => mockRemote.chatWithFormat(messages: messages, formatSchema: format),
        ).thenAnswer((_) async => tOllamaResponse);

        final result = await repo.requestTurnB(
          messages: messages,
          formatSchema: format,
        );

        expect(result, isA<SuccessResponse<OllamaChatResponseDto>>());
        expect((result as SuccessResponse).data, equals(tOllamaResponse));
      });

      test('returns ErrorResponse on remote error', () async {
        when(
          () => mockRemote.chatWithFormat(
            messages: any(named: 'messages'),
            formatSchema: any(named: 'formatSchema'),
          ),
        ).thenThrow(Exception('Turn B Failed'));

        final result = await repo.requestTurnB(
          messages: messages,
          formatSchema: format,
        );

        expect(result, isA<ErrorResponse<OllamaChatResponseDto>>());
      });
    });

    group('saveMessage', () {
      final msg = ChatMessageEntity(
        id: 'm1',
        sender: ChatSender.user,
        text: 'hello',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );

      test('calls firestore dataSource with mapped DTO', () async {
        when(
          () => mockFirestore.saveMessage(any(), any()),
        ).thenAnswer((_) async {});

        final result = await repo.saveMessage('s1', msg, 50);

        expect(result, isA<SuccessResponse<void>>());
        verify(() => mockFirestore.saveMessage('s1', any())).called(1);
      });

      test('returns ErrorResponse when firestore fails', () async {
        when(
          () => mockFirestore.saveMessage(any(), any()),
        ).thenThrow(Exception('Firestore Write Failed'));

        final result = await repo.saveMessage('s1', msg, 50);

        expect(result, isA<ErrorResponse<void>>());
      });
    });

    group('getMessages', () {
      const exDto = ExerciseCardEntity(
        id: 'ex1',
        name: 'Squat',
        muscleGroup: 'Legs',
        difficulty: 'Novice',
      );
      const mlDto = MealCardEntity(
        id: 'ml1',
        name: 'Oatmeal',
        kcal: 350,
        proteinG: 15,
      );

      test('hydrates messages with exercise and meal cards', () async {
        const messageDto = ChatMessageDto(
          id: 'm1',
          sender: 'coach',
          text: 'workout plan',
          createdAtMillis: 1000,
          exerciseRefs: ['ex1'],
          mealRefs: ['ml1'],
        );

        when(
          () => mockFirestore.getMessages('s1'),
        ).thenAnswer((_) async => [messageDto]);
        when(
          () => mockCatalog.getExercisesByIds(['ex1']),
        ).thenAnswer((_) async => const SuccessResponse([exDto]));
        when(
          () => mockCatalog.getMealsByIds(['ml1']),
        ).thenAnswer((_) async => const SuccessResponse([mlDto]));

        final result = await repo.getMessages('s1');

        expect(result, isA<SuccessResponse<List<ChatMessageEntity>>>());
        final data = (result as SuccessResponse<List<ChatMessageEntity>>).data;
        expect(data.length, equals(1));
        expect(data.first.id, equals('m1'));
        expect(data.first.exercises, equals([exDto]));
        expect(data.first.meals, equals([mlDto]));
      });

      test('returns ErrorResponse when firestore throws', () async {
        when(
          () => mockFirestore.getMessages('s1'),
        ).thenThrow(Exception('Get Messages Failed'));

        final result = await repo.getMessages('s1');

        expect(result, isA<ErrorResponse<List<ChatMessageEntity>>>());
      });
    });

    group('getPreviousSessions', () {
      const sessionDto = ChatSessionDto(
        id: 's1',
        title: 'Session One',
        updatedAtMillis: 1000,
        totalTokens: 200,
      );

      test('returns mapped session entities on success', () async {
        when(
          () => mockFirestore.getSessions(),
        ).thenAnswer((_) async => [sessionDto]);

        final result = await repo.getPreviousSessions();

        expect(result, isA<SuccessResponse<List<ChatSessionEntity>>>());
        final data = (result as SuccessResponse<List<ChatSessionEntity>>).data;
        expect(data.length, equals(1));
        expect(data.first.id, equals('s1'));
        expect(data.first.title, equals('Session One'));
        expect(data.first.totalTokens, equals(200));
      });

      test('returns ErrorResponse when firestore throws', () async {
        when(
          () => mockFirestore.getSessions(),
        ).thenThrow(Exception('Get Sessions Failed'));

        final result = await repo.getPreviousSessions();

        expect(result, isA<ErrorResponse<List<ChatSessionEntity>>>());
      });
    });
  });
}
