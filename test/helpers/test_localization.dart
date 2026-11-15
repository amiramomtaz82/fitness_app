import 'dart:convert';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Loads the real English translations into easy_localization so widgets can
/// resolve `.tr()` keys inside widget tests.
Future<void> loadTestLocalization() async {
  final content = await rootBundle.loadString('assets/translations/en.json');
  final json = jsonDecode(content) as Map<String, dynamic>;
  Localization.load(const Locale('en'), translations: Translations(json));
}
