import 'package:injectable/injectable.dart';

import '../client/chat_api_client.dart';
import '../models/ollama_chat_request_dto.dart';
import '../models/ollama_chat_response_dto.dart';
import 'chat_remote_data_source.dart';

@Injectable(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImp implements ChatRemoteDataSource {
  final ChatApiClient _apiClient;

  const ChatRemoteDataSourceImp(this._apiClient);

  @override
  Future<OllamaChatResponseDto> chat(OllamaChatRequestDto request) =>
      _apiClient.chat(request);
}
