import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:fitness_app/app/bottom_bar/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget testableWidget({required Widget child}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) =>
        MaterialApp(home: Scaffold(bottomNavigationBar: child)),
  );
}

void main() {
  testWidgets('FloatingBottomBar renders items and selected label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      testableWidget(
        child: FloatingBottomBar(items: items, selectedIndex: 0, onTap: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingBottomBar), findsOneWidget);
    expect(find.byType(Items), findsNWidgets(items.length));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Chat'), findsNothing);
  });
}
