import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_book_detail_model.dart';

class KavooshBookPdfPlaybackTarget {
  final String bookId;
  final String cacheFileId;
  final String? publicStorageKey;
  final String? decryptionFileId;
  final bool usePublicUrl;

  const KavooshBookPdfPlaybackTarget({
    required this.bookId,
    required this.cacheFileId,
    required this.publicStorageKey,
    required this.decryptionFileId,
    required this.usePublicUrl,
  });

  bool get requiresDecryption => !usePublicUrl;
}

class KavooshBookPdfPlaybackResolver {
  const KavooshBookPdfPlaybackResolver._();

  static bool hasFullBookAccess({
    required bool purchasedFromApi,
    required bool hasAccessFromApi,
  }) {
    return purchasedFromApi || hasAccessFromApi;
  }

  /// [forceTrial] is true when user taps "خواندن نمونه".
  static KavooshBookPdfPlaybackTarget? resolve({
    required KavooshBookDetail book,
    required bool forceTrial,
  }) {
    final hasFullAccess = hasFullBookAccess(
      purchasedFromApi: book.purchased,
      hasAccessFromApi: book.hasAccess,
    );

    if (forceTrial || !hasFullAccess) {
      final trialFile = book.demoFileId?.trim();
      if (trialFile == null || trialFile.isEmpty) return null;

      return KavooshBookPdfPlaybackTarget(
        bookId: book.id,
        cacheFileId: 'kavoosh_book_trial_${book.id}',
        publicStorageKey: trialFile,
        decryptionFileId: null,
        usePublicUrl: true,
      );
    }

    final paidFileId = book.fileId?.trim();

    return KavooshBookPdfPlaybackTarget(
      bookId: book.id,
      cacheFileId: 'kavoosh_book_full_${book.id}',
      publicStorageKey: null,
      decryptionFileId:
          paidFileId != null && paidFileId.isNotEmpty ? paidFileId : null,
      usePublicUrl: false,
    );
  }
}
