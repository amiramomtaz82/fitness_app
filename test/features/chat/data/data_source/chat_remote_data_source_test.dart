import 'package:fitness_app/features/chat/data/client/chat_api_client.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_request_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_response_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_message_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatApiClient extends Mock implements ChatApiClient {}

void main() {
  late MockChatApiClient mockApiClient;
  late ChatRemoteDataSource dataSource;

  const tResponse = OllamaChatResponseDto(
    model: 'beam',
    message: OllamaMessageDto(role: 'assistant', content: 'Hello!'),
    promptEvalCount: 10,
    evalCount: 20,
    done: true,
  );

  const tRequest = OllamaChatRequestDto(
    messages: [OllamaMessageDto(role: 'user', content: 'Hi')],
  );

  setUpAll(() {
    registerFallbackValue(tRequest);
  });

  setUp(() {
    mockApiClient = MockChatApiClient();
    dataSource = ChatRemoteDataSource(mockApiClient);
  });

  group('ChatRemoteDataSource —', () {
    test('calls client.chat with request dto and returns response', () async {
      when(() => mockApiClient.chat(any())).thenAnswer((_) async => tResponse);

      final result = await dataSource.chat(tRequest);

      expect(result, equals(tResponse));
      verify(() => mockApiClient.chat(tRequest)).called(1);
    });

    test('propagates exception when client throws', () async {
      when(
        () => mockApiClient.chat(any()),
      ).thenThrow(Exception('Network Error'));

      expect(() => dataSource.chat(tRequest), throwsException);
    });
  });
}
