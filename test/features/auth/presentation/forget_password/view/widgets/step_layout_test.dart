import 'package:fitness_app/core/widgets/frosted_panel.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/widgets/step_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../forget_password_widget_test_helpers.dart';

void main() {
  Widget build({
    bool subtitleAbove = false,
    Widget child = const Text('StepBody'),
  }) {
    return StepLayout(
      title: 'Step Title',
      subtitle: 'Step Subtitle',
      subtitleAbove: subtitleAbove,
      child: child,
    );
  }

  testWidgets('renders the title, subtitle and the step body', (tester) async {
    await pumpBareWidget(tester, build());

    expect(find.text('Step Title'), findsOneWidget);
    expect(find.text('Step Subtitle'), findsOneWidget);
    expect(find.text('StepBody'), findsOneWidget);
  });

  testWidgets('title sits above the subtitle by default', (tester) async {
    await pumpBareWidget(tester, build());

    final titleTop = tester.getTopLeft(find.text('Step Title')).dy;
    final subtitleTop = tester.getTopLeft(find.text('Step Subtitle')).dy;
    expect(titleTop, lessThan(subtitleTop));
  });

  testWidgets('subtitleAbove puts the subtitle over the title', (tester) async {
    await pumpBareWidget(tester, build(subtitleAbove: true));

    final titleTop = tester.getTopLeft(find.text('Step Title')).dy;
    final subtitleTop = tester.getTopLeft(find.text('Step Subtitle')).dy;
    expect(subtitleTop, lessThan(titleTop));
  });

  testWidgets('the step body is rendered inside a frosted panel', (
    tester,
  ) async {
    await pumpBareWidget(tester, build());

    expect(
      find.descendant(
        of: find.byType(FrostedPanel),
        matching: find.text('StepBody'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tall content stays inside the scrollable and never overflows', (
    tester,
  ) async {
    await pumpBareWidget(
      tester,
      build(
        child: const SizedBox(
          height: 1200,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text('BottomChild'),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('BottomChild'), findsOneWidget);
  });

  testWidgets('the layout lives in a scroll view that dismisses on drag', (
    tester,
  ) async {
    await pumpBareWidget(tester, build());

    final scroll = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(StepLayout),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(
      scroll.keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
  });
}
