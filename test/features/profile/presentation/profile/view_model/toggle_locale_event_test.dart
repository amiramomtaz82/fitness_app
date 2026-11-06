import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/toggle_locale_event.dart';

void main() {
  group('ToggleLocaleEvent', () {
    test('is a ui event the profile screen can forward', () {
      const event = ToggleLocaleEvent();

      expect(event, isA<BaseUiEvent>());
    });

    test('is a constant the cubit can reuse', () {
      expect(
        identical(const ToggleLocaleEvent(), const ToggleLocaleEvent()),
        isTrue,
      );
    });
  });
}
