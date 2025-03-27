import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/fetures_shopping_cart/repositories/shopping_cart_repository.dart';

part 'shopping_cart_state.dart';
part 'shopping_cart_data_status.dart';

class ShoppingCartCubit extends Cubit<ShoppingCartState> {
  final ShoppingCartRepository shoppingCartRepository;

  ShoppingCartCubit({required this.shoppingCartRepository})
      : super(ShoppingCartState(cartDataStatus: ShoppingCartDataInitial()));

  void getCart() async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    DataState dataState = await shoppingCartRepository.getCart();

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataCompleted(dataState.data),
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
      ));
    }
  }

  void addToCart(ShoppingCartItem item) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    DataState dataState = await shoppingCartRepository.addToCart(item);

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataCompleted(dataState.data),
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
      ));
    }
  }

  void removeFromCart(String title) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    DataState dataState = await shoppingCartRepository.removeFromCart(title);

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataCompleted(dataState.data),
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
      ));
    }
  }

  void updateQuantity(String title, int quantity) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    DataState dataState =
        await shoppingCartRepository.updateQuantity(title, quantity);

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataCompleted(dataState.data),
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
      ));
    }
  }

  void clearCart() async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    DataState dataState = await shoppingCartRepository.clearCart();

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataCompleted(dataState.data),
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
      ));
    }
  }
}
