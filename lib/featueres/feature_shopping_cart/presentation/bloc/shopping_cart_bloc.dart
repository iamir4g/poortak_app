import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'dart:developer';

class ShoppingCartBloc extends Bloc<ShoppingCartEvent, ShoppingCartState> {
  final ShoppingCartRepository repository;

  ShoppingCartBloc({required this.repository}) : super(ShoppingCartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);

    // Local Cart Events
    on<AddToLocalCartEvent>(_onAddToLocalCart);
    on<GetLocalCartEvent>(_onGetLocalCart);
    on<RemoveFromLocalCartEvent>(_onRemoveFromLocalCart);
    on<ClearLocalCartEvent>(_onClearLocalCart);
    on<SyncLocalCartToBackendEvent>(_onSyncLocalCartToBackend);
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
      final cart = await repository.removeFromCart(event.itemId);
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

  // Local Cart Event Handlers
  Future<void> _onAddToLocalCart(
      AddToLocalCartEvent event, Emitter<ShoppingCartState> emit) async {
    try {
      log("🛒 Adding item to local cart: Type=${event.type}, ID=${event.itemId}");
      await repository.addToLocalCart(event.type, event.itemId);
      final items = await repository.getLocalCartItems();
      log("✅ Item added to local cart successfully. Total items: ${items.length}");
      emit(LocalCartItemAdded(items));
    } catch (e) {
      log("❌ Failed to add item to local cart: $e");
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onGetLocalCart(
      GetLocalCartEvent event, Emitter<ShoppingCartState> emit) async {
    try {
      log("📋 Getting local cart items...");
      final items = await repository.getLocalCartItems();
      log("📊 Retrieved ${items.length} local cart items");
      emit(LocalCartLoaded(items));
    } catch (e) {
      log("❌ Failed to get local cart items: $e");
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromLocalCart(
      RemoveFromLocalCartEvent event, Emitter<ShoppingCartState> emit) async {
    try {
      log("🗑️ Removing item from local cart: Type=${event.type}, ID=${event.itemId}");
      await repository.removeFromLocalCart(event.type, event.itemId);
      final items = await repository.getLocalCartItems();
      log("✅ Item removed from local cart successfully. Remaining items: ${items.length}");
      emit(LocalCartItemRemoved(items));
    } catch (e) {
      log("❌ Failed to remove item from local cart: $e");
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onClearLocalCart(
      ClearLocalCartEvent event, Emitter<ShoppingCartState> emit) async {
    try {
      log("🧹 Clearing local cart...");
      await repository.clearLocalCart();
      log("✅ Local cart cleared successfully");
      emit(LocalCartCleared());
    } catch (e) {
      log("❌ Failed to clear local cart: $e");
      emit(ShoppingCartError(e.toString()));
    }
  }

  Future<void> _onSyncLocalCartToBackend(SyncLocalCartToBackendEvent event,
      Emitter<ShoppingCartState> emit) async {
    try {
      log("🔄 Processing SyncLocalCartToBackendEvent...");

      // Check if there are items to sync first
      final localCartItems = await repository.getLocalCartItems();
      log("📊 Found ${localCartItems.length} items to sync");

      if (localCartItems.isEmpty) {
        log("📭 No items to sync - emitting LocalCartSyncSuccess immediately");
        emit(LocalCartSyncSuccess());
        return;
      }

      log("📤 Calling repository.syncLocalCartToBackend()...");

      await repository.syncLocalCartToBackend();

      log("✅ Local cart sync to backend completed successfully");
      emit(LocalCartSyncSuccess());
    } catch (e) {
      log("❌ Local cart sync to backend failed: $e");
      emit(LocalCartSyncError(e.toString()));
    }
  }
}
