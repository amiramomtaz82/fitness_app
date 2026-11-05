import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/chat/domain/entites/chat_entities/chat_session_entity.dart';
import 'package:fitness_app/features/chat/domain/repo/chat_repo.dart';
import 'package:fitness_app/features/chat/domain/use_cases/get_previous_sessions_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepo extends Mock implements ChatRepo {}

void main() {
  late MockChatRepo mockChatRepo;
  late GetPreviousSessionsUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepo();
    useCase = GetPreviousSessionsUseCase(mockChatRepo);
  });

  group('GetPreviousSessionsUseCase —', () {
    final tSessions = [
      ChatSessionEntity(
        id: 's_1',
        title: 'Morning Leg Workout',
        updatedAt: DateTime(2026, 1, 1),
        totalTokens: 1500,
      ),
    ];

    test('returns SuccessResponse with sessions when repo succeeds', () async {
      when(() => mockChatRepo.getPreviousSessions())
          .thenAnswer((_) async => SuccessResponse(tSessions));

      final result = await useCase();

      expect(result, isA<SuccessResponse<List<ChatSessionEntity>>>());
      expect((result as SuccessResponse).data, equals(tSessions));
      verify(() => mockChatRepo.getPreviousSessions()).called(1);
    });

    test('returns ErrorResponse when repo fails', () async {
      const failure = ServerFailure(serverMessage: 'Firestore unavailable');
      when(() => mockChatRepo.getPreviousSessions())
          .thenAnswer((_) async => ErrorResponse(failure: failure));

      final result = await useCase();

      expect(result, isA<ErrorResponse<List<ChatSessionEntity>>>());
      expect((result as ErrorResponse).failure, equals(failure));
      verify(() => mockChatRepo.getPreviousSessions()).called(1);
    });
  });
}
