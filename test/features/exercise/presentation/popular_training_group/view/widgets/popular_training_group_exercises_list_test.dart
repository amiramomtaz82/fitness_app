import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercise_rows.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercises_list.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../presentation_fixtures.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpList(
    WidgetTester tester,
    Resource<List<GroupExerciseItem>> resource, {
    VoidCallback? onRetry,
  }) {
    return tester.pumpWidget(
      makeTestableComponent(
        PopularTrainingGroupExercisesList(
          resource: resource,
          onItemTap: (_) {},
          onRetry: onRetry,
        ),
      ),
    );
  }

  group('PopularTrainingGroupExercisesList', () {
    testWidgets('renders nothing while the resource is still initial', (
      tester,
    ) async {
      await pumpList(tester, const Resource.initial());

      expect(find.byType(PopularTrainingGroupExercisesList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(PopularTrainingGroupExerciseRows), findsNothing);
      expect(find.text(LocaleKeys.common_retry.tr()), findsNothing);
    });

    testWidgets('shows a progress indicator while loading', (tester) async {
      await pumpList(tester, const Resource.loading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(PopularTrainingGroupExerciseRows), findsNothing);
    });

    testWidgets('shows the failure message and the retry action', (
      tester,
    ) async {
      await pumpList(
        tester,
        const Resource.error(ServerFailure()),
        onRetry: () {},
      );

      expect(
        find.text(LocaleKeys.errors_something_went_wrong.tr()),
        findsOneWidget,
      );
      expect(find.text(LocaleKeys.common_retry.tr()), findsOneWidget);
    });

    testWidgets('calls the retry callback when the retry action is tapped', (
      tester,
    ) async {
      var retries = 0;

      await pumpList(
        tester,
        const Resource.error(ServerFailure()),
        onRetry: () => retries++,
      );

      await tester.tap(find.text(LocaleKeys.common_retry.tr()));
      await tester.pump();

      expect(retries, 1);
    });

    testWidgets('renders the exercise rows when the resource succeeded', (
      tester,
    ) async {
      await pumpList(tester, const Resource.success([kExerciseItem]));

      expect(find.byType(PopularTrainingGroupExerciseRows), findsOneWidget);
      expect(find.byType(ExerciseItemCard), findsOneWidget);
    });

    testWidgets('hands an absent payload to the rows as an empty list', (
      tester,
    ) async {
      await pumpList(
        tester,
        const Resource<List<GroupExerciseItem>>(ApiStatus.success, null, null),
      );

      expect(find.byType(PopularTrainingGroupExerciseRows), findsOneWidget);
      expect(
        tester
            .widget<PopularTrainingGroupExerciseRows>(
              find.byType(PopularTrainingGroupExerciseRows),
            )
            .items,
        isEmpty,
      );
    });
  });
}
