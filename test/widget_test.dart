import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/home/presentation/view/home_view.dart';

void main() {
  testWidgets('HomeView renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    expect(find.byType(HomeView), findsOneWidget);
  });
}
