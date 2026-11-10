import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/widgets/app_image_placeholder.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_video_image.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  setUpAll(loadTestTranslations);

  group('ExerciseVideoImage', () {
    testWidgets(
      'fills the space with the video thumbnail when there is an id',
      (tester) async {
        await tester.pumpWidget(
          makeTestableComponent(
            const ExerciseVideoImage(videoId: 'dQw4w9WgXcQ'),
          ),
        );

        final thumbnail = tester.widget<ThumbnailImage>(
          find.byType(ThumbnailImage),
        );

        expect(thumbnail.videoId, 'dQw4w9WgXcQ');
      },
    );

    testWidgets('shows an unavailable message when there is no id', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(const ExerciseVideoImage(videoId: null)),
      );

      expect(find.byType(ThumbnailImage), findsNothing);
      expect(find.byType(AppImagePlaceholder), findsOneWidget);
      expect(
        find.text(LocaleKeys.exercises_not_available.tr()),
        findsOneWidget,
      );
    });
  });
}
