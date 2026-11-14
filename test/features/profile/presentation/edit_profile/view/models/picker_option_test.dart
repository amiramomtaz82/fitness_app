import 'package:fitness_app/features/profile/presentation/edit_profile/view/models/picker_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PickerOption', () {
    test('pairs what the row shows with what the draft stores', () {
      const option = PickerOption(label: 'Male', value: 'male');

      expect(option.label, 'Male');
      expect(option.value, 'male');
    });

    test('compares by both halves so a label swap is a new option', () {
      const stored = PickerOption(label: 'Male', value: 'male');

      expect(stored, const PickerOption(label: 'Male', value: 'male'));
      expect(stored, isNot(const PickerOption(label: 'ذكر', value: 'male')));
      expect(stored, isNot(const PickerOption(label: 'Male', value: 'female')));
    });

    test('carries an empty label until the server sends a known value', () {
      const option = PickerOption(label: '', value: 'other');

      expect(option.label, isEmpty);
      expect(option.value, 'other');
    });
  });
}
