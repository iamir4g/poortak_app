part of 'single_book_cubit.dart';

abstract class SingleBookDataStatus {}

class SingleBookDataInitial extends SingleBookDataStatus {}

class SingleBookDataLoading extends SingleBookDataStatus {}

class SingleBookDataCompleted extends SingleBookDataStatus {
  final SingleBookModel data;
  SingleBookDataCompleted(this.data);
}

class SingleBookDataError extends SingleBookDataStatus {
  final String errorMessage;
  SingleBookDataError(this.errorMessage);
}
