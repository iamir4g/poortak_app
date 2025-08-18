class FAQItem {
  final String id;
  final String question;
  final String answer;
  final FAQCategory category;
  final bool isExpanded;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });

  FAQItem copyWith({
    String? id,
    String? question,
    String? answer,
    FAQCategory? category,
    bool? isExpanded,
  }) {
    return FAQItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

enum FAQCategory {
  all,
  lessons,
  payment,
  general,
}

extension FAQCategoryExtension on FAQCategory {
  String get displayName {
    switch (this) {
      case FAQCategory.all:
        return 'همه ی بخش ها';
      case FAQCategory.lessons:
        return '📚 درس ها';
      case FAQCategory.payment:
        return '💳 خرید و پرداخت';
      case FAQCategory.general:
        return '🌟';
    }
  }

  bool get isActive {
    return this == FAQCategory.all;
  }
}
