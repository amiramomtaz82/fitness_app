import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/screens/change_password_screen.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_cubit.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../profile_test_helper.dart';

class MockCustomColors extends Mock implements CustomColors {}

class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'profile_old_password': 'Old Password',
      'profile_new_password': 'New Password',
      'profile_confirm_password': 'Confirm Password',
      'profile_done': 'Done',
      'profile_create_new_password': 'Create New Password',
      'profile_make_sure_8_characters': 'Make Sure Its 8 Characters Or More',
      'validation_field_required': 'This field is required',
      'validation_password_too_short': 'Password is too short',
      'validation_password_missing_number': 'Password needs a number',
      'validation_password_missing_uppercase': 'Password needs uppercase',
      'validation_password_missing_lowercase': 'Password needs lowercase',
      'validation_password_missing_special_char':
          'Password needs a special character',
      'validation_passwords_dont_match': 'Passwords do not match',
    };
  }
}

void main() {
  late MockChangePasswordUseCase mockUseCase;
  late MockCustomColors mockColors;
  late ChangePasswordCubit cubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockUseCase = MockChangePasswordUseCase();
    mockColors = MockCustomColors();

    when(() => mockColors.white).thenReturn(Colors.white);
    when(() => mockColors.textPrimary).thenReturn(Colors.white);
    when(() => mockColors.textSecondary).thenReturn(Colors.white70);
    when(() => mockColors.hint).thenReturn(Colors.white54);

    cubit = ChangePasswordCubit(mockUseCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget createWidgetUnderTest() {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      fallbackLocale: const Locale('en'),
      path: 'test/translations',
      assetLoader: _TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                theme: ThemeData(
                  brightness: Brightness.dark,
                  extensions: [mockColors],
                ),
                home: BlocProvider<ChangePasswordCubit>.value(
                  value: cubit,
                  child: const ChangePasswordScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  group('ChangePasswordScreen', () {
    testWidgets('renders the password screen correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordScreen), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(3));

      expect(find.text('Make Sure Its 8 Characters Or More'), findsOneWidget);

      expect(find.text('Create New Password'), findsOneWidget);

      expect(find.text('Old Password'), findsOneWidget);

      expect(find.text('New Password'), findsOneWidget);

      expect(find.text('Confirm Password'), findsOneWidget);

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('all password fields are obscured initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextField>(find.byType(TextField));

      expect(fields.length, 3);

      for (final field in fields) {
        expect(field.obscureText, isTrue);
      }
    });

    testWidgets('toggles current password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(0));

      expect(field.obscureText, isFalse);
    });

    testWidgets('toggles new password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).at(1));

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(1));

      expect(field.obscureText, isFalse);
    });

    testWidgets('toggles confirm password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).at(2));

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(2));

      expect(field.obscureText, isFalse);
    });

    testWidgets('updates current password when typing', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'OldPassword123!');

      await tester.pump();

      expect(cubit.state.currentPassword, 'OldPassword123!');
    });

    testWidgets('updates new password when typing', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), 'NewPassword123!');

      await tester.pump();

      expect(cubit.state.newPassword, 'NewPassword123!');
    });

    testWidgets('updates confirm password when typing', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(2), 'NewPassword123!');

      await tester.pump();

      expect(cubit.state.confirmPassword, 'NewPassword123!');
    });

    testWidgets('shows validation errors when submitting empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(
        cubit.state.errorOf(ChangePasswordField.currentPassword),
        isNotNull,
      );

      expect(cubit.state.errorOf(ChangePasswordField.newPassword), isNotNull);

      expect(
        cubit.state.errorOf(ChangePasswordField.confirmPassword),
        isNotNull,
      );

      verifyNever(
        () => mockUseCase(
          password: any(named: 'password'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    testWidgets('does not submit when passwords do not match', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'OldPassword123!');

      await tester.enterText(find.byType(TextField).at(1), 'NewPassword123!');

      await tester.enterText(
        find.byType(TextField).at(2),
        'DifferentPassword123!',
      );

      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(
        cubit.state.errorOf(ChangePasswordField.confirmPassword),
        isNotNull,
      );

      verifyNever(
        () => mockUseCase(
          password: any(named: 'password'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    testWidgets('clears field error when user updates the field', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        cubit.state.errorOf(ChangePasswordField.currentPassword),
        isNotNull,
      );

      await tester.enterText(find.byType(TextField).at(0), 'OldPassword123!');

      await tester.pump();

      expect(cubit.state.errorOf(ChangePasswordField.currentPassword), isNull);
    });
  });
}
