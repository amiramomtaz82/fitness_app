import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/ollama_chat_request_dto.dart';
import '../models/ollama_chat_response_dto.dart';
import '../models/ollama_generate_request_dto.dart';
import '../models/ollama_generate_response_dto.dart';

part 'chat_api_client.g.dart';

@RestApi()
abstract class ChatApiClient {
  factory ChatApiClient(Dio dio, {String baseUrl}) = _ChatApiClient;

  @POST(Endpoints.ollamaChat)
  Future<OllamaChatResponseDto> chat(
    @Body() OllamaChatRequestDto body, //
  );

  @POST(Endpoints.ollamaGenerate)
  Future<OllamaGenerateResponseDto> generate(
    @Body() OllamaGenerateRequestDto body,
  );
}
