import 'package:fitness_app/features/profile/presentation/profile/view/widgets/avatar_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Image shownImage(WidgetTester tester) {
    return tester.widget<Image>(find.byType(Image));
  }

  testWidgets('shows the built-in person artwork', (tester) async {
    await pumpLocalizedWidget(tester, const AvatarPlaceholder());

    expect(shownImage(tester).image, isA<AssetImage>());
  });

  testWidgets('covers its box so the crop stays square', (tester) async {
    await pumpLocalizedWidget(tester, const AvatarPlaceholder());

    expect(shownImage(tester).fit, BoxFit.cover);
  });
}
