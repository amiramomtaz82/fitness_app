import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BottomItem model & items list', () {
    test('BottomItem constructor creates instance with correct properties', () {
      const item = BottomItem(icon: AppAssets.home, label: 'Test Label');

      expect(item.icon, equals(AppAssets.home));
      expect(item.label, equals('Test Label'));
    });

    test('items list has 4 elements with correct properties and order', () {
      expect(items.length, equals(4));

      expect(items[0].label, equals(LocaleKeys.home));
      expect(items[0].icon, equals(AppAssets.home));

      expect(items[1].label, equals(LocaleKeys.chat_smart_coach));
      expect(items[1].icon, equals(AppAssets.chat));

      expect(items[2].label, equals(LocaleKeys.workouts));
      expect(items[2].icon, equals(AppAssets.exercise));

      expect(items[3].label, equals(LocaleKeys.profile));
      expect(items[3].icon, equals(AppAssets.person));
    });
  });
}
