import 'package:flutter/material.dart';

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
      buffer.write('\u2066${match.group(0)}\u2069');
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

  const BidiText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final direction = BidiTextHelper.detectDirection(text);
    final displayText = BidiTextHelper.prepare(text);

    return Directionality(
      textDirection: direction,
      child: Text(
        displayText,
        style: style,
        textDirection: direction,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
