import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Widget row(int index) => SizedBox(key: Key('row_$index'), height: 40);

  Future<void> pumpList(WidgetTester tester, int childCount) {
    return tester.pumpWidget(
      makeTestableComponent(
        TranslucentCardList(
          children: [
            for (var index = 1; index <= childCount; index++) row(index),
          ],
        ),
      ),
    );
  }

  group('TranslucentCardList', () {
    testWidgets('renders one child without any divider', (tester) async {
      await pumpList(tester, 1);

      expect(find.byKey(const Key('row_1')), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('keeps every child in order with a divider between them', (
      tester,
    ) async {
      await pumpList(tester, 3);

      expect(
        tester.getTopLeft(find.byKey(const Key('row_1'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('row_2'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('row_2'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('row_3'))).dy),
      );
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('paints a rounded translucent container', (tester) async {
      await pumpList(tester, 1);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TranslucentCardList),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.color!.a, 0.5);
    });
  });
}
