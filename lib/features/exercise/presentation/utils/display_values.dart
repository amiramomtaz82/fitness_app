abstract final class DisplayValues {
  DisplayValues._();

  static String? text(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? number(int? value) {
    if (value == null) return null;
    return '$value';
  }

  static String? firstFilled(Iterable<String?> values) {
    for (final value in values) {
      final filled = text(value);
      if (filled != null) return filled;
    }
    return null;
  }

  static String? joined(Iterable<String?> values, {String separator = ', '}) {
    final filled = values
        .map(DisplayValues.text)
        .whereType<String>()
        .toList(growable: false);
    if (filled.isEmpty) return null;
    return filled.join(separator);
  }
}
