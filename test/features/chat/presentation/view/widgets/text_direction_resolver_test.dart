import 'package:fitness_app/features/chat/presentation/view/widgets/text_direction_resolver.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextDirectionResolver', () {
    test('returns rtl for Arabic text', () {
      expect(TextDirectionResolver.of('عايز تمارين'), TextDirection.rtl);
    });

    test('returns ltr for English text', () {
      expect(TextDirectionResolver.of('Chest workout'), TextDirection.ltr);
    });

    test('uses the first letter that has a direction', () {
      expect(TextDirectionResolver.of('3 تمارين for chest'), TextDirection.rtl);
      expect(TextDirectionResolver.of('💪 Push day تمارين'), TextDirection.ltr);
    });

    test('returns null when the text has no letters', () {
      expect(TextDirectionResolver.of(''), isNull);
      expect(TextDirectionResolver.of('123 💪 !?'), isNull);
    });
  });
}
