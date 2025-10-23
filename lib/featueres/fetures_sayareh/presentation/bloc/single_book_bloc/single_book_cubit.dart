import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/single_book_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'single_book_state.dart';
part 'single_book_data_status.dart';

class SingleBookCubit extends Cubit<SingleBookState> {
  SayarehRepository sayarehRepository;

  SingleBookCubit({required this.sayarehRepository})
      : super(SingleBookState(singleBookDataStatus: SingleBookDataInitial()));

  void fetchBookById(String bookId) async {
    emit(state.copyWith(singleBookDataStatus: SingleBookDataLoading()));

    DataState dataState = await sayarehRepository.fetchBookById(bookId);

    // Check if cubit is still open before emitting
    if (isClosed) return;

    if (dataState is DataSuccess) {
      emit(state.copyWith(
          singleBookDataStatus: SingleBookDataCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
          singleBookDataStatus: SingleBookDataError(dataState.error ?? "")));
    }
  }
}
