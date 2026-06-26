import 'package:poortak/featueres/fetures_sayareh/data/models/single_book_model.dart';

class BookPdfPlaybackTarget {
  final String bookId;
  final String cacheFileId;
  final String? publicStorageKey;
  final String? decryptionFileId;
  final bool usePublicUrl;

  const BookPdfPlaybackTarget({
    required this.bookId,
    required this.cacheFileId,
    required this.publicStorageKey,
    required this.decryptionFileId,
    required this.usePublicUrl,
  });

  bool get requiresDecryption => !usePublicUrl;
}

class BookPdfPlaybackResolver {
  const BookPdfPlaybackResolver._();

  static bool hasFullBookAccess({
    required bool hasBookAccess,
    required bool purchasedFromApi,
    required bool isDemo,
  }) {
    if (purchasedFromApi) return true;
    // Demo books in iknow/access only grant trial access until purchased.
    if (isDemo) return false;
    return hasBookAccess;
  }

  /// [forceTrial] is true when user taps "خواندن نمونه".
  static BookPdfPlaybackTarget? resolve({
    required SingleBookData book,
    required bool forceTrial,
    required bool hasBookAccess,
  }) {
    final hasFullAccess = hasFullBookAccess(
      hasBookAccess: hasBookAccess,
      purchasedFromApi: book.purchased ?? false,
      isDemo: book.isDemo ?? false,
    );

    if (forceTrial || !hasFullAccess) {
      final trialFile = book.trialFile?.trim();
      if (trialFile == null || trialFile.isEmpty) return null;

      return BookPdfPlaybackTarget(
        bookId: book.id,
        cacheFileId: 'book_trial_${book.id}',
        publicStorageKey: trialFile,
        decryptionFileId: null,
        usePublicUrl: true,
      );
    }

    final paidFileId = book.file?.trim();

    return BookPdfPlaybackTarget(
      bookId: book.id,
      cacheFileId: 'book_full_${book.id}',
      publicStorageKey: null,
      decryptionFileId:
          paidFileId != null && paidFileId.isNotEmpty ? paidFileId : null,
      usePublicUrl: false,
    );
  }

  static List<String> decryptionCandidates({
    required BookPdfPlaybackTarget target,
    String? downloadUrlFileId,
  }) {
    final candidates = <String>[];

    void add(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      if (!candidates.contains(trimmed)) {
        candidates.add(trimmed);
      }
    }

    add(downloadUrlFileId);
    add(target.decryptionFileId);
    add(target.bookId);

    return candidates;
  }
}
