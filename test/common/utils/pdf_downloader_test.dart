import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/common/utils/pdfDownloader.dart';

void main() {
  group('PdfDownloader.extractStorageFileIdFromUrl', () {
    test('شناسه را از مسیر storage/download استخراج می‌کند', () {
      const url =
          'https://api.poortak.ir/api/v1/storage/download/aa11bb22-cc33-dd44-ee55-ff6677889900';

      expect(
        PdfDownloader.extractStorageFileIdFromUrl(url),
        'aa11bb22-cc33-dd44-ee55-ff6677889900',
      );
    });

    test('اگر UUID در URL نباشد null برمی‌گرداند', () {
      expect(
        PdfDownloader.extractStorageFileIdFromUrl('https://cdn.example.com/file.bin'),
        isNull,
      );
    });
  });
}
