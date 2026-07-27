class FaqResponse {
  final bool ok;
  final List<FAQItem> data;

  FaqResponse({
    required this.ok,
    required this.data,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List? ?? [])
        .map((e) => FAQItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return FaqResponse(
      ok: json['ok'] == true,
      data: items,
    );
  }
}

class FAQItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isExpanded;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.order = 0,
    this.isExpanded = false,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      order: (json['order'] is int)
          ? json['order'] as int
          : int.tryParse('${json['order']}') ?? 0,
    );
  }

  FAQItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isExpanded,
  }) {
    return FAQItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
