import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/chat_repo.dart';
import 'package:fitness_app/features/chat/domain/use_cases/create_chat_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepo extends Mock implements ChatRepo {}

void main() {
  late MockChatRepo mockChatRepo;
  late CreateChatSessionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      ChatSessionEntity(
        id: 'fallback',
        title: 'fallback',
        updatedAt: DateTime(2026),
        totalTokens: 0,
      ),
    );
  });

  setUp(() {
    mockChatRepo = MockChatRepo();
    useCase = CreateChatSessionUseCase(mockChatRepo);
    when(() => mockChatRepo.createSession(any())).thenAnswer(
      (invocation) async => SuccessResponse(
        invocation.positionalArguments.first as ChatSessionEntity,
      ),
    );
  });

  ChatSessionEntity capturedSession() =>
      verify(() => mockChatRepo.createSession(captureAny())).captured.single
          as ChatSessionEntity;

  group('CreateChatSessionUseCase —', () {
    test('creates a fresh session with zero tokens and a ses_ id', () async {
      final before = DateTime.now();

      final result = await useCase('Chest workout');

      expect(result, isA<SuccessResponse<ChatSessionEntity>>());
      final session = capturedSession();
      expect(session.id, startsWith('ses_'));
      expect(session.totalTokens, equals(0));
      expect(session.updatedAt.isBefore(before), isFalse);
      expect((result as SuccessResponse).data, equals(session));
    });

    test('uses the trimmed first message as the title', () async {
      await useCase('   Chest   workout\nplease  ');

      expect(capturedSession().title, equals('Chest workout please'));
    });

    test('keeps a title that is exactly the max length unchanged', () async {
      final message = 'a' * CreateChatSessionUseCase.maxTitleLength;

      await useCase(message);

      expect(capturedSession().title, equals(message));
    });

    test('truncates a long title and appends an ellipsis', () async {
      final message = 'b' * (CreateChatSessionUseCase.maxTitleLength + 10);

      await useCase(message);

      expect(
        capturedSession().title,
        equals('${'b' * CreateChatSessionUseCase.maxTitleLength}…'),
      );
    });

    test('returns ErrorResponse when repo fails', () async {
      const failure = ServerFailure(serverMessage: 'Firestore unavailable');
      when(
        () => mockChatRepo.createSession(any()),
      ).thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase('Hi');

      expect(result, isA<ErrorResponse<ChatSessionEntity>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });
  });
}
