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
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../profile_test_helper.dart';

class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'profile': {
        'old_password': 'Old Password',
        'new_password': 'New Password',
        'confirm_password': 'Confirm Password',
        'done': 'Done',
        'create_new_password': 'Create New Password',
        'make_sure_8_characters': 'Make Sure Its 8 Characters Or More',
      },
      'validation': {
        'field_required': 'This field is required',
        'password_too_short': 'Password is too short',
        'password_missing_number': 'Password needs a number',
        'password_missing_uppercase': 'Password needs uppercase',
        'password_missing_lowercase': 'Password needs lowercase',
        'password_missing_special_char': 'Password needs a special character',
        'passwords_dont_match': 'Passwords do not match',
      },
    };
  }
}

void main() {
  late MockChangePasswordUseCase mockUseCase;
  late ChangePasswordCubit cubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockUseCase = MockChangePasswordUseCase();
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
                  extensions: const [CustomColors.dark],
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

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
    await tester.pumpAndSettle();
  }

  group('ChangePasswordScreen', () {
    testWidgets('renders the password screen correctly', (tester) async {
      await pumpScreen(tester);

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
      await pumpScreen(tester);

      final fields = tester.widgetList<TextField>(find.byType(TextField));

      expect(fields.length, 3);

      for (final field in fields) {
        expect(field.obscureText, isTrue);
      }
    });

    testWidgets('toggles current password visibility', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(0));

      expect(field.obscureText, isFalse);
    });

    testWidgets('toggles new password visibility', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).at(1));

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(1));

      expect(field.obscureText, isFalse);
    });

    testWidgets('toggles confirm password visibility', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined).at(2));

      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField).at(2));

      expect(field.obscureText, isFalse);
    });

    testWidgets('updates current password when typing', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'OldPassword123!');

      await tester.pump();

      expect(cubit.state.currentPassword, 'OldPassword123!');
    });

    testWidgets('updates new password when typing', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(1), 'NewPassword123!');

      await tester.pump();

      expect(cubit.state.newPassword, 'NewPassword123!');
    });

    testWidgets('updates confirm password when typing', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(2), 'NewPassword123!');

      await tester.pump();

      expect(cubit.state.confirmPassword, 'NewPassword123!');
    });

    testWidgets('shows validation errors when submitting empty fields', (
      tester,
    ) async {
      await pumpScreen(tester);

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
      await pumpScreen(tester);

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
      await pumpScreen(tester);

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
