import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';

class ShoppingCartBloc extends Bloc<ShoppingCartEvent, ShoppingCartState> {
  final ShoppingCartRepository repository;

  ShoppingCartBloc({required this.repository}) : super(ShoppingCartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onGetCart(
      GetCartEvent event, Emitter<ShoppingCartState> emit) async {
    emit(ShoppingCartLoading());
    try {
      final cart = await repository.getCart();
      emit(ShoppingCartLoaded(cart));
    } catch (e) {
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(
      AddToCartEvent event, Emitter<ShoppingCartState> emit) async {
    emit(ShoppingCartLoading());
    try {
      final cart = await repository.addToCart(event.item);
      emit(ShoppingCartLoaded(cart));
    } catch (e) {
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCartEvent event, Emitter<ShoppingCartState> emit) async {
    emit(ShoppingCartLoading());
    try {
      final cart = await repository.removeFromCart(event.title);
      emit(ShoppingCartLoaded(cart));
    } catch (e) {
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<ShoppingCartState> emit) async {
    emit(ShoppingCartLoading());
    try {
      final cart = await repository.updateQuantity(event.title, event.quantity);
      emit(ShoppingCartLoaded(cart));
    } catch (e) {
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<ShoppingCartState> emit) async {
    emit(ShoppingCartLoading());
    try {
      final cart = await repository.clearCart();
      emit(ShoppingCartLoaded(cart));
    } catch (e) {
      emit(ShoppingCartError(e.toString()));
    }
  }
}
