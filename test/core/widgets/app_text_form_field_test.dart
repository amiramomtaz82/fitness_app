import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  Widget makeTestable({
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
    GlobalKey<FormState>? formKey,
  }) {
    return makeTestableComponent(
      Form(
        key: formKey,
        child: AppTextFormField(
          key: const Key('field'),
          hintText: 'Email',
          prefixIcon: AppAssets.mail,
          obscureText: obscureText,
          suffix: suffix,
          validator: validator,
        ),
      ),
    );
  }

  EditableText editableOf(WidgetTester tester) {
    return tester.widget<EditableText>(find.byType(EditableText));
  }

  group('AppTextFormField —', () {
    testWidgets('renders the hint and the prefix icon', (tester) async {
      await tester.pumpWidget(makeTestable());

      expect(find.text('Email'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AppAssets.mail,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows plain text by default', (tester) async {
      await tester.pumpWidget(makeTestable());

      expect(editableOf(tester).obscureText, isFalse);
    });

    testWidgets('hides the text when obscureText is true', (tester) async {
      await tester.pumpWidget(makeTestable(obscureText: true));

      expect(editableOf(tester).obscureText, isTrue);
    });

    testWidgets('renders the given suffix', (tester) async {
      await tester.pumpWidget(
        makeTestable(suffix: const Icon(Icons.visibility_outlined)),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('accepts typed text', (tester) async {
      await tester.pumpWidget(makeTestable());

      await tester.enterText(find.byKey(const Key('field')), 'hello');

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('shows the validator message on validate', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        makeTestable(formKey: formKey, validator: (_) => 'required'),
      );

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('required'), findsOneWidget);
    });
  });
}
