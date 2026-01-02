class DictionaryEntry {
  final String word;
  final List<String> persianTranslations;

  DictionaryEntry({
    required this.word,
    required this.persianTranslations,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String? ?? '';
    final entries = json['entries'] as List<dynamic>? ?? [];

    final Set<String> translations = {};

    for (var entry in entries) {
      final senses = entry['senses'] as List<dynamic>? ?? [];
      for (var sense in senses) {
        final trans = sense['translations'] as List<dynamic>? ?? [];
        for (var t in trans) {
          final lang = t['language'] as Map<String, dynamic>?;
          if (lang != null && lang['code'] == 'fa') {
            translations.add(t['word'] as String);
          }
        }

        // Also check subsenses if any
        final subsenses = sense['subsenses'] as List<dynamic>? ?? [];
        for (var sub in subsenses) {
          final trans = sub['translations'] as List<dynamic>? ?? [];
          for (var t in trans) {
            final lang = t['language'] as Map<String, dynamic>?;
            if (lang != null && lang['code'] == 'fa') {
              translations.add(t['word'] as String);
            }
          }
        }
      }
    }

    return DictionaryEntry(
      word: word,
      persianTranslations: translations.toList(),
    );
  }
}
