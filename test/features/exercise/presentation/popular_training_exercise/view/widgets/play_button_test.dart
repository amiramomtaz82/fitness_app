import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/play_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Widget buildSubject({required VoidCallback onPlay}) {
    return makeTestableComponent(PlayButton(onPlay: onPlay));
  }

  group('PlayButton —', () {
    testWidgets('renders a circular play icon', (tester) async {
      await tester.pumpWidget(buildSubject(onPlay: () {}));

      expect(find.byType(PlayButton), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('calls onPlay once when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(buildSubject(onPlay: () => taps++));

      await tester.tap(find.byType(PlayButton));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
