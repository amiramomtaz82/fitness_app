import 'package:fitness_app/features/exercise/presentation/utils/display_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisplayValues.text', () {
    test('returns null when the value is missing', () {
      expect(DisplayValues.text(null), isNull);
    });

    test('returns null when the value is empty or only spaces', () {
      expect(DisplayValues.text(''), isNull);
      expect(DisplayValues.text('   '), isNull);
    });

    test('returns the trimmed value', () {
      expect(DisplayValues.text('  Barbell  '), 'Barbell');
    });
  });

  group('DisplayValues.number', () {
    test('returns null when the value is missing', () {
      expect(DisplayValues.number(null), isNull);
    });

    test('returns the value as text', () {
      expect(DisplayValues.number(0), '0');
      expect(DisplayValues.number(12), '12');
    });
  });

  group('DisplayValues.firstFilled', () {
    test('returns null when there is no value at all', () {
      expect(DisplayValues.firstFilled(const []), isNull);
      expect(DisplayValues.firstFilled(const [null, '', '   ']), isNull);
    });

    test('returns the first trimmed value that is filled', () {
      expect(
        DisplayValues.firstFilled(const [null, '  ', ' first ', 'second']),
        'first',
      );
    });
  });

  group('DisplayValues.joined', () {
    test('returns null when every value is missing', () {
      expect(DisplayValues.joined(const [null, '', '  ']), isNull);
    });

    test('joins the filled values with a comma', () {
      expect(
        DisplayValues.joined(const [' Push ', null, 'Pull']),
        'Push, Pull',
      );
    });

    test('joins with the given separator', () {
      expect(
        DisplayValues.joined(const ['Push', 'Pull'], separator: ' / '),
        'Push / Pull',
      );
    });
  });
}
