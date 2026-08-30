import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_Menu/data/models/contact_us_model.dart';
import 'package:poortak/featueres/feature_Menu/repositories/menu_repository.dart';

part 'contact_us_event.dart';
part 'contact_us_state.dart';

class ContactUsBloc extends Bloc<ContactUsEvent, ContactUsState> {
  final MenuRepository menuRepository;

  ContactUsBloc({required this.menuRepository}) : super(ContactUsInitial()) {
    on<GetContactUsInfoEvent>(_onGetContactUsInfo);
  }

  Future<void> _onGetContactUsInfo(
    GetContactUsInfoEvent event,
    Emitter<ContactUsState> emit,
  ) async {
    emit(ContactUsLoading());
    final response = await menuRepository.getContactUsInfo();
    if (response is DataSuccess) {
      emit(ContactUsSuccess(info: response.data!));
    } else {
      emit(ContactUsError(
        message: response.error ?? "خطا در دریافت اطلاعات تماس",
      ));
    }
  }
}
