import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/featureMenu/data/models/faq_model.dart';
import 'package:poortak/featueres/featureMenu/repositories/menu_repository.dart';

part 'faq_event.dart';
part 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final MenuRepository menuRepository;

  FaqBloc({required this.menuRepository}) : super(FaqInitial()) {
    on<GetFaqEvent>(_onGetFaq);
    on<ToggleFaqExpansionEvent>(_onToggleExpansion);
    on<SelectFaqCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onGetFaq(GetFaqEvent event, Emitter<FaqState> emit) async {
    emit(FaqLoading());
    final response = await menuRepository.getFaq();
    if (response is DataSuccess) {
      final items = response.data ?? [];
      final categories = items
          .map((e) => e.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      emit(FaqSuccess(items: items, categories: categories));
    } else {
      emit(FaqError(
        message: response.error ?? "خطا در دریافت سوالات رایج",
      ));
    }
  }

  void _onToggleExpansion(
    ToggleFaqExpansionEvent event,
    Emitter<FaqState> emit,
  ) {
    final current = state;
    if (current is! FaqSuccess) return;

    final updatedItems = current.items.map((item) {
      if (item.id == event.id) {
        return item.copyWith(isExpanded: !item.isExpanded);
      }
      return item.copyWith(isExpanded: false);
    }).toList();

    emit(current.copyWith(items: updatedItems));
  }

  void _onSelectCategory(
    SelectFaqCategoryEvent event,
    Emitter<FaqState> emit,
  ) {
    final current = state;
    if (current is! FaqSuccess) return;

    final collapsedItems =
        current.items.map((item) => item.copyWith(isExpanded: false)).toList();

    emit(current.copyWith(
      items: collapsedItems,
      selectedCategory: event.category,
      clearSelectedCategory: event.category == null,
    ));
  }
}
