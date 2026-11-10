import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  const trailingKey = Key('trailing');

  Widget card({String? subtitle, String? videoId, VoidCallback? onTap}) {
    return ExerciseItemCard(
      name: 'Bench Press',
      subtitle: subtitle,
      videoId: videoId,
      onTap: onTap,
      trailing: const SizedBox(key: trailingKey, width: 24, height: 24),
    );
  }

  Future<void> pumpCard(WidgetTester tester, Widget child) {
    return tester.pumpWidget(makeTestableComponent(child));
  }

  group('ExerciseItemCard', () {
    testWidgets('shows the name, the subtitle and the trailing widget', (
      tester,
    ) async {
      await pumpCard(tester, card(subtitle: 'Barbell', videoId: 'dQw4w9WgXcQ'));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
      expect(find.byKey(trailingKey), findsOneWidget);
    });

    testWidgets('shows only the name when there is no subtitle', (
      tester,
    ) async {
      await pumpCard(tester, card());

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('hands the video id to the thumbnail', (tester) async {
      await pumpCard(tester, card(videoId: 'dQw4w9WgXcQ'));

      final thumbnail = tester.widget<ExerciseThumbnail>(
        find.byType(ExerciseThumbnail),
      );

      expect(thumbnail.videoId, 'dQw4w9WgXcQ');
    });

    testWidgets('reports a tap on the whole row', (tester) async {
      var taps = 0;
      await pumpCard(tester, card(subtitle: 'Barbell', onTap: () => taps++));

      await tester.tap(find.text('Bench Press'));

      expect(taps, 1);
    });

    testWidgets('ignores taps when no callback is given', (tester) async {
      await pumpCard(tester, card());

      await tester.tap(find.text('Bench Press'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('cuts a long name instead of overflowing', (tester) async {
      await pumpCard(tester, card(subtitle: 'Barbell'));

      final name = tester.widget<Text>(find.text('Bench Press'));
      final subtitle = tester.widget<Text>(find.text('Barbell'));

      expect(name.maxLines, 1);
      expect(name.overflow, TextOverflow.ellipsis);
      expect(subtitle.maxLines, 1);
      expect(subtitle.overflow, TextOverflow.ellipsis);
    });
  });
}
