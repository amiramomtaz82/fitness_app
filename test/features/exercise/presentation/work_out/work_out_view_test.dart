import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view/work_out_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const WorkOutView()),
        GoRoute(
          path: AppRoutes.exerciseDetails,
          name: AppRoutes.exerciseDetails,
          builder: (_, state) => Scaffold(
            body: Text(
              '${state.pathParameters['muscleId']}|'
              '${state.uri.queryParameters['muscle']}',
            ),
          ),
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  group('WorkOutView —', () {
    testWidgets('pushes the chest exercise details route', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.text('Exercises'), findsOneWidget);

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      expect(find.text('69d982ed85f6bfa972bf2220|Chest'), findsOneWidget);
    });
  });
}
