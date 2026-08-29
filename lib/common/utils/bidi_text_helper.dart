import 'package:flutter/material.dart';
import 'package:poortak/common/utils/digit_utils.dart';

/// Helpers for rendering mixed Persian (RTL) and English (LTR) strings.
class BidiTextHelper {
  BidiTextHelper._();

  static final RegExp _rtlChar = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );
  static final RegExp _latinChar = RegExp(r'[A-Za-z]');
  static final RegExp _ltrRun = RegExp(
    r'''["«][^"»]+["»]|'[^']+'|[A-Za-z0-9](?:[A-Za-z0-9\s'’.\-_!?,:;()\[\]{}/\\@#$%&*+=]|___)*[A-Za-z0-9'’)]?|[A-Za-z0-9]+|___+''',
  );

  static bool hasRtl(String text) => _rtlChar.hasMatch(text);
  static bool hasLatin(String text) => _latinChar.hasMatch(text);

  static TextDirection detectDirection(String text) {
    if (hasRtl(text)) return TextDirection.rtl;
    if (hasLatin(text)) return TextDirection.ltr;
    return TextDirection.rtl;
  }

  /// Wraps Latin segments in Unicode isolates so they stay in order inside RTL text.
  static String prepare(String text) {
    // Pure English (or other LTR) in an RTL app: wrap the whole string so
    // trailing blanks/punctuation (e.g. "the ___.") are not flipped to the start.
    if (!hasRtl(text) && hasLatin(text)) {
      return '\u2066$text\u2069';
    }

    if (!hasRtl(text) || !hasLatin(text)) return text;

    final buffer = StringBuffer();
    var lastEnd = 0;

    for (final match in _ltrRun.allMatches(text)) {
      buffer.write(text.substring(lastEnd, match.start));
      final raw = match.group(0)!;
      final core = raw.trim();

      // Keep whitespace outside LTR isolates so spaces between English and
      // Persian (e.g. "jam یعنی") are preserved when rendered RTL.
      final leadingSpaces = raw.length - raw.trimLeft().length;
      final trailingSpaces = raw.length - raw.trimRight().length;

      if (leadingSpaces > 0) {
        buffer.write(raw.substring(0, leadingSpaces));
      }
      if (core.isNotEmpty) {
        buffer.write('\u2066$core\u2069');
      }
      if (trailingSpaces > 0) {
        buffer.write(raw.substring(raw.length - trailingSpaces));
      }

      lastEnd = match.end;
    }
    buffer.write(text.substring(lastEnd));
    return buffer.toString();
  }
}

class BidiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool forceEnglishDigits;

  const BidiText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
    this.forceEnglishDigits = false,
  });

  @override
  Widget build(BuildContext context) {
    final sourceText =
        forceEnglishDigits ? toEnglishDigits(text) : text;
    final direction = BidiTextHelper.detectDirection(sourceText);
    final displayText = BidiTextHelper.prepare(sourceText);

    return Directionality(
      textDirection: direction,
      child: Text(
        displayText,
        style: forceEnglishDigits
            ? (style ?? const TextStyle()).copyWith(
                fontFamilyFallback: const ['sans-serif'],
              )
            : style,
        textDirection: direction,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
