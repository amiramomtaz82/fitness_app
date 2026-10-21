import 'package:fitness_app/app/bottom_bar/bottom_navigation_bar.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:fitness_app/app/bottom_bar/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppBottomNavigationBar widget', () {
    testWidgets('integrates with GoRouter StatefulShellRoute and switches branches on tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testRouter = GoRouter(
        initialLocation: '/first',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppBottomNavigationBar(
                navigationShell: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/first',
                    builder: (context, state) => const Center(child: Text('Screen One')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/second',
                    builder: (context, state) => const Center(child: Text('Screen Two')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/third',
                    builder: (context, state) => const Center(child: Text('Screen Three')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/fourth',
                    builder: (context, state) => const Center(child: Text('Screen Four')),
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
          builder: (context, _) => MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingBottomBar), findsOneWidget);
      expect(find.text('Screen One'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);

      // Tap on second tab (Chat, index 1)
      await tester.tap(find.byType(Items).at(1));
      await tester.pumpAndSettle();

      expect(find.text('Screen Two'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Explore'), findsNothing);

      // Tap on third tab (Workouts, index 2)
      await tester.tap(find.byType(Items).at(2));
      await tester.pumpAndSettle();

      expect(find.text('Screen Three'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);

      // Tap on fourth tab (Profile, index 3)
      await tester.tap(find.byType(Items).at(3));
      await tester.pumpAndSettle();

      expect(find.text('Screen Four'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Workouts'), findsNothing);

      // Tap back to first tab (Explore, index 0)
      await tester.tap(find.byType(Items).at(0));
      await tester.pumpAndSettle();

      expect(find.text('Screen One'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('tapping currently active tab resets branch when navigated to nested route (initialLocation: true)',
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
              return AppBottomNavigationBar(
                navigationShell: navigationShell,
              );
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
                        builder: (context, state) => const Text('Nested Detail Screen'),
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
          builder: (context, _) => MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Root First Screen'), findsOneWidget);

      // Navigate to detail
      await tester.tap(find.text('Go to Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Nested Detail Screen'), findsOneWidget);

      // Tap tab 0 (which is already active)
      await tester.tap(find.byType(Items).at(0));
      await tester.pumpAndSettle();

      // Because initialLocation: (index == selectedIndex) is true, it navigates back to root
      expect(find.text('Root First Screen'), findsOneWidget);
      expect(find.text('Nested Detail Screen'), findsNothing);
    });
  });
}
