import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/bottom_bar/bottom_bar_items.dart';
import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/bottom_navigation_bar.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppBottomNavigationBar widget', () {
    testWidgets(
      'integrates with GoRouter StatefulShellRoute and switches branches on tap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testRouter = _buildRouterWithCoachRoute();

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) =>
                MaterialApp.router(routerConfig: testRouter),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingBottomBar), findsOneWidget);
        expect(find.text('Home Screen'), findsOneWidget);
        expect(find.text(items[0].label.tr()), findsOneWidget);

        await tester.tap(find.byType(BottomBarItems).at(2));
        await tester.pumpAndSettle();

        expect(find.text('Workouts Screen'), findsOneWidget);
        expect(find.text(items[2].label.tr()), findsOneWidget);
        expect(find.text(items[0].label.tr()), findsNothing);

        await tester.tap(find.byType(BottomBarItems).at(3));
        await tester.pumpAndSettle();

        expect(find.text('Profile Screen'), findsOneWidget);
        expect(find.text(items[3].label.tr()), findsOneWidget);
        expect(find.text(items[2].label.tr()), findsNothing);

        await tester.tap(find.byType(BottomBarItems).at(0));
        await tester.pumpAndSettle();

        expect(find.text('Home Screen'), findsOneWidget);
        expect(find.text(items[0].label.tr()), findsOneWidget);
        expect(find.text(items[3].label.tr()), findsNothing);
      },
    );

    testWidgets(
      'smart coach tab pushes a full screen route without the bottom bar',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testRouter = _buildRouterWithCoachRoute();

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) =>
                MaterialApp.router(routerConfig: testRouter),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(BottomBarItems).at(1));
        await tester.pumpAndSettle();

        expect(find.text('Coach Screen'), findsOneWidget);
        expect(find.byType(FloatingBottomBar), findsNothing);

        testRouter.pop();
        await tester.pumpAndSettle();

        expect(find.text('Home Screen'), findsOneWidget);
        expect(find.byType(FloatingBottomBar), findsOneWidget);
        expect(find.text(items[0].label.tr()), findsOneWidget);
      },
    );

    testWidgets(
      'tapping currently active tab resets branch when navigated to nested route (initialLocation: true)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        late GoRouter router;
        router = GoRouter(
          initialLocation: '/first',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                return AppBottomNavigationBar(navigationShell: navigationShell);
              },
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/first',
                      builder: (context, state) => Column(
                        children: [
                          const Text('Root First Screen'),
                          ElevatedButton(
                            onPressed: () => router.go('/first/detail'),
                            child: const Text('Go to Detail'),
                          ),
                        ],
                      ),
                      routes: [
                        GoRoute(
                          path: 'detail',
                          builder: (context, state) =>
                              const Text('Nested Detail Screen'),
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/second',
                      builder: (context, state) => const Text('Screen Two'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Root First Screen'), findsOneWidget);

        // Navigate to detail
        await tester.tap(find.text('Go to Detail'));
        await tester.pumpAndSettle();
        expect(find.text('Nested Detail Screen'), findsOneWidget);

        // Tap tab 0 (which is already active)
        await tester.tap(find.byType(BottomBarItems).at(0));
        await tester.pumpAndSettle();

        // Because initialLocation: (index == selectedIndex) is true, it navigates back to root
        expect(find.text('Root First Screen'), findsOneWidget);
        expect(find.text('Nested Detail Screen'), findsNothing);
      },
    );
  });
}

GoRouter _buildRouterWithCoachRoute() {
  StatefulShellBranch branch(String path, String label) => StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => Center(child: Text(label)),
      ),
    ],
  );

  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: AppRoutes.smartCoach,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Coach Screen'))),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppBottomNavigationBar(navigationShell: navigationShell);
        },
        branches: [
          branch('/home', 'Home Screen'),
          branch('/workouts', 'Workouts Screen'),
          branch('/profile', 'Profile Screen'),
        ],
      ),
    ],
  );
}
