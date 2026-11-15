import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../presentation_fixtures.dart';

void main() {
  group('InitPopularTrainingGroupIntent', () {
    test('carries the training that was tapped', () {
      const intent = InitPopularTrainingGroupIntent(kTraining);

      expect(intent.training, kTraining);
      expect(intent, isA<PopularTrainingGroupIntent>());
    });

    test('reuses one const instance for the same training', () {
      expect(
        identical(
          const InitPopularTrainingGroupIntent(kTraining),
          const InitPopularTrainingGroupIntent(kTraining),
        ),
        isTrue,
      );
    });
  });

  group('RetryPopularTrainingGroupIntent', () {
    test('reuses one const instance', () {
      expect(
        identical(
          const RetryPopularTrainingGroupIntent(),
          const RetryPopularTrainingGroupIntent(),
        ),
        isTrue,
      );
    });

    test('is a different intent than the init one', () {
      expect(
        const RetryPopularTrainingGroupIntent(),
        isNot(const InitPopularTrainingGroupIntent(kTraining)),
      );
    });
  });
}
