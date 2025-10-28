import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/iknow_access_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'iknow_access_event.dart';
part 'iknow_access_state.dart';

class IknowAccessBloc extends Bloc<IknowAccessEvent, IknowAccessState> {
  final SayarehRepository sayarehRepository;

  // Cache to store access data
  IknowAccess? _accessData;

  IknowAccessBloc({required this.sayarehRepository})
      : super(IknowAccessInitial()) {
    on<FetchIknowAccessEvent>((event, emit) async {
      // If data is already cached, use it
      if (_accessData != null && !event.forceRefresh) {
        emit(IknowAccessCompleted(_accessData!));
        return;
      }

      emit(IknowAccessLoading());

      final response = await sayarehRepository.fetchIknowAccess();
      if (response is DataSuccess) {
        _accessData = response.data;
        emit(IknowAccessCompleted(response.data!));
      } else {
        emit(IknowAccessError(response.error ?? "خطا در دریافت اطلاعات"));
      }
    });

    on<CheckCourseAccessEvent>((event, emit) async {
      // Ensure data is loaded
      if (_accessData == null) {
        emit(IknowAccessLoading());
        final response = await sayarehRepository.fetchIknowAccess();
        if (response is DataSuccess) {
          _accessData = response.data;
        } else {
          emit(IknowAccessError(response.error ?? "خطا در دریافت اطلاعات"));
          return;
        }
      }

      // Emit current state if access data exists
      if (_accessData != null) {
        emit(IknowAccessCompleted(_accessData!));
      }
    });

    on<ClearIknowAccessEvent>((event, emit) {
      _accessData = null;
      emit(IknowAccessInitial());
    });
  }

  // Helper method to check if user has access to a course
  bool hasCourseAccess(String courseId) {
    return _accessData?.data.hasCourseAccess(courseId) ?? false;
  }

  // Helper method to check if user has access to a book
  bool hasBookAccess(String bookId) {
    return _accessData?.data.hasBookAccess(bookId) ?? false;
  }
}
