import 'package:fitness_app/app/bottom_bar/bottom_bar_items.dart';
import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createItemsTestWidget({
  required Widget child,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            children: [child],
          ),
        ),
      ),
    ),
  );
}

void main() {
  const testItem = BottomItem(
    icon: AppAssets.home,
    label: 'Explore',
  );

  group('Items widget', () {
    testWidgets('renders icon and does not show label when isSelected is false', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var tapped = false;

      await tester.pumpWidget(
        createItemsTestWidget(
          child: BottomBarItems(
            item: testItem,
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Explore'), findsNothing);

      await tester.tap(find.byType(BottomBarItems));
      expect(tapped, isTrue);
    });

    testWidgets('renders icon and shows label when isSelected is true', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var tapped = false;

      await tester.pumpWidget(
        createItemsTestWidget(
          child: BottomBarItems(
            item: testItem,
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);

      await tester.tap(find.byType(BottomBarItems));
      expect(tapped, isTrue);
    });

    testWidgets('animates label appearance when transitioning from unselected to selected',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var isSelected = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createItemsTestWidget(
              child: BottomBarItems(
                item: testItem,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    isSelected = true;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsNothing);

      // Tap to select
      await tester.tap(find.byType(BottomBarItems));
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);
    });
  });
}
