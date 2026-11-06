import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const apiKey = '153c6070a22a46659ca4acd8a3139b61.zBIo1hOZI8qM3BR175lr1aba';

  print('⏳ Sending test message to Ollama Cloud...');

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
        'model': 'gemma4:31b',
        'messages': [
          {'role': 'user', 'content': 'Hello coach, give me 1 quick fitness tip!'}
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