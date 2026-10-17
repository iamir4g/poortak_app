/// Splits [text] into sentences using Latin and Persian/Arabic terminators.
///
/// Terminators: `.` `!` `?` (Latin) and `؟` `۔` (Persian/Arabic).
///
/// When [trim] is false (default), leading spaces between sentences are kept
/// so [Text.rich] spans render correctly. When true, each sentence is trimmed
/// and empty results are dropped (suitable for TTS / navigation indexes).
List<String> splitIntoSentences(String text, {bool trim = false}) {
  if (text.isEmpty) return const [];

  final regExp = RegExp(r'[^.!?؟۔]+[.!?؟۔]*');
  final matches = regExp.allMatches(text).map((m) => m.group(0)!);

  if (!trim) return matches.toList();

  return matches
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}
