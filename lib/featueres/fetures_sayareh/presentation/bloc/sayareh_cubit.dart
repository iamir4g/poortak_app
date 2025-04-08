import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'sayareh_state.dart';
part 'sayareh_data_status.dart';

class SayarehCubit extends Cubit<SayarehState> {
  SayarehRepository sayarehRepository;
  SayarehCubit({required this.sayarehRepository})
      : super(SayarehState(sayarehDataStatus: SayarehDataInitial()));

  void callSayarehDataEvent() async {
    emit(state.copyWith(sayarehDataStatus: SayarehDataLoading()));

    DataState dataState = await sayarehRepository.fetchSayarehData();

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

  void callSayarehStorageEvent() async {
    // Only emit loading if we're not already loading
    if (!(state.sayarehDataStatus is SayarehDataLoading)) {
      emit(state.copyWith(sayarehDataStatus: SayarehDataLoading()));
    }

    DataState dataState = await sayarehRepository.fetchSayarehStorage();

    if (dataState is DataSuccess) {
      emit(state.copyWith(
          sayarehDataStatus: SayarehStorageCompleted(dataState.data)));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
          sayarehDataStatus: SayarehStorageError(dataState.error ?? "")));
    }
  }
}
