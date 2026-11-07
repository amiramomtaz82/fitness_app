import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_firestore_data_source.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:fitness_app/features/chat/data/models/chat_message_dto.dart';
import 'package:fitness_app/features/chat/data/models/chat_session_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_request_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_response_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_message_dto.dart';
import 'package:fitness_app/features/chat/data/repo_imp/chat_repo_imp.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/coach_turn_results.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockChatFirestoreDataSource extends Mock
    implements ChatFirestoreDataSource {}

void main() {
  late MockChatRemoteDataSource mockRemote;
  late MockChatFirestoreDataSource mockFirestore;
  late ChatRepoImp repo;

  const tOllamaResponse = OllamaChatResponseDto(
    model: 'gemma4:31b',
    message: OllamaMessageDto(role: 'assistant', content: 'Coach reply'),
    promptEvalCount: 10,
    evalCount: 20,
    done: true,
  );

  const tOllamaTurnBResponse = OllamaChatResponseDto(
    model: 'gemma4:31b',
    message: OllamaMessageDto(
      role: 'assistant',
      content:
          '{"reply": "Great job!", "exercise_ids": ["ex1"], "meal_ids": ["ml1"]}',
    ),
    promptEvalCount: 15,
    evalCount: 25,
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
    registerFallbackValue(const OllamaChatRequestDto(messages: []));
  });

  setUp(() {
    mockRemote = MockChatRemoteDataSource();
    mockFirestore = MockChatFirestoreDataSource();
    repo = ChatRepoImp(mockRemote, mockFirestore);
  });

  group('ChatRepoImp —', () {
    group('requestTurnA', () {
      final history = <ChatMessageEntity>[];
      const userText = 'Hello coach';

      test(
        'returns SuccessResponse with CoachTurnAResultEntity on success',
        () async {
          when(
            () => mockRemote.chat(any()),
          ).thenAnswer((_) async => tOllamaResponse);

          final result = await repo.requestTurnA(
            history: history,
            userText: userText,
          );

          expect(result, isA<SuccessResponse<CoachTurnAResultEntity>>());
          final data = (result as SuccessResponse<CoachTurnAResultEntity>).data;
          expect(data.text, equals('Coach reply'));
          expect(data.totalTokens, equals(30));
          verify(() => mockRemote.chat(any())).called(1);
        },
      );

      test('returns ErrorResponse on remote error', () async {
        when(
          () => mockRemote.chat(any()),
        ).thenThrow(Exception('Turn A Failed'));

        final result = await repo.requestTurnA(
          history: history,
          userText: userText,
        );

        expect(result, isA<ErrorResponse<CoachTurnAResultEntity>>());
      });
    });

    group('requestTurnB', () {
      final history = <ChatMessageEntity>[];
      const userText = 'Hello coach';

      test(
        'returns SuccessResponse with CoachTurnBResultEntity on success',
        () async {
          when(
            () => mockRemote.chat(any()),
          ).thenAnswer((_) async => tOllamaTurnBResponse);

          final result = await repo.requestTurnB(
            history: history,
            userText: userText,
            toolResults: const [],
          );

          expect(result, isA<SuccessResponse<CoachTurnBResultEntity>>());
          final data = (result as SuccessResponse<CoachTurnBResultEntity>).data;
          expect(data.reply, equals('Great job!'));
          expect(data.exerciseIds, equals(['ex1']));
          expect(data.mealIds, equals(['ml1']));
          expect(data.totalTokens, equals(40));
        },
      );

      test('returns ErrorResponse on remote error', () async {
        when(
          () => mockRemote.chat(any()),
        ).thenThrow(Exception('Turn B Failed'));

        final result = await repo.requestTurnB(
          history: history,
          userText: userText,
          toolResults: const [],
        );

        expect(result, isA<ErrorResponse<CoachTurnBResultEntity>>());
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
      test('returns mapped message entities on success', () async {
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

        final result = await repo.getMessages('s1');

        expect(result, isA<SuccessResponse<List<ChatMessageEntity>>>());
        final data = (result as SuccessResponse<List<ChatMessageEntity>>).data;
        expect(data.length, equals(1));
        expect(data.first.id, equals('m1'));
        expect(data.first.exerciseRefs, equals(['ex1']));
        expect(data.first.mealRefs, equals(['ml1']));
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
          () => mockFirestore.getSessions(
            limit: any(named: 'limit'),
            lastUpdatedAtMillis: any(named: 'lastUpdatedAtMillis'),
          ),
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
          () => mockFirestore.getSessions(
            limit: any(named: 'limit'),
            lastUpdatedAtMillis: any(named: 'lastUpdatedAtMillis'),
          ),
        ).thenThrow(Exception('Get Sessions Failed'));

        final result = await repo.getPreviousSessions();

        expect(result, isA<ErrorResponse<List<ChatSessionEntity>>>());
      });
    });
  });
}
