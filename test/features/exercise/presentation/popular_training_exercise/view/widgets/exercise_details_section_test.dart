import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_row.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_section.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_video_tile.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../presentation_fixtures.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpSection(
    WidgetTester tester,
    List<ExerciseDetailsEntry> entries, {
    ValueChanged<String>? onVideoTap,
  }) {
    return tester.pumpWidget(
      makeTestableComponent(
        ExerciseDetailsSection(
          section: ExerciseDetailsSectionData(
            titleKey: LocaleKeys.exercises_videos,
            entries: entries,
          ),
          onVideoTap: onVideoTap ?? (_) {},
        ),
      ),
    );
  }

  group('ExerciseDetailsSection', () {
    testWidgets('shows the localized section title', (tester) async {
      await pumpSection(tester, const [
        ExerciseDetailsTextEntry(labelKey: LocaleKeys.exercises_level),
      ]);

      expect(find.text(LocaleKeys.exercises_videos.tr()), findsOneWidget);
    });

    testWidgets('maps a text entry into a labelled row', (tester) async {
      await pumpSection(tester, const [
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_level,
          value: 'Beginner',
        ),
      ]);

      final row = tester.widget<ExerciseDetailsRow>(
        find.byType(ExerciseDetailsRow),
      );

      expect(find.byType(TranslucentCardList), findsOneWidget);
      expect(row.labelKey, LocaleKeys.exercises_level);
      expect(row.value, 'Beginner');
    });

    testWidgets('maps a video entry into a tile that reports its url', (
      tester,
    ) async {
      final opened = <String>[];

      await pumpSection(tester, const [
        ExerciseDetailsVideoEntry(
          labelKey: LocaleKeys.exercises_video_explanation,
          videoUrl: kYoutubeUrl,
        ),
      ], onVideoTap: opened.add);

      expect(find.byType(ExerciseVideoTile), findsOneWidget);
      expect(
        find.text(LocaleKeys.exercises_video_explanation.tr()),
        findsOneWidget,
      );

      await tester.tap(find.byType(ExerciseVideoTile));
      await tester.pump();

      expect(opened, [kYoutubeUrl]);
    });

    testWidgets('falls back to a row when the video entry has no url', (
      tester,
    ) async {
      await pumpSection(tester, const [
        ExerciseDetailsVideoEntry(
          labelKey: LocaleKeys.exercises_video_explanation,
        ),
      ]);

      expect(find.byType(ExerciseVideoTile), findsNothing);
      expect(
        find.text(LocaleKeys.exercises_not_available.tr()),
        findsOneWidget,
      );
    });

    testWidgets('keeps the entries in the section order', (tester) async {
      await pumpSection(tester, const [
        ExerciseDetailsTextEntry(labelKey: LocaleKeys.exercises_level),
        ExerciseDetailsVideoEntry(
          labelKey: LocaleKeys.exercises_video_explanation,
          videoUrl: kYoutubeUrl,
        ),
      ]);

      final rowTop = tester.getTopLeft(find.byType(ExerciseDetailsRow)).dy;
      final tileTop = tester.getTopLeft(find.byType(ExerciseVideoTile)).dy;

      expect(tileTop, greaterThan(rowTop));
    });

    testWidgets('shows an empty card when the section has no entries', (
      tester,
    ) async {
      await pumpSection(tester, const []);

      expect(find.byType(TranslucentCardList), findsOneWidget);
      expect(find.byType(ExerciseDetailsRow), findsNothing);
      expect(find.byType(ExerciseVideoTile), findsNothing);
    });
  });
}
