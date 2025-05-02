import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final SayarehRepository sayarehRepository;
  LessonBloc({required this.sayarehRepository}) : super(LessonInitial()) {
    on<GetLessonEvenet>((event, emit) async {
      emit(LessonLoading());
      final response = await sayarehRepository.fetchCourseById(event.id);
      if (response is DataSuccess) {
        emit(LessonSuccess(lesson: response.data!));
      } else {
        emit(LessonError(message: response.error ?? "خطا در دریافت اطلاعات"));
      }
    });
  }
}
