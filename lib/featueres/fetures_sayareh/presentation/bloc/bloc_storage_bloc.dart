import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'bloc_storage_event.dart';
part 'bloc_storage_state.dart';

class BlocStorageBloc extends Bloc<BlocStorageEvent, BlocStorageState> {
  final SayarehRepository sayarehRepository;
  BlocStorageBloc({required this.sayarehRepository})
      : super(BlocStorageInitial()) {
    on<RequestStorageEvent>((event, emit) async {
      emit(BlocStorageLoading());
      final response = await sayarehRepository.fetchSayarehStorage();
      if (response is DataSuccess) {
        emit(BlocStorageCompleted(response.data!));
      } else {
        emit(BlocStorageError(response.error ?? "خطا در دریافت داده"));
      }
    });
  }
}
