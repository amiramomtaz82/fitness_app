import 'package:flutter/widgets.dart';

abstract final class TextDirectionResolver {
  static TextDirection? of(String text) {
    for (final rune in text.runes) {
      if (_isRtl(rune)) return TextDirection.rtl;
      if (_isLtr(rune)) return TextDirection.ltr;
    }
    return null;
  }

  static bool _isRtl(int rune) =>
      (rune >= 0x0590 && rune <= 0x08FF) ||
      (rune >= 0xFB1D && rune <= 0xFDFF) ||
      (rune >= 0xFE70 && rune <= 0xFEFE);

  static bool _isLtr(int rune) =>
      (rune >= 0x41 && rune <= 0x5A) ||
      (rune >= 0x61 && rune <= 0x7A) ||
      (rune >= 0xC0 && rune <= 0x24F);
}
