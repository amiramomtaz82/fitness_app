import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/ollama_chat_response_dto.dart';

part 'chat_api_client.g.dart';

@RestApi(baseUrl: 'https://ollama.com/api')
abstract class ChatApiClient {
  factory ChatApiClient(Dio dio, {String baseUrl}) = _ChatApiClient;

  @POST('/chat')
  Future<OllamaChatResponseDto> chat(
      @Header('Authorization') String authorization,
      @Body() Map<String, dynamic> body,
      );
}