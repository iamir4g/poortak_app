class DictionaryEntry {
  final String word;
  final List<String> persianTranslations;
  final List<DictionaryExample> examples;

  DictionaryEntry({
    required this.word,
    required this.persianTranslations,
    required this.examples,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String? ?? '';
    final entries = json['entries'] as List<dynamic>? ?? [];

    final Set<String> translations = {};
    final List<DictionaryExample> examples = [];

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

        final exs = sense['examples'] as List<dynamic>? ?? [];
        for (var ex in exs) {
          if (ex is String && ex.isNotEmpty) {
            examples.add(DictionaryExample(text: ex));
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

          final subExs = sub['examples'] as List<dynamic>? ?? [];
          for (var ex in subExs) {
            if (ex is String && ex.isNotEmpty) {
              examples.add(DictionaryExample(text: ex));
            }
          }
        }
      }
    }

    return DictionaryEntry(
      word: word,
      persianTranslations: translations.toList(),
      examples: examples,
    );
  }
}

class DictionaryExample {
  final String text;
  final String? persian;

  DictionaryExample({required this.text, this.persian});
}
