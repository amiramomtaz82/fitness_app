import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/play_button.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_exercise_card.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_exercise_list.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const dummyExercises = [
    ExerciseEntity(exercise: 'Bench Press', primaryEquipment: 'Barbell'),
    ExerciseEntity(exercise: 'Squat', primaryEquipment: 'Barbell'),
  ];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget buildSubject({
    required List<ExerciseEntity> exercises,
    ValueChanged<ExerciseEntity>? onPlay,
  }) {
    return EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [Locale('en'), Locale('ar')],
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: PopularTrainingExerciseList(
                exercises: exercises,
                onPlay: onPlay ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpList(WidgetTester tester, Widget subject) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(subject);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
  }

  group('PopularTrainingExerciseList —', () {
    testWidgets('shows the localized empty message when there are no items', (
      tester,
    ) async {
      await pumpList(tester, buildSubject(exercises: const []));

      expect(
        find.text(LocaleKeys.exercises_no_exercises_found.tr()),
        findsOneWidget,
      );
      expect(find.byType(PopularTrainingExerciseCard), findsNothing);
    });

    testWidgets('renders one card per exercise', (tester) async {
      await pumpList(tester, buildSubject(exercises: dummyExercises));

      expect(find.byType(PopularTrainingExerciseCard), findsNWidgets(2));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('reports the exercised entity when a card is played', (
      tester,
    ) async {
      final played = <ExerciseEntity>[];
      await pumpList(
        tester,
        buildSubject(exercises: dummyExercises, onPlay: played.add),
      );

      await tester.tap(find.byType(PlayButton).first);
      await tester.pump();

      expect(played.single.exercise, 'Bench Press');
    });
  });
}
