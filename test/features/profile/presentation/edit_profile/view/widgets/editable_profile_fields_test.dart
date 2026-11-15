import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/edit_tap_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/editable_profile_fields.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const draft = ProfileParams(
    firstName: 'Ahmed',
    lastName: 'Sukkary',
    gender: 'male',
    age: 25,
    weight: 75.5,
    height: 178,
    activityLevel: 'level1',
    goal: 'Gain weight',
  );

  Future<void> pumpRows(
    WidgetTester tester, {
    ValueChanged<EditProfileField>? onFieldTap,
  }) {
    return pumpLocalizedWidget(
      tester,
      EditableProfileFields(draft: draft, onFieldTap: onFieldTap ?? (_) {}),
    );
  }

  testWidgets('offers one row for every editable field', (tester) async {
    await pumpRows(tester);

    expect(
      find.byType(EditTapField),
      findsNWidgets(EditProfileField.values.length),
    );
    for (final field in EditProfileField.values) {
      expect(find.byKey(Key('field_${field.name}')), findsOneWidget);
    }
  });

  testWidgets('a tap hands the field back so its picker can open', (
    tester,
  ) async {
    EditProfileField? tapped;
    await pumpRows(tester, onFieldTap: (field) => tapped = field);

    await tester.ensureVisible(find.byKey(const Key('field_age')));
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('field_age')),
        matching: find.byType(InkWell),
      ),
    );
    await settleUi(tester);

    expect(tapped, EditProfileField.age);
  });
}
