enum KavooshTreeType {
  book,
  video,
}

extension KavooshTreeTypeApiValue on KavooshTreeType {
  String get apiValue {
    switch (this) {
      case KavooshTreeType.book:
        return 'BOOK';
      case KavooshTreeType.video:
        return 'VIDEO';
    }
  }
}
