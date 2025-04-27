import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
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

    if (dataState is DataSuccess) {
      // emit completed
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      // emit error
      emit(state.copyWith(
          sayarehDataStatus: SayarehDataError(dataState.error ?? "")));
    }
  }
}
