import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_message_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/catalog_repo.dart';
import 'package:fitness_app/features/chat/domain/repo/chat_repo.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_chat_messages_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepo extends Mock implements ChatRepo {}

class MockCatalogRepo extends Mock implements CatalogRepo {}

void main() {
  late MockChatRepo mockChatRepo;
  late MockCatalogRepo mockCatalogRepo;
  late GetChatMessagesUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepo();
    mockCatalogRepo = MockCatalogRepo();
    useCase = GetChatMessagesUseCase(mockChatRepo, mockCatalogRepo);
  });

  group('GetChatMessagesUseCase —', () {
    const tSessionId = 'session_123';
    final tMessages = [
      ChatMessageEntity(
        id: 'msg_1',
        sender: ChatSender.user,
        text: 'Hello coach',
        createdAt: DateTime(2026, 1, 1),
        exerciseRefs: const ['ex_1'],
      ),
    ];

    test('returns SuccessResponse and hydrates exercises and meals', () async {
      when(
        () => mockChatRepo.getMessages(tSessionId),
      ).thenAnswer((_) async => SuccessResponse(tMessages));

      when(() => mockCatalogRepo.getExercisesByIds(const ['ex_1'])).thenAnswer(
        (_) async => const SuccessResponse([
          ExerciseCardEntity(id: 'ex_1', name: 'Push Up'),
        ]),
      );

      final result = await useCase(tSessionId);

      expect(result, isA<SuccessResponse<List<ChatMessageEntity>>>());
      final data = (result as SuccessResponse).data as List<ChatMessageEntity>;
      expect(data.first.exercises.length, equals(1));
      expect(data.first.exercises.first.name, equals('Push Up'));
    });

    test('returns ErrorResponse when repo fails', () async {
      const failure = ServerFailure(serverMessage: 'Database error');
      when(
        () => mockChatRepo.getMessages(tSessionId),
      ).thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase(tSessionId);

      expect(result, isA<ErrorResponse<List<ChatMessageEntity>>>());
      expect((result as ErrorResponse).failure, equals(failure));
    });
  });
}
