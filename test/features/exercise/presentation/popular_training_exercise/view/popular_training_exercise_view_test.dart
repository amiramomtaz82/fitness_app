import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/popular_training_exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_section.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_play_button.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_summary_card.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_video_tile.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_video_image.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../../helpers/test_app.dart';
import '../../presentation_fixtures.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpView(WidgetTester tester, ExerciseEntity exercise) async {
    usePhoneScreenSize(tester);

    final router = GoRouter(
      initialLocation: AppRoutes.popularTrainingExercise,
      routes: [
        GoRoute(
          path: AppRoutes.popularTrainingExercise,
          builder: (context, settings) =>
              PopularTrainingExerciseView(exercise: exercise),
        ),
        GoRoute(
          path: AppRoutes.exerciseVideo,
          builder: (context, settings) =>
              Scaffold(body: Text('video-${settings.extra}')),
        ),
      ],
    );

    await tester.pumpWidget(makeTestableRouterWidget(router));
    await tester.pump();
  }

  group('PopularTrainingExerciseView', () {
    testWidgets('fills the hero with the exercise name and level', (
      tester,
    ) async {
      await pumpView(tester, kExercise);

      expect(find.byType(AppBackgroundScaffold), findsOneWidget);
      expect(find.byType(ExerciseVideoImage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExerciseHero),
          matching: find.text('Bench Press'),
        ),
        findsOneWidget,
      );
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows the summary card with the primary equipment', (
      tester,
    ) async {
      await pumpView(tester, kExercise);

      final card = tester.widget<ExerciseSummaryCard>(
        find.byType(ExerciseSummaryCard),
      );

      expect(card.name, 'Bench Press');
      expect(card.equipment, 'Barbell');
      expect(card.videoId, kYoutubeId);
      expect(find.byType(ExercisePlayButton), findsOneWidget);
    });

    testWidgets('renders every detail section in the documented order', (
      tester,
    ) async {
      await pumpView(tester, kExercise);

      const titles = [
        LocaleKeys.exercises_related_muscles,
        LocaleKeys.exercises_equipment,
        LocaleKeys.exercises_execution,
        LocaleKeys.exercises_classification,
        LocaleKeys.exercises_videos,
      ];

      expect(find.byType(ExerciseDetailsSection), findsNWidgets(5));

      expect(
        tester
            .widgetList<ExerciseDetailsSection>(
              find.byType(ExerciseDetailsSection),
            )
            .map((section) => section.section.titleKey)
            .toList(),
        titles,
      );
    });

    testWidgets('opens the video screen with the playable url', (tester) async {
      await pumpView(tester, kExercise);

      await tester.tap(find.byType(ExercisePlayButton));
      await tester.pumpAndSettle();

      expect(find.text('video-$kYoutubeUrl'), findsOneWidget);
    });

    testWidgets('opens the video screen from a video row of the section', (
      tester,
    ) async {
      await pumpView(tester, kExercise);

      await tester.ensureVisible(find.byType(ExerciseVideoTile));
      await tester.tap(find.byType(ExerciseVideoTile));
      await tester.pumpAndSettle();

      expect(find.text('video-$kYoutubeUrl'), findsOneWidget);
    });

    testWidgets('leaves the play button idle when the exercise has no video', (
      tester,
    ) async {
      await pumpView(tester, kExerciseWithoutVideo);

      expect(
        tester
            .widget<ExercisePlayButton>(find.byType(ExercisePlayButton))
            .onTap,
        isNull,
      );

      await tester.tap(find.byType(ExercisePlayButton));
      await tester.pumpAndSettle();

      expect(find.text('video-$kYoutubeUrl'), findsNothing);
      expect(find.byType(ExerciseSummaryCard), findsOneWidget);
    });
  });
}
