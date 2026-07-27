part of 'faq_bloc.dart';

sealed class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object> get props => [];
}

class GetFaqEvent extends FaqEvent {
  const GetFaqEvent();
}

class ToggleFaqExpansionEvent extends FaqEvent {
  final String id;

  const ToggleFaqExpansionEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class SelectFaqCategoryEvent extends FaqEvent {
  final String? category;

  const SelectFaqCategoryEvent({this.category});

  @override
  List<Object> get props => [category ?? ''];
}
