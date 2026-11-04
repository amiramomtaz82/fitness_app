import 'package:fitness_app/core/widgets/app_text_form_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/read_only_identity_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpFields(WidgetTester tester) {
    return pumpLocalizedWidget(
      tester,
      const ReadOnlyIdentityFields(
        firstName: 'Ahmed',
        lastName: 'Sukkary',
        email: 'ahmed@test.com',
      ),
    );
  }

  AppTextFormField field(WidgetTester tester, String name) {
    return tester.widget<AppTextFormField>(find.byKey(Key('${name}Field')));
  }

  testWidgets('keeps the account identity out of reach', (tester) async {
    await pumpFields(tester);

    expect(field(tester, 'firstName').enabled, isFalse);
    expect(field(tester, 'lastName').enabled, isFalse);
    expect(field(tester, 'email').enabled, isFalse);
  });

  testWidgets('shows what the account already holds', (tester) async {
    await pumpFields(tester);

    expect(field(tester, 'firstName').hintText, 'Ahmed');
    expect(field(tester, 'lastName').hintText, 'Sukkary');
    expect(field(tester, 'email').hintText, 'ahmed@test.com');
  });

  testWidgets('offers exactly the three locked identity lines', (tester) async {
    await pumpFields(tester);

    expect(find.byType(AppTextFormField), findsNWidgets(3));
  });
}
