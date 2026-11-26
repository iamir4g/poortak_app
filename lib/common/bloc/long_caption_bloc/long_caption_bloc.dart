import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/models/long_caption_model.dart';
import 'package:poortak/common/repositories/constants_repository.dart';
import 'package:poortak/common/resources/data_state.dart';

part 'long_caption_event.dart';
part 'long_caption_state.dart';

class LongCaptionBloc extends Bloc<LongCaptionEvent, LongCaptionState> {
  final ConstantsRepository constantsRepository;

  LongCaptionBloc({required this.constantsRepository})
      : super(LongCaptionInitial()) {
    on<GetLongCaptionEvent>(_onGetLongCaption);
  }

  Future<void> _onGetLongCaption(
    GetLongCaptionEvent event,
    Emitter<LongCaptionState> emit,
  ) async {
    emit(LongCaptionLoading());
    final response = await constantsRepository.getLongCaption(event.key);
    if (response is DataSuccess<LongCaptionModel>) {
      emit(LongCaptionSuccess(caption: response.data!));
    } else {
      emit(LongCaptionError(
        message: response.error ?? "خطا در دریافت متن",
      ));
    }
  }
}
