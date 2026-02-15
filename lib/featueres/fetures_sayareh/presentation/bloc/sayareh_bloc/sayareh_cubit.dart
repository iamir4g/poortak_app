import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/book_list_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/locator.dart';

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

    AllCoursesProgressModel? progressData;
    final prefsOperator = locator<PrefsOperator>();

    if (prefsOperator.isLoggedIn()) {
      DataState progressState =
          await sayarehRepository.fetchAllCoursesProgress();
      if (progressState is DataSuccess) {
        progressData = progressState.data;
      }
    }

    if (isClosed) return;

    if (dataState is DataSuccess && bookListState is DataSuccess) {
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataCompleted(
              dataState.data, bookListState.data,
              progressData: progressData)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataError(dataState.error ?? "")));
    } else if (bookListState is DataFailed) {
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataError(bookListState.error ?? "")));
    }
  }
}
