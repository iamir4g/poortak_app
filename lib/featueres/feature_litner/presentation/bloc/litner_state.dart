import 'package:equatable/equatable.dart';
import 'package:poortak/featueres/feature_litner/data/models/create_word_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/overview_linter_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/review_words_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/submit_review_word.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';

abstract class LitnerState extends Equatable {
  const LitnerState();

  @override
  List<Object> get props => [];
}

class LitnerInitial extends LitnerState {}

class LitnerLoading extends LitnerState {}

class CreateWordSuccess extends LitnerState {
  final CreateWord createWord;

  const CreateWordSuccess(this.createWord);

  @override
  List<Object> get props => [createWord];
}

class ReviewWordsSuccess extends LitnerState {
  final ReviewWords reviewWords;

  const ReviewWordsSuccess(this.reviewWords);

  @override
  List<Object> get props => [reviewWords];
}

class SubmitReviewWordSuccess extends LitnerState {
  final SubmitReviewWord submitReviewWord;

  const SubmitReviewWordSuccess(this.submitReviewWord);

  @override
  List<Object> get props => [submitReviewWord];
}

class ListWordsSuccess extends LitnerState {
  final ListWords listWords;

  const ListWordsSuccess(this.listWords);

  @override
  List<Object> get props => [listWords];
}

class OverviewLitnerSuccess extends LitnerState {
  final OverviewLinter overviewLitner;

  const OverviewLitnerSuccess(this.overviewLitner);

  @override
  List<Object> get props => [overviewLitner];
}

class LitnerError extends LitnerState {
  final String message;

  const LitnerError(this.message);

  @override
  List<Object> get props => [message];
}
