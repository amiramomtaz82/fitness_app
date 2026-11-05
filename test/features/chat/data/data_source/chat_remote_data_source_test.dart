import 'package:fitness_app/core/secure_storage/secure_storage.dart';
import 'package:fitness_app/features/chat/data/client/chat_api_client.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:fitness_app/features/chat/data/models/ollama_chat_response_dto.dart';
import 'package:fitness_app/features/chat/data/models/ollama_message_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatApiClient extends Mock implements ChatApiClient {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late MockChatApiClient mockApiClient;
  late MockSecureStorage mockSecureStorage;
  late ChatRemoteDataSource dataSource;

  const tResponse = OllamaChatResponseDto(
    model: 'gemma4:31b',
    message: OllamaMessageDto(role: 'assistant', content: 'Hello!'),
    promptEvalCount: 10,
    evalCount: 20,
    done: true,
  );

  setUp(() {
    mockApiClient = MockChatApiClient();
    mockSecureStorage = MockSecureStorage();
    dataSource = ChatRemoteDataSource(mockApiClient, mockSecureStorage);
  });

  group('ChatRemoteDataSource —', () {
    group('sendTurnA', () {
      final tMessages = [
        {'role': 'user', 'content': 'Hi'},
      ];
      final tTools = [
        {
          'type': 'function',
          'function': {'name': 'search_exercises'},
        },
      ];

      test(
        'resolves API key and calls client.chat with expected payload',
        () async {
          when(
            () => mockSecureStorage.read(key: 'OLLAMA_API_KEY'),
          ).thenAnswer((_) async => 'test_api_key');

          when(
            () => mockApiClient.chat(any(), any()),
          ).thenAnswer((_) async => tResponse);

          final result = await dataSource.sendTurnA(
            messages: tMessages,
            tools: tTools,
          );

          expect(result, equals(tResponse));
          verify(
            () => mockApiClient.chat('Bearer test_api_key', {
              'model': 'gemma4:31b',
              'messages': tMessages,
              'tools': tTools,
              'stream': false,
              'think': false,
              'options': {'temperature': 0.6, 'num_predict': 512},
            }),
          ).called(1);
        },
      );

      test(
        'uses empty bearer token if key is null in secure storage',
        () async {
          when(
            () => mockSecureStorage.read(key: any(named: 'key')),
          ).thenAnswer((_) async => null);

          when(
            () => mockApiClient.chat(any(), any()),
          ).thenAnswer((_) async => tResponse);

          final result = await dataSource.sendTurnA(
            messages: tMessages,
            tools: tTools,
          );

          expect(result, equals(tResponse));
          verify(() => mockApiClient.chat('Bearer ', any())).called(1);
        },
      );

      test('propagates exception when client throws', () async {
        when(
          () => mockSecureStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'key');

        when(
          () => mockApiClient.chat(any(), any()),
        ).thenThrow(Exception('Network Error'));

        expect(
          () => dataSource.sendTurnA(messages: tMessages, tools: tTools),
          throwsException,
        );
      });
    });

    group('sendTurnB', () {
      final tMessages = [
        {'role': 'user', 'content': 'Hi'},
      ];
      final tFormat = {
        'type': 'object',
        'properties': {
          'reply': {'type': 'string'},
        },
      };

      test(
        'resolves API key and calls client.chat with format schema',
        () async {
          when(
            () => mockSecureStorage.read(key: 'OLLAMA_API_KEY'),
          ).thenAnswer((_) async => 'test_api_key');

          when(
            () => mockApiClient.chat(any(), any()),
          ).thenAnswer((_) async => tResponse);

          final result = await dataSource.sendTurnB(
            messages: tMessages,
            formatSchema: tFormat,
          );

          expect(result, equals(tResponse));
          verify(
            () => mockApiClient.chat('Bearer test_api_key', {
              'model': 'gemma4:31b',
              'messages': tMessages,
              'format': tFormat,
              'stream': false,
              'think': false,
              'options': {'temperature': 0.6, 'num_predict': 512},
            }),
          ).called(1);
        },
      );

      test('propagates exception when client throws', () async {
        when(
          () => mockSecureStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'key');

        when(
          () => mockApiClient.chat(any(), any()),
        ).thenThrow(Exception('Ollama Timeout'));

        expect(
          () =>
              dataSource.sendTurnB(messages: tMessages, formatSchema: tFormat),
          throwsException,
        );
      });
    });
  });
}
