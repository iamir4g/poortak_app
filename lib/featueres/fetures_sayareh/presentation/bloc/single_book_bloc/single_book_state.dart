part of 'single_book_cubit.dart';

class SingleBookState {
  final SingleBookDataStatus singleBookDataStatus;

  SingleBookState({required this.singleBookDataStatus});

  SingleBookState copyWith({SingleBookDataStatus? singleBookDataStatus}) {
    return SingleBookState(
      singleBookDataStatus: singleBookDataStatus ?? this.singleBookDataStatus,
    );
  }
}
