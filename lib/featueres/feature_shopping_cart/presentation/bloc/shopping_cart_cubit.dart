import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';

part 'shopping_cart_state.dart';
part 'shopping_cart_data_status.dart';

class ShoppingCartCubit extends Cubit<ShoppingCartState> {
  final ShoppingCartRepository shoppingCartRepository;

  ShoppingCartCubit({required this.shoppingCartRepository})
      : super(ShoppingCartState(cartDataStatus: ShoppingCartDataInitial())) {
    // Load cart data when cubit is created
    getCart();
  }

  Future<void> getCart() async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    try {
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
    } catch (e) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(e.toString()),
      ));
    }
  }

  Future<void> addToCart(ShoppingCartItem item) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    try {
      DataState dataState = await shoppingCartRepository.addToCart(item);

      if (dataState is DataSuccess) {
        // Emit the new state immediately
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataCompleted(dataState.data),
        ));
        // Then refresh to ensure we have the latest data
        await getCart();
      } else if (dataState is DataFailed) {
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(e.toString()),
      ));
    }
  }

  Future<void> removeFromCart(String title) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    try {
      DataState dataState = await shoppingCartRepository.removeFromCart(title);

      if (dataState is DataSuccess) {
        // Emit the new state immediately
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataCompleted(dataState.data),
        ));
        // Then refresh to ensure we have the latest data
        await getCart();
      } else if (dataState is DataFailed) {
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(e.toString()),
      ));
    }
  }

  Future<void> updateQuantity(String title, int quantity) async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    try {
      DataState dataState =
          await shoppingCartRepository.updateQuantity(title, quantity);

      if (dataState is DataSuccess) {
        // Emit the new state immediately
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataCompleted(dataState.data),
        ));
        // Then refresh to ensure we have the latest data
        await getCart();
      } else if (dataState is DataFailed) {
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(e.toString()),
      ));
    }
  }

  Future<void> clearCart() async {
    emit(state.copyWith(cartDataStatus: ShoppingCartDataLoading()));

    try {
      DataState dataState = await shoppingCartRepository.clearCart();

      if (dataState is DataSuccess) {
        // Emit the new state immediately
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataCompleted(dataState.data),
        ));
        // Then refresh to ensure we have the latest data
        await getCart();
      } else if (dataState is DataFailed) {
        emit(state.copyWith(
          cartDataStatus: ShoppingCartDataError(dataState.error ?? ""),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        cartDataStatus: ShoppingCartDataError(e.toString()),
      ));
    }
  }

  int getCartItems() {
    if (state.cartDataStatus is ShoppingCartDataCompleted) {
      return (state.cartDataStatus as ShoppingCartDataCompleted)
          .data
          .items
          .length;
    }
    return 0;
  }

  int getCartItemsLength() {
    if (state.cartDataStatus is ShoppingCartDataCompleted) {
      return (state.cartDataStatus as ShoppingCartDataCompleted)
          .data
          .items
          .length;
    }
    return 0;
  }
}
