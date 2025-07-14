import 'package:equatable/equatable.dart';

abstract class LitnerEvent extends Equatable {
  const LitnerEvent();

  @override
  List<Object> get props => [];
}

class CreateWordEvent extends LitnerEvent {
  final String word;
  final String translation;

  const CreateWordEvent({
    required this.word,
    required this.translation,
  });

  @override
  List<Object> get props => [word, translation];
}

class ReviewWordsEvent extends LitnerEvent {
  const ReviewWordsEvent();
}

class SubmitReviewWordEvent extends LitnerEvent {
  final String wordId;
  final bool success;

  const SubmitReviewWordEvent({
    required this.wordId,
    required this.success,
  });

  @override
  List<Object> get props => [wordId, success];
}

class FetchListWordsEvent extends LitnerEvent {
  final int size;
  final int page;
  final String order;
  final String boxLevels;
  final String word;
  final String query;
  const FetchListWordsEvent({
    required this.size,
    required this.page,
    required this.order,
    required this.boxLevels,
    required this.word,
    required this.query,
  });

  @override
  List<Object> get props => [size, page, order];
}

class FetchOverviewLitnerEvent extends LitnerEvent {
  const FetchOverviewLitnerEvent();
}
