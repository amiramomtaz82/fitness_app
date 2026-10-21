import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:fitness_app/app/bottom_bar/items.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createFloatingBottomBarTestWidget({
  required Widget child,
  EdgeInsets viewPadding = EdgeInsets.zero,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(375, 812),
          padding: viewPadding,
          viewPadding: viewPadding,
        ),
        child: Scaffold(
          bottomNavigationBar: child,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    // Standard setup if needed
  });

  group('FloatingBottomBar widget', () {
    testWidgets('renders all items and shows label only for selected index', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          child: FloatingBottomBar(
            items: items,
            selectedIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingBottomBar), findsOneWidget);
      expect(find.byType(Items), findsNWidgets(4));

      // Explore is selected (index 0)
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);
      expect(find.text('Workouts'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('triggers onTap callback with correct index when items are tapped', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tappedIndices = <int>[];

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          child: FloatingBottomBar(
            items: items,
            selectedIndex: 0,
            onTap: (index) => tappedIndices.add(index),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Chat (index 1)
      await tester.tap(find.byType(Items).at(1));
      await tester.pumpAndSettle();

      // Tap Workouts (index 2)
      await tester.tap(find.byType(Items).at(2));
      await tester.pumpAndSettle();

      // Tap Profile (index 3)
      await tester.tap(find.byType(Items).at(3));
      await tester.pumpAndSettle();

      // Tap Explore (index 0)
      await tester.tap(find.byType(Items).at(0));
      await tester.pumpAndSettle();

      expect(tappedIndices, equals([1, 2, 3, 0]));
    });

    testWidgets('updates selected label when selectedIndex changes upon rebuild', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createFloatingBottomBarTestWidget(
              child: FloatingBottomBar(
                items: items,
                selectedIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Workouts'), findsNothing);

      // Tap Workouts (index 2)
      await tester.tap(find.byType(Items).at(2));
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsNothing);
      expect(find.text('Workouts'), findsOneWidget);
    });

    testWidgets('renders Container decoration with surface color and rounded border', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          child: FloatingBottomBar(
            items: items,
            selectedIndex: 1,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.descendant(
        of: find.byType(FloatingBottomBar),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.color, equals(AppColors.surface));
      expect(decoration.borderRadius, equals(BorderRadius.circular(32.r)));
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('adjusts bottom margin when bottom padding is greater than zero', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          viewPadding: const EdgeInsets.only(bottom: 34),
          child: FloatingBottomBar(
            items: items,
            selectedIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FloatingBottomBar),
          matching: find.byType(Container),
        ),
      );

      final margin = container.margin as EdgeInsets?;
      expect(margin, isNotNull);
      expect(margin!.bottom, equals(8.h));
    });

    testWidgets('adjusts bottom margin when bottom padding is zero', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          viewPadding: EdgeInsets.zero,
          child: FloatingBottomBar(
            items: items,
            selectedIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FloatingBottomBar),
          matching: find.byType(Container),
        ),
      );

      final margin = container.margin as EdgeInsets?;
      expect(margin, isNotNull);
      expect(margin!.bottom, equals(16.h));
    });

    testWidgets('renders with custom items list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const customItems = [
        BottomItem(icon: AppAssets.home, label: 'Custom 1'),
        BottomItem(icon: AppAssets.person, label: 'Custom 2'),
      ];

      await tester.pumpWidget(
        createFloatingBottomBarTestWidget(
          child: FloatingBottomBar(
            items: customItems,
            selectedIndex: 1,
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Items), findsNWidgets(2));
      expect(find.text('Custom 2'), findsOneWidget);
      expect(find.text('Custom 1'), findsNothing);
    });
  });
}
