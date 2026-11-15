import 'package:fitness_app/features/exercise/presentation/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';
import 'helpers/test_localization.dart';

void main() {
  setUpAll(loadTestLocalization);

  testWidgets('HomeScreen renders successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
