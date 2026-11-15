import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entites/catalog_entities/exercise_card_entity.dart';
import '../entites/catalog_entities/meal_card_entity.dart';
import '../entites/chat_entities/chat_message_entity.dart';
import '../repo/catalog_repo.dart';
import '../repo/chat_repo.dart';

@injectable
class GetChatMessagesUseCase {
  final ChatRepo _chatRepo;
  final CatalogRepo
  _catalogRepo; // ✅ UseCases coordinate multiple repositories!

  const GetChatMessagesUseCase(this._chatRepo, this._catalogRepo);

  Future<BaseResponse<List<ChatMessageEntity>>> call(String sessionId) async {
    // 1. Fetch the raw messages
    final messagesRes = await _chatRepo.getMessages(sessionId);
    final List<ChatMessageEntity> messages;

    switch (messagesRes) {
      case ErrorResponse(:final failure):
        return ErrorResponse(failure: failure);
      case SuccessResponse(:final data):
        messages = data;
    }

    // 2. Collect all unique IDs across all messages using a Set
    final allExerciseIds = <String>{};
    final allMealIds = <String>{};
    for (final msg in messages) {
      allExerciseIds.addAll(msg.exerciseRefs);
      allMealIds.addAll(msg.mealRefs);
    }

    // 3. Look up exercises once for the entire conversation
    final exerciseMap = <String, ExerciseCardEntity>{};
    if (allExerciseIds.isNotEmpty) {
      final res = await _catalogRepo.getExercisesByIds(allExerciseIds.toList());
      switch (res) {
        case SuccessResponse(:final data):
          for (final item in data) {
            exerciseMap[item.id] = item;
          }
        case ErrorResponse():
          break;
      }
    }

    // 4. Look up meals once for the entire conversation
    final mealMap = <String, MealCardEntity>{};
    if (allMealIds.isNotEmpty) {
      final res = await _catalogRepo.getMealsByIds(allMealIds.toList());
      switch (res) {
        case SuccessResponse(:final data):
          for (final item in data) {
            mealMap[item.id] = item;
          }
        case ErrorResponse():
          break;
      }
    }

    // 5. Hydrate messages in-memory with O(1) map lookups
    final hydratedMessages = messages.map((msg) {
      final exercises = msg.exerciseRefs
          .map((id) => exerciseMap[id])
          .whereType<ExerciseCardEntity>()
          .toList();
      final meals = msg.mealRefs
          .map((id) => mealMap[id])
          .whereType<MealCardEntity>()
          .toList();

      return msg.copyWith(exercises: exercises, meals: meals);
    }).toList();

    return SuccessResponse(hydratedMessages);
  }
}
