import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/get_cart_model.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'dart:developer';
import 'dart:async';
import 'package:poortak/featueres/feature_shopping_cart/data/models/checkout_cart_model.dart';

class ShoppingCartRepository {
  ShoppingCart _cart = ShoppingCart();
  final PrefsOperator _prefsOperator = locator<PrefsOperator>();
  final ShoppingCartApiProvider _apiProvider;

  ShoppingCartRepository({required ShoppingCartApiProvider apiProvider})
      : _apiProvider = apiProvider;

  Future<ShoppingCart> getCart() async {
    log("🛒 Getting cart from server...");
    try {
      final response = await _apiProvider.getCart();
      log("📦 Server cart response received");

      // Parse the server response
      final getCartModel = GetCartModel.fromJson(response.data);
      log("📊 Server cart has ${getCartModel.data.cart.items?.length ?? 0} items");

      // Check if cart is empty or items is null
      if (getCartModel.data.cart.items == null ||
          getCartModel.data.cart.items!.isEmpty) {
        log("📭 Server cart is empty - creating empty ShoppingCart");
        _cart = ShoppingCart(items: []);
        return _cart;
      }

      // Convert server cart items to ShoppingCartItem format
      final List<ShoppingCartItem> shoppingCartItems = [];

      for (final cartItem in getCartModel.data.cart.items!) {
        log("🔄 Converting server cart item: ${cartItem.itemId} (${cartItem.type})");

        // Create display title based on type
        String displayTitle = '';
        String displayDescription = '';

        if (cartItem.type == 'IKnowCourse') {
          displayTitle = 'دوره آموزشی';
          displayDescription = 'دوره تک درس';
        } else if (cartItem.type == 'IKnow') {
          displayTitle = 'مجموعه کامل سیاره آی نو';
          displayDescription = 'شامل تمام دوره ها و کتاب ها';
        } else {
          displayTitle = 'محصول';
          displayDescription = 'محصول انتخابی';
        }

        final shoppingCartItem = ShoppingCartItem(
          title: displayTitle,
          description: displayDescription,
          image: '', // Server doesn't provide image URL, using empty for now
          isLock: false, // Assuming items in cart are unlocked
          price: int.parse(cartItem.price),
        );

        shoppingCartItems.add(shoppingCartItem);
        log("✅ Converted item: ${shoppingCartItem.title} - ${shoppingCartItem.price} تومان");
      }

      // Create new ShoppingCart with server items
      _cart = ShoppingCart(items: shoppingCartItems);
      log("🎉 Successfully converted server cart to ShoppingCart format with ${shoppingCartItems.length} items");

      return _cart;
    } catch (e) {
      log("❌ Error getting cart from server: $e");
      rethrow;
    }
  }

  Future<ShoppingCart> addToCart(ShoppingCartItem item) async {
    _cart.addItem(item);
    return _cart;
  }

  Future<ShoppingCart> removeFromCart(String title) async {
    _cart.removeItem(title);
    return _cart;
  }

  Future<ShoppingCart> updateQuantity(String title, int quantity) async {
    _cart.updateQuantity(title, quantity);
    return _cart;
  }

  Future<ShoppingCart> clearCart() async {
    _cart = ShoppingCart();
    return _cart;
  }

  // Local Cart Operations
  Future<List<Map<String, dynamic>>> getLocalCartItems() async {
    return await _prefsOperator.getLocalCartItems();
  }

  Future<void> addToLocalCart(String type, String itemId) async {
    await _prefsOperator.saveLocalCartItem(type, itemId);
  }

  Future<void> removeFromLocalCart(String type, String itemId) async {
    await _prefsOperator.removeLocalCartItem(type, itemId);
  }

  Future<void> clearLocalCart() async {
    await _prefsOperator.clearLocalCart();
  }

  Future<String> checkoutCart() async {
    log("💳 Checking out cart...");
    try {
      final response = await _apiProvider.checkoutCart();
      log("📦 Checkout response received");

      // Parse the checkout response
      final checkoutModel = CheckoutCartModel.fromJson(response.data);
      log("📊 Checkout successful: ${checkoutModel.ok}");

      if (checkoutModel.ok && checkoutModel.data != null) {
        log("🔗 Payment URL: ${checkoutModel.data!.url}");
        return checkoutModel.data!.url;
      } else {
        throw Exception('Checkout failed: Invalid response from server');
      }
    } catch (e) {
      log("❌ Error during checkout: $e");
      rethrow;
    }
  }

  // Sync Local Cart to Backend with retry mechanism
  Future<void> syncLocalCartToBackend() async {
    log("🔄 Starting local cart sync to backend...");
    final localCartItems = await getLocalCartItems();

    log("📊 Total local cart items to sync: ${localCartItems.length}");

    if (localCartItems.isEmpty) {
      log("📭 No local cart items found - nothing to sync");
      log("ℹ️ Skipping sync process as there are no items to send to server");
      return;
    }

    log("✅ Proceeding with sync for ${localCartItems.length} items");
    int successCount = 0;
    int failureCount = 0;

    for (int i = 0; i < localCartItems.length; i++) {
      final item = localCartItems[i];
      final itemType = item['type'] as String;
      final itemId = item['itemId'] as String;

      log("📤 Syncing item ${i + 1}/${localCartItems.length}:");
      log("   Type: $itemType");
      log("   ID: $itemId");
      log("   Added: ${item['addedAt']}");

      bool syncSuccess = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!syncSuccess && retryCount < maxRetries) {
        try {
          if (retryCount > 0) {
            log("🔄 Retry attempt ${retryCount + 1} for item ${i + 1}...");
            await Future.delayed(
                Duration(seconds: retryCount * 2)); // Exponential backoff
          }

          log("🌐 Making API call: POST /cart");
          log("   Request body: {\"type\": \"$itemType\", \"itemId\": \"$itemId\"}");

          await _apiProvider.addToCart(
            CartType.values.firstWhere((e) => e.name == itemType),
            itemId,
          );

          log("✅ Successfully synced item ${i + 1}: $itemType - $itemId");
          successCount++;
          syncSuccess = true;
        } catch (e) {
          retryCount++;
          if (e is UnauthorisedException) {
            log("🔐 Authentication error on attempt $retryCount for item ${i + 1}: $e");
            if (retryCount >= maxRetries) {
              log("❌ Max retries reached for item ${i + 1} - authentication failed");
              failureCount++;
            }
          } else {
            log("❌ Failed to sync item ${i + 1} on attempt $retryCount: $e");
            if (retryCount >= maxRetries) {
              log("❌ Max retries reached for item ${i + 1}");
              failureCount++;
            }
          }
        }
      }
    }

    log("📈 Sync summary:");
    log("   ✅ Successfully synced: $successCount items");
    log("   ❌ Failed to sync: $failureCount items");
    log("   📊 Total processed: ${localCartItems.length} items");

    if (successCount > 0) {
      log("🧹 Clearing local cart after successful sync...");
      await clearLocalCart();
      log("✅ Local cart cleared successfully");
    } else {
      log("⚠️ No items were successfully synced - keeping local cart intact");
    }

    log("🎉 Local cart sync process completed!");
  }
}
