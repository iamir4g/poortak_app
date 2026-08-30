import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';

void main() {
  group('BidiTextHelper.prepare', () {
    test('keeps space between English word and Persian text outside isolates', () {
      const input = 'jam یعنی مربا، سه گزینه‌ی دیگر حیوان هستند.';
      const lri = '\u2066';
      const pdi = '\u2069';

      final result = BidiTextHelper.prepare(input);

      expect(result, '${lri}jam$pdi یعنی مربا، سه گزینه‌ی دیگر حیوان هستند.');
      expect(result, contains('$pdi یعنی'));
      expect(result, isNot(contains('$lri jam $pdi')));
    });

    test('keeps space between English word and Persian for bird explanation', () {
      const input = 'bird  یعنی پرنده، سه گزینه‌ی دیگر اعضای بدن هستند.';
      const lri = '\u2066';
      const pdi = '\u2069';

      final result = BidiTextHelper.prepare(input);

      expect(
        result,
        '${lri}bird$pdi  یعنی پرنده، سه گزینه‌ی دیگر اعضای بدن هستند.',
      );
    });

    test('returns plain text when no Latin characters are present', () {
      const input = 'فقط متن فارسی';
      expect(BidiTextHelper.prepare(input), input);
    });
  });
}
