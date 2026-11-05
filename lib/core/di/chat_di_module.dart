import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/chat/data/client/chat_api_client.dart';
import 'dio_module.dart';

@module
abstract class ChatDiModule {
  @lazySingleton
  ChatApiClient chatApiClient(@Named(DioNames.ollama) Dio dio) =>
      ChatApiClient(dio);
}