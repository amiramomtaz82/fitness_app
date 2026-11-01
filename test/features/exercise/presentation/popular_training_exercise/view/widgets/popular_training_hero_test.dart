import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/levels_bar.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Widget buildSubject({
    String? backgroundVideoId,
    String title = 'Chest Exercise',
    List<String> levels = const ['Beginner', 'Advanced'],
    String selectedLevel = 'Beginner',
    ValueChanged<String>? onLevelSelected,
  }) {
    return makeTestableComponent(
      PopularTrainingHero(
        backgroundVideoId: backgroundVideoId,
        title: title,
        levels: levels,
        selectedLevel: selectedLevel,
        onLevelSelected: onLevelSelected ?? (_) {},
      ),
    );
  }

  group('PopularTrainingHero —', () {
    testWidgets('renders title, levels bar and back button', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Chest Exercise'), findsOneWidget);
      expect(find.byType(LevelsBar), findsOneWidget);
      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('uses a card placeholder when no video id is given', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(ThumbnailImage), findsNothing);
    });

    testWidgets('shows the background thumbnail when a video id is given', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(backgroundVideoId: 'dQw4w9WgXcQ'));

      expect(find.byType(ThumbnailImage), findsOneWidget);
    });

    testWidgets('forwards the selected level to onLevelSelected', (
      tester,
    ) async {
      final selected = <String>[];
      await tester.pumpWidget(buildSubject(onLevelSelected: selected.add));

      await tester.tap(find.text('Advanced'));
      await tester.pump();

      expect(selected, ['Advanced']);
    });
  });
}
