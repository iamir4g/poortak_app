import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'converstion_event.dart';
part 'converstion_state.dart';

class ConverstionBloc extends Bloc<ConverstionEvent, ConverstionState> {
  final SayarehRepository sayarehRepository;

  ConverstionBloc({required this.sayarehRepository})
      : super(ConverstionInitial()) {
    on<GetConversationEvent>((event, emit) async {
      emit(ConverstionLoading());
      final response =
          await sayarehRepository.fetchSayarehConversation(event.id);

      if (response is DataSuccess) {
        // Fetch last playback position
        final playbackResponse =
            await sayarehRepository.fetchConversationPlayback(event.id);
        String? lastId;
        if (playbackResponse is DataSuccess) {
          lastId = playbackResponse.data;
        }

        emit(ConverstionSuccess(response.data!, lastConversationId: lastId));
      } else {
        emit(ConverstionError(response.error ?? "خطا در دریافت اطلاعات"));
      }
    });

    on<SaveConversationPlaybackEvent>((event, emit) async {
      await sayarehRepository.saveConversationPlayback(
        event.courseId,
        event.conversationId,
      );
    });
  }
}
