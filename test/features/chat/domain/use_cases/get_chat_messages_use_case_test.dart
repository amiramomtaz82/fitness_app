import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/chat_repo.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_chat_messages_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepo extends Mock implements ChatRepo {}

void main() {
  late MockChatRepo mockChatRepo;
  late GetChatMessagesUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepo();
    useCase = GetChatMessagesUseCase(mockChatRepo);
  });

  group('GetChatMessagesUseCase —', () {
    const tSessionId = 'session_123';
    final tMessages = [
      ChatMessageEntity(
        id: 'msg_1',
        sender: ChatSender.user,
        text: 'Hello coach',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    test('returns SuccessResponse with messages when repo succeeds', () async {
      when(
        () => mockChatRepo.getMessages(tSessionId),
      ).thenAnswer((_) async => SuccessResponse(tMessages));

      final result = await useCase(tSessionId);

      expect(result, isA<SuccessResponse<List<ChatMessageEntity>>>());
      expect((result as SuccessResponse).data, equals(tMessages));
      verify(() => mockChatRepo.getMessages(tSessionId)).called(1);
    });

    test('returns ErrorResponse when repo fails', () async {
      const failure = ServerFailure(serverMessage: 'Database read error');
      when(
        () => mockChatRepo.getMessages(tSessionId),
      ).thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(tSessionId);

      expect(result, isA<ErrorResponse<List<ChatMessageEntity>>>());
      expect((result as ErrorResponse).failure, equals(failure));
      verify(() => mockChatRepo.getMessages(tSessionId)).called(1);
    });
  });
}
