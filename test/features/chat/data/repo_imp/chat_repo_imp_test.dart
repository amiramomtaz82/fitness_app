import 'package:fitness_app/core/contants/ollama_constants.dart';
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
    model: 'beam',
    message: OllamaMessageDto(role: 'assistant', content: 'Coach reply'),
    promptEvalCount: 10,
    evalCount: 20,
    done: true,
  );

  const tOllamaTurnBResponse = OllamaChatResponseDto(
    model: 'beam',
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
    registerFallbackValue(
      const ChatSessionDto(
        id: 'fallback_session',
        title: 'title',
        updatedAtMillis: 0,
        totalTokens: 0,
      ),
    );
  });

  setUp(() {
    mockRemote = MockChatRemoteDataSource();
    mockFirestore = MockChatFirestoreDataSource();
    repo = ChatRepoImp(mockRemote, mockFirestore);
  });

  group('ChatRepoImp —', () {
    group('requestCoachResponseWithTools', () {
      final history = <ChatMessageEntity>[];
      const userText = 'Hello coach';

      test(
        'returns SuccessResponse with CoachResponseWithToolsEntity on success',
        () async {
          when(
            () => mockRemote.chat(any()),
          ).thenAnswer((_) async => tOllamaResponse);

          final result = await repo.requestCoachResponseWithTools(
            history: history,
            userText: userText,
          );

          expect(result, isA<SuccessResponse<CoachResponseWithToolsEntity>>());
          final data =
              (result as SuccessResponse<CoachResponseWithToolsEntity>).data;
          expect(data.text, equals('Coach reply'));
          expect(data.totalTokens, equals(30));
          verify(() => mockRemote.chat(any())).called(1);
        },
      );

      test('puts the user profile in the system prompt', () async {
        when(
          () => mockRemote.chat(any()),
        ).thenAnswer((_) async => tOllamaResponse);

        await repo.requestCoachResponseWithTools(
          history: history,
          userText: userText,
          userName: 'Maha',
          userAge: 24,
          userGender: 'female',
          userGoal: 'Gain weight',
        );

        final request =
            verify(() => mockRemote.chat(captureAny())).captured.single
                as OllamaChatRequestDto;
        final system = request.messages.first;
        expect(system.role, equals('system'));
        expect(system.content, contains('Name: Maha.'));
        expect(system.content, contains('Age: 24.'));
        expect(system.content, contains('Gender: female.'));
        expect(system.content, contains('Goal: Gain weight.'));
      });

      test('returns ErrorResponse on remote error', () async {
        when(
          () => mockRemote.chat(any()),
        ).thenThrow(Exception('Turn A Failed'));

        final result = await repo.requestCoachResponseWithTools(
          history: history,
          userText: userText,
        );

        expect(result, isA<ErrorResponse<CoachResponseWithToolsEntity>>());
      });
    });

    group('requestStructuredCoachResponse', () {
      final history = <ChatMessageEntity>[];
      const userText = 'Hello coach';

      test(
        'returns SuccessResponse with CoachStructuredResultEntity on success',
        () async {
          when(
            () => mockRemote.chat(any()),
          ).thenAnswer((_) async => tOllamaTurnBResponse);

          final result = await repo.requestStructuredCoachResponse(
            history: history,
            userText: userText,
            toolResults: const [],
          );

          expect(result, isA<SuccessResponse<CoachStructuredResultEntity>>());
          final data =
              (result as SuccessResponse<CoachStructuredResultEntity>).data;
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

        final result = await repo.requestStructuredCoachResponse(
          history: history,
          userText: userText,
          toolResults: const [],
        );

        expect(result, isA<ErrorResponse<CoachStructuredResultEntity>>());
      });

      Future<CoachStructuredResultEntity> structuredWith(String content) async {
        when(() => mockRemote.chat(any())).thenAnswer(
          (_) async => OllamaChatResponseDto(
            model: 'beam',
            message: OllamaMessageDto(role: 'assistant', content: content),
            promptEvalCount: 5,
            evalCount: 5,
            done: true,
          ),
        );
        final result = await repo.requestStructuredCoachResponse(
          history: history,
          userText: userText,
          toolResults: const [],
        );
        return (result as SuccessResponse<CoachStructuredResultEntity>).data;
      }

      test('asks the model to convert its answer to JSON', () async {
        await structuredWith('{"reply": "ok", "exercise_ids": []}');

        final request =
            verify(() => mockRemote.chat(captureAny())).captured.single
                as OllamaChatRequestDto;
        expect(request.format, isNotNull);
        expect(request.messages.last.role, equals('user'));
        expect(request.messages.last.content, contains('JSON'));
      });

      test(
        'falls back to plain text when the model ignores the format',
        () async {
          final data = await structuredWith(
            'Here are some beginner-friendly exercises for you.',
          );

          expect(
            data.reply,
            equals('Here are some beginner-friendly exercises for you.'),
          );
          expect(data.exerciseIds, isEmpty);
          expect(data.mealIds, isEmpty);
        },
      );

      test('extracts JSON wrapped in extra text', () async {
        final data = await structuredWith(
          'Sure!\n```json\n{"reply": "Try these", "exercise_ids": ["ex1"], '
          '"meal_ids": []}\n```',
        );

        expect(data.reply, equals('Try these'));
        expect(data.exerciseIds, equals(['ex1']));
      });

      test('accepts numeric ids and missing lists', () async {
        final data = await structuredWith(
          '{"reply": "Try these", "exercise_ids": [12, 7]}',
        );

        expect(data.exerciseIds, equals(['12', '7']));
        expect(data.mealIds, isEmpty);
      });

      test('gives the structured step a larger output budget', () async {
        await structuredWith('{"reply": "ok"}');

        final request =
            verify(() => mockRemote.chat(captureAny())).captured.single
                as OllamaChatRequestDto;
        expect(request.options, equals(OllamaConstants.structuredOptions));
      });

      test('shows only the reply text when the JSON is cut off', () async {
        final data = await structuredWith(
          '{"reply":"Try these:\\nGlute Bridge and \\"Bird Dog\\".",'
          '"exercise_ids":["bodyweight-glute',
        );

        expect(data.reply, equals('Try these:\nGlute Bridge and "Bird Dog".'));
        expect(data.exerciseIds, isEmpty);
      });

      test('shows the reply text when cut off inside the reply', () async {
        final data = await structuredWith('{"reply":"Here are some moves for');

        expect(data.reply, equals('Here are some moves for'));
      });

      test('falls back to plain text when JSON has no reply', () async {
        final data = await structuredWith('{"exercise_ids": ["ex1"]}');

        expect(data.reply, equals('{"exercise_ids": ["ex1"]}'));
        expect(data.exerciseIds, isEmpty);
      });
    });

    group('createSession', () {
      final session = ChatSessionEntity(
        id: 'ses_1',
        title: 'Chest day',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
        totalTokens: 0,
      );

      test('saves mapped DTO and returns the same session', () async {
        when(() => mockFirestore.saveSession(any())).thenAnswer((_) async {});

        final result = await repo.createSession(session);

        expect(result, isA<SuccessResponse<ChatSessionEntity>>());
        expect(
          (result as SuccessResponse<ChatSessionEntity>).data,
          equals(session),
        );
        final saved =
            verify(
                  () => mockFirestore.saveSession(captureAny()),
                ).captured.single
                as ChatSessionDto;
        expect(saved.id, equals('ses_1'));
        expect(saved.title, equals('Chest day'));
        expect(saved.updatedAtMillis, equals(1000));
        expect(saved.totalTokens, equals(0));
      });

      test('returns ErrorResponse when firestore fails', () async {
        when(
          () => mockFirestore.saveSession(any()),
        ).thenThrow(Exception('Firestore Write Failed'));

        final result = await repo.createSession(session);

        expect(result, isA<ErrorResponse<ChatSessionEntity>>());
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
