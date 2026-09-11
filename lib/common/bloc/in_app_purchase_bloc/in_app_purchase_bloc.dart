import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/models/bazaar_purchase_result.dart';
import 'package:poortak/common/services/cafe_bazaar_purchase_service.dart';
import 'package:poortak/config/app_flavor.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';

part 'in_app_purchase_event.dart';
part 'in_app_purchase_state.dart';

class InAppPurchaseBloc extends Bloc<InAppPurchaseEvent, InAppPurchaseState> {
  final CafeBazaarPurchaseService _service;
  final ShoppingCartRepository _cartRepository;

  InAppPurchaseBloc({
    required CafeBazaarPurchaseService service,
    required ShoppingCartRepository cartRepository,
  })  : _service = service,
        _cartRepository = cartRepository,
        super(const InAppPurchaseInitial()) {
    on<ConnectInAppPurchaseEvent>(_onConnect);
    on<PurchaseProductsEvent>(_onPurchaseProducts);
    on<DisconnectInAppPurchaseEvent>(_onDisconnect);
  }

  Future<void> _onConnect(
    ConnectInAppPurchaseEvent event,
    Emitter<InAppPurchaseState> emit,
  ) async {
    if (!AppFlavor.useBazaarIap) {
      emit(const InAppPurchaseUnavailable());
      return;
    }

    emit(const InAppPurchaseConnecting());
    try {
      await _service.connect();
      emit(const InAppPurchaseConnected());
    } catch (e) {
      debugPrint('🛒 [Bazaar] bloc connect error: $e');
      emit(InAppPurchaseError(e.toString()));
    }
  }

  Future<void> _onPurchaseProducts(
    PurchaseProductsEvent event,
    Emitter<InAppPurchaseState> emit,
  ) async {
    if (!AppFlavor.useBazaarIap) {
      emit(const InAppPurchaseError(
        'پرداخت درون‌برنامه‌ای بازار فقط در نسخه اندروید کافه بازار فعال است',
      ));
      return;
    }

    final bazaarSkus = event.productIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (bazaarSkus.isEmpty) {
      emit(const InAppPurchaseError(
        'شناسه محصول بازار (SKU) برای این آیتم‌ها تنظیم نشده',
      ));
      return;
    }

    emit(InAppPurchasePurchasing(bazaarSkus.first));
    try {
      await _service.ensureConnected();
      final alreadyOwned = await _service.getPurchasedProducts();
      final purchases = <BazaarPurchaseResult>[];

      for (final sku in bazaarSkus) {
        emit(InAppPurchasePurchasing(sku));
        BazaarPurchaseResult? existing;
        for (final item in alreadyOwned) {
          if (item.productId == sku) {
            existing = item;
            break;
          }
        }
        if (existing != null) {
          debugPrint('🛒 [Bazaar] already owned: $sku');
          purchases.add(existing);
          continue;
        }

        final result = await _service.purchase(
          sku,
          payload: event.payload ?? '',
        );
        await _cartRepository.verifyBazaarPurchase(result);
        purchases.add(result);
      }

      emit(InAppPurchaseSuccess(purchases));
    } catch (e) {
      debugPrint('🛒 [Bazaar] purchase error: $e');
      emit(InAppPurchaseError(_friendlyError(e)));
    }
  }

  Future<void> _onDisconnect(
    DisconnectInAppPurchaseEvent event,
    Emitter<InAppPurchaseState> emit,
  ) async {
    await _service.disconnect();
    emit(const InAppPurchaseUnavailable());
  }

  String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('cancel') || text.contains('لغو')) {
      return 'خرید لغو شد';
    }
    if (text.contains('not connected') || text.contains('bazaar')) {
      return 'لطفا برنامه کافه بازار را نصب و وارد حساب شوید';
    }
    return error.toString();
  }
}
