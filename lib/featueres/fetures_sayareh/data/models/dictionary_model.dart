class DictionaryEntry {
  final String word;
  final List<String> persianTranslations;
  final List<DictionaryExample> examples;
  final List<String> relatedWords;

  DictionaryEntry({
    required this.word,
    required this.persianTranslations,
    required this.examples,
    required this.relatedWords,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String? ?? '';
    final entries = json['entries'] as List<dynamic>? ?? [];

    final Set<String> translations = {};
    final List<DictionaryExample> examples = [];
    final Set<String> related = {};

    for (var entry in entries) {
      final forms = entry['forms'] as List<dynamic>? ?? [];
      for (var form in forms) {
        if (form is Map) {
          final w = form['word'] as String?;
          if (w != null &&
              w.isNotEmpty &&
              w.toLowerCase() != word.toLowerCase()) {
            related.add(w);
          }
        }
      }

      final synonyms = entry['synonyms'] as List<dynamic>? ?? [];
      for (var syn in synonyms) {
        if (syn is String &&
            syn.isNotEmpty &&
            syn.toLowerCase() != word.toLowerCase()) {
          related.add(syn);
        }
      }

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

        final senseSynonyms = sense['synonyms'] as List<dynamic>? ?? [];
        for (var syn in senseSynonyms) {
          if (syn is String &&
              syn.isNotEmpty &&
              syn.toLowerCase() != word.toLowerCase()) {
            related.add(syn);
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

          final subSynonyms = sub['synonyms'] as List<dynamic>? ?? [];
          for (var syn in subSynonyms) {
            if (syn is String &&
                syn.isNotEmpty &&
                syn.toLowerCase() != word.toLowerCase()) {
              related.add(syn);
            }
          }
        }
      }
    }

    return DictionaryEntry(
      word: word,
      persianTranslations: translations.toList(),
      examples: examples,
      relatedWords: related.toList(),
    );
  }
}

class DictionaryExample {
  final String text;
  final String? persian;

  DictionaryExample({required this.text, this.persian});
}
