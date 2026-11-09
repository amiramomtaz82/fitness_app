import 'package:fitness_app/core/widgets/app_content_card.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/exercise_card_entity.dart';
import 'package:fitness_app/features/chat/domain/entites/catalog_entities/meal_card_entity.dart';
import 'package:fitness_app/features/chat/presentation/view/widgets/coach_recommendations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_app.dart';

void main() {
  Future<List<AppContentCard>> pumpCards(
    WidgetTester tester, {
    List<ExerciseCardEntity> exercises = const [],
    List<MealCardEntity> meals = const [],
  }) async {
    await pumpLocalizedWidget(
      tester,
      CoachRecommendations(exercises: exercises, meals: meals),
    );
    return tester
        .widgetList<AppContentCard>(find.byType(AppContentCard))
        .toList();
  }

  group('CoachRecommendations', () {
    testWidgets('uses the YouTube thumbnail for exercise demo videos', (
      tester,
    ) async {
      final cards = await pumpCards(
        tester,
        exercises: const [
          ExerciseCardEntity(
            id: 'bodyweight-bird-dog',
            name: 'Bodyweight Bird Dog',
            demoUrl: 'https://youtu.be/tU-WZsouVjo?si=Ti1JUU03OqgnmtX6',
          ),
          ExerciseCardEntity(
            id: 'dead-bug',
            name: 'Dead Bug',
            demoUrl: 'https://www.youtube.com/watch?v=jbWmbhElf3Q',
          ),
        ],
      );

      expect(
        cards.map((card) => card.imageUrl),
        equals([
          'https://img.youtube.com/vi/tU-WZsouVjo/hqdefault.jpg',
          'https://img.youtube.com/vi/jbWmbhElf3Q/hqdefault.jpg',
        ]),
      );
    });

    testWidgets('keeps non-YouTube or missing exercise images as they are', (
      tester,
    ) async {
      final cards = await pumpCards(
        tester,
        exercises: const [
          ExerciseCardEntity(
            id: 'a',
            name: 'A',
            demoUrl: 'https://cdn.example.com/a.jpg',
          ),
          ExerciseCardEntity(id: 'b', name: 'B'),
        ],
      );

      expect(
        cards.map((card) => card.imageUrl),
        equals(['https://cdn.example.com/a.jpg', '']),
      );
    });

    testWidgets('uses the meal thumbnail directly', (tester) async {
      final cards = await pumpCards(
        tester,
        meals: const [
          MealCardEntity(
            id: 'ml1',
            name: 'Chicken Rice',
            thumb: 'https://www.themealdb.com/images/media/meals/x.jpg',
          ),
        ],
      );

      expect(
        cards.single.imageUrl,
        'https://www.themealdb.com/images/media/meals/x.jpg',
      );
    });
  });
}
