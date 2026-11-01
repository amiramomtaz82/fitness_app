import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/play_button.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const exercise = ExerciseEntity(
    exercise: 'Bench Press',
    primaryEquipment: 'Barbell',
  );

  Widget buildSubject({required VoidCallback onPlay}) {
    return makeTestableComponent(
      PopularTrainingExerciseCard(exercise: exercise, onPlay: onPlay),
    );
  }

  group('PopularTrainingExerciseCard —', () {
    testWidgets('shows the exercise name, equipment, thumbnail and play', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(onPlay: () {}));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
      expect(find.byType(ExerciseThumbnail), findsOneWidget);
      expect(find.byType(PlayButton), findsOneWidget);
    });

    testWidgets('calls onPlay when the play button is tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(buildSubject(onPlay: () => taps++));

      await tester.tap(find.byType(PlayButton));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
