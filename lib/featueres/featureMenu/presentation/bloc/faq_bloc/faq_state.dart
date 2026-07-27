part of 'faq_bloc.dart';

sealed class FaqState extends Equatable {
  const FaqState();

  @override
  List<Object?> get props => [];
}

final class FaqInitial extends FaqState {}

final class FaqLoading extends FaqState {}

final class FaqSuccess extends FaqState {
  final List<FAQItem> items;
  final List<String> categories;
  final String? selectedCategory;

  const FaqSuccess({
    required this.items,
    required this.categories,
    this.selectedCategory,
  });

  List<FAQItem> get filteredItems {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return items;
    }
    return items
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  FaqSuccess copyWith({
    List<FAQItem>? items,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
  }) {
    return FaqSuccess(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
    );
  }

  @override
  List<Object?> get props => [items, categories, selectedCategory];
}

final class FaqError extends FaqState {
  final String message;

  const FaqError({required this.message});

  @override
  List<Object?> get props => [message];
}
