// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final envLines = File('.env').readAsLinesSync();
  final apiKey = envLines
      .firstWhere((l) => l.startsWith('OLLAMA_API_KEY='))
      .split('=')[1]
      .trim();

  print('⏳ Sending test message to Ollama Cloud with free model: beam...');

  try {
    final response = await dio.post(
      'https://ollama.com/api/chat',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'beam',
        'messages': [
          {
            'role': 'user',
            'content': 'Hello coach, give me 1 quick fitness tip!',
          },
        ],
        'stream': false,
        'think': false,
      },
    );

    print('\n✅ --- Response Received ---');
    print('Status: ${response.statusCode}');
    print('AI Reply: ${response.data['message']['content']}');
    print('Tokens Evaluated (Prompt): ${response.data['prompt_eval_count']}');
    print('Tokens Generated: ${response.data['eval_count']}');
  } on DioException catch (e) {
    print('\n⚠️ --- Ollama Response / Error ---');
    print('Status Code: ${e.response?.statusCode}');
    print('Message: ${e.response?.data}');
    print('Details: ${e.message}');
  } catch (e) {
    print('\n❌ Error: $e');
  }
}
