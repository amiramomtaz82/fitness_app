import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../domain/entites/catalog_entities/exercise_card_entity.dart';
import '../../domain/entites/catalog_entities/meal_card_entity.dart';
import '../../domain/entites/chat_entities/chat_message_entity.dart';
import '../../domain/entites/chat_entities/chat_session_entity.dart';
import '../../domain/repo/catalog_repo.dart';
import '../../domain/repo/chat_repo.dart';
import '../data_source/chat_firestore_data_source.dart';
import '../data_source/chat_remote_data_source.dart';

import '../models/chat_message_dto.dart';

import '../models/ollama_chat_response_dto.dart';

@Injectable(as: ChatRepo)
class ChatRepoImp implements ChatRepo {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatFirestoreDataSource _fireStoreDataSource;
  final CatalogRepo _catalogRepo;

  const ChatRepoImp(
    this._remoteDataSource,
    this._fireStoreDataSource,
    this._catalogRepo,
  );

  ///------------------requestTurnA----------------------------------------------------
  @override
  Future<BaseResponse<OllamaChatResponseDto>> requestTurnA({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> tools,
  }) => safeCall(
    () => _remoteDataSource.sendTurnA(messages: messages, tools: tools),
  );

  ///-------------------------requestTurnB----------------------------------------------------
  @override
  Future<BaseResponse<OllamaChatResponseDto>> requestTurnB({
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> formatSchema,
  }) => safeCall(
    () => _remoteDataSource.sendTurnB(
      messages: messages,
      formatSchema: formatSchema,
    ),
  );

  ///----------------------saveMessage----------------------------------------------------
  @override
  Future<BaseResponse<void>> saveMessage(
    String sessionId,
    ChatMessageEntity msg,
    int tokens,
  ) => safeCall(
    () => _fireStoreDataSource.saveMessage(
      sessionId,
      ChatMessageDto.fromEntity(msg, tokens),
    ),
  );

  ///-------------------------------get messages----------------------------------------------------
  @override
  Future<BaseResponse<List<ChatMessageEntity>>> getMessages(String sessionId) =>
      safeCall(() async {
        final dtos = await _fireStoreDataSource.getMessages(sessionId);
        final messages = <ChatMessageEntity>[];

        for (final dto in dtos) {
          final exercises = dto.exerciseRefs.isNotEmpty
              ? (await _catalogRepo.getExercisesByIds(dto.exerciseRefs)).data ??
                    []
              : const <ExerciseCardEntity>[];
          final meals = dto.mealRefs.isNotEmpty
              ? (await _catalogRepo.getMealsByIds(dto.mealRefs)).data ?? []
              : const <MealCardEntity>[];

          messages.add(dto.toEntity(exercises: exercises, meals: meals));
        }
        return messages;
      });

  ///-----------get previous sessions----------------------------------------------------
  @override
  Future<BaseResponse<List<ChatSessionEntity>>> getPreviousSessions() =>
      safeCall(() async {
        final dtos = await _fireStoreDataSource.getSessions();
        return dtos.map((d) => d.toEntity()).toList();
      });
}
