import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entites/chat_entities/chat_session_entity.dart';
import '../repo/chat_repo.dart';

@injectable
class GetPreviousSessionsUseCase {
  final ChatRepo _chatRepo;
  const GetPreviousSessionsUseCase(this._chatRepo);

  Future<BaseResponse<List<ChatSessionEntity>>> call({
    int limit = 20,
    int? lastUpdatedAtMillis,
  }) => _chatRepo.getPreviousSessions(
    limit: limit,
    lastUpdatedAtMillis: lastUpdatedAtMillis,
  );
}
