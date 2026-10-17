import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/common/utils/sentence_splitter.dart';

void main() {
  group('splitIntoSentences', () {
    test('splits English on Latin terminators', () {
      const english =
          'Sure. What would you like? Pens, pencils, notebooks?';

      final sentences = splitIntoSentences(english, trim: true);

      expect(sentences, [
        'Sure.',
        'What would you like?',
        'Pens, pencils, notebooks?',
      ]);
    });

    test('splits Persian on ؟ and keeps matching EN/FA counts', () {
      const english =
          'Sure. What would you like? Pens, pencils, notebooks?';
      const persian = 'حتماً. چی می‌خوای؟ خودکار، مداد، دفتر؟';

      final englishSentences = splitIntoSentences(english, trim: true);
      final persianSentences = splitIntoSentences(persian, trim: true);

      expect(persianSentences, [
        'حتماً.',
        'چی می‌خوای؟',
        'خودکار، مداد، دفتر؟',
      ]);
      expect(englishSentences.length, persianSentences.length);
    });

    test('preserves leading spaces when trim is false', () {
      const text = 'Sure. What would you like?';

      final sentences = splitIntoSentences(text);

      expect(sentences.length, 2);
      expect(sentences[0], 'Sure.');
      expect(sentences[1], ' What would you like?');
    });

    test('returns empty list for empty text', () {
      expect(splitIntoSentences(''), isEmpty);
      expect(splitIntoSentences('', trim: true), isEmpty);
    });
  });
}
