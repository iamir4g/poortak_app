import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/book_list_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'sayareh_state.dart';
part 'sayareh_data_status.dart';

class SayarehCubit extends Cubit<SayarehState> {
  SayarehRepository sayarehRepository;
  SayarehCubit({required this.sayarehRepository})
      : super(SayarehState(sayarehDataStatus: SayarehDataInitial()));

  void callSayarehDataEvent() async {
    emit(state.copyWith(sayarehDataStatus: SayarehDataLoading()));

    DataState dataState = await sayarehRepository.fetchAllCourses();
    DataState bookListState = await sayarehRepository.fetchBookList();

    if (dataState is DataSuccess && bookListState is DataSuccess) {
      // emit completed when both succeed
      emit(state.copyWith(
          sayarehDataStatus:
              SayarehDataCompleted(dataState.data, bookListState.data)));
    } else if (dataState is DataFailed) {
      // emit error for courses
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataError(dataState.error ?? "")));
    } else if (bookListState is DataFailed) {
      // emit error for book list
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataError(bookListState.error ?? "")));
    }
  }
}
