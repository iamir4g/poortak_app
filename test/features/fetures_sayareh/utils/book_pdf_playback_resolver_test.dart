import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/single_book_model.dart';
import 'package:poortak/featueres/fetures_sayareh/utils/book_pdf_playback_resolver.dart';

void main() {
  const bookId = '30086bbe-2bc6-4c4b-9266-01bc290c4e51';
  const trialFile = '29226be1-3989-4234-8b46-0b92d7164989';
  const fullFile = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

  SingleBookData sampleBook({
    String? file,
    String? trialFileValue,
    bool purchased = false,
  }) {
    return SingleBookData(
      id: bookId,
      title: 'فرهنگ لغات پورتک',
      order: 0,
      thumbnail: 'thumb',
      price: '850000',
      pageCount: 171,
      publishDate: '1404',
      file: file,
      trialFile: trialFileValue ?? trialFile,
      createdAt: DateTime.parse('2026-05-17T10:52:08.814Z'),
      updatedAt: DateTime.parse('2026-05-17T10:52:08.814Z'),
      purchased: purchased,
      isDemo: true,
    );
  }

  group('BookPdfPlaybackResolver.canDecryptFullBook', () {
    test('کتاب دمو با دسترسی iknow/access می‌تواند decrypt شود', () {
      expect(
        BookPdfPlaybackResolver.canDecryptFullBook(
          hasBookAccess: true,
          purchasedFromApi: false,
          isDemo: true,
        ),
        isTrue,
      );
    });

    test('کتاب دمو با خرید واقعی دسترسی کامل دارد', () {
      expect(
        BookPdfPlaybackResolver.canDecryptFullBook(
          hasBookAccess: false,
          purchasedFromApi: true,
          isDemo: true,
        ),
        isTrue,
      );
    });

    test('کتاب غیر دمو با دسترسی iknow/access دسترسی کامل دارد', () {
      expect(
        BookPdfPlaybackResolver.canDecryptFullBook(
          hasBookAccess: true,
          purchasedFromApi: false,
          isDemo: false,
        ),
        isTrue,
      );
    });

    test('بدون دسترسی decrypt ممکن نیست', () {
      expect(
        BookPdfPlaybackResolver.canDecryptFullBook(
          hasBookAccess: false,
          purchasedFromApi: false,
          isDemo: true,
        ),
        isFalse,
      );
    });
  });

  group('BookPdfPlaybackResolver.canOpenReaderDirectly', () {
    test('با دسترسی iknow/access مستقیم باز می‌شود', () {
      expect(
        BookPdfPlaybackResolver.canOpenReaderDirectly(
          hasBookAccess: true,
          purchasedFromApi: false,
        ),
        isTrue,
      );
    });
  });

  group('BookPdfPlaybackResolver.hasFullBookAccess', () {
    test('hasFullBookAccess همان canDecryptFullBook است', () {
      expect(
        BookPdfPlaybackResolver.hasFullBookAccess(
          hasBookAccess: true,
          purchasedFromApi: false,
          isDemo: true,
        ),
        isTrue,
      );
    });
  });

  group('BookPdfPlaybackResolver.resolve', () {
    test('کتاب دمو با دسترسی iknow/access، نسخه کامل', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(file: fullFile),
        forceTrial: false,
        hasBookAccess: true,
      );

      expect(target, isNotNull);
      expect(target!.usePublicUrl, isFalse);
      expect(target.requiresDecryption, isTrue);
      expect(target.decryptionFileId, fullFile);
      expect(target.cacheFileId, 'book_full_$bookId');
    });

    test('کتاب دمو بدون دسترسی، نمونه بدون رمزگشایی', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(),
        forceTrial: false,
        hasBookAccess: false,
      );

      expect(target, isNotNull);
      expect(target!.usePublicUrl, isTrue);
      expect(target.requiresDecryption, isFalse);
      expect(target.publicStorageKey, trialFile);
      expect(target.cacheFileId, 'book_trial_$bookId');
    });

    test('بدون خرید، نمونه از trialFile با URL عمومی و بدون رمزگشایی', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(),
        forceTrial: true,
        hasBookAccess: false,
      );

      expect(target, isNotNull);
      expect(target!.usePublicUrl, isTrue);
      expect(target.requiresDecryption, isFalse);
      expect(target.publicStorageKey, trialFile);
      expect(target.decryptionFileId, isNull);
      expect(target.cacheFileId, 'book_trial_$bookId');
    });

    test('با خرید، دانلود با bookId و رمزگشایی با file', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(file: fullFile, purchased: true),
        forceTrial: false,
        hasBookAccess: true,
      );

      expect(target, isNotNull);
      expect(target!.usePublicUrl, isFalse);
      expect(target.requiresDecryption, isTrue);
      expect(target.decryptionFileId, fullFile);
      expect(target.publicStorageKey, isNull);
      expect(target.cacheFileId, 'book_full_$bookId');
    });

    test('با خرید ولی بدون file، باز هم هدف کامل برمی‌گردد', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(file: null, purchased: true),
        forceTrial: false,
        hasBookAccess: true,
      );

      expect(target, isNotNull);
      expect(target!.usePublicUrl, isFalse);
      expect(target.decryptionFileId, isNull);
      expect(target.bookId, bookId);
    });

    test('با forceTrial حتی خریدار هم نمونه بدون رمزگشایی می‌بیند', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(file: fullFile, purchased: true),
        forceTrial: true,
        hasBookAccess: true,
      );

      expect(target?.usePublicUrl, isTrue);
      expect(target?.requiresDecryption, isFalse);
      expect(target?.publicStorageKey, trialFile);
      expect(target?.cacheFileId, 'book_trial_$bookId');
    });

    test('بدون trialFile هیچ هدفی برنمی‌گردد', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(trialFileValue: ''),
        forceTrial: true,
        hasBookAccess: false,
      );

      expect(target, isNull);
    });
  });

  group('BookPdfPlaybackResolver.decryptionCandidates', () {
    test('اولویت با fileId استخراج‌شده از URL دانلود است', () {
      final target = BookPdfPlaybackResolver.resolve(
        book: sampleBook(file: fullFile, purchased: true),
        forceTrial: false,
        hasBookAccess: true,
      )!;

      final candidates = BookPdfPlaybackResolver.decryptionCandidates(
        target: target,
        downloadUrlFileId: 'url-file-id',
      );

      expect(candidates, [
        'url-file-id',
        fullFile,
        bookId,
      ]);
    });
  });
}
