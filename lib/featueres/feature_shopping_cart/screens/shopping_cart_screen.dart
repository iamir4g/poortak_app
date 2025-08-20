import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';

import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/empty_cart_widget.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'dart:developer';

class ShoppingCartScreen extends StatefulWidget {
  static const routeName = "/shopping_cart_screen";
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) {
        final bloc = ShoppingCartBloc(repository: locator());
        // Check if user is logged in to determine which cart to load
        _loadAppropriateCart(bloc);
        return bloc;
      },
      child: Builder(
        builder: (context) {
          return BlocBuilder<ShoppingCartBloc, ShoppingCartState>(
            builder: (context, state) {
              log("🔄 Builder called with state: ${state.runtimeType}");

              if (state is ShoppingCartLoading) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE8F0FC),
                        Color(0xFFFCEBF1),
                        Color(0xFFEFE8FC),
                      ],
                      stops: [0.1, 0.54, 1.0],
                    ),
                  ),
                  child: const Center(child: DotLoadingWidget(size: 100)),
                );
              }

              // Handle server cart (for logged-in users)
              if (state is ShoppingCartLoaded) {
                log("📦 Builder: ShoppingCartLoaded state - Cart has ${state.cart.items.length} items");

                if (state.cart.items.isEmpty) {
                  log("📭 Builder: Server cart is empty - showing empty UI");
                  return buildEmptyCartUI();
                }

                log("✅ Builder: Server cart has items - showing cart UI");
                return _buildCartItemsUI(state.cart, l10n);
              }

              // Handle local cart (for non-logged-in users)
              if (state is LocalCartLoaded) {
                log("📱 Builder: LocalCartLoaded state - Cart has ${state.items.length} items");

                if (state.items.isEmpty) {
                  log("📭 Builder: Local cart is empty - showing empty UI");
                  return buildEmptyCartUI();
                }

                log("✅ Builder: Local cart has items - showing local cart UI");
                return _buildLocalCartItemsUI(state.items, l10n);
              }

              // Handle local cart item added/removed states
              if (state is LocalCartItemAdded ||
                  state is LocalCartItemRemoved) {
                // Refresh the cart to show updated items
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadAppropriateCart(context.read<ShoppingCartBloc>());
                });
              }

              // Handle local cart cleared state
              if (state is LocalCartCleared) {
                // Refresh the cart to show empty state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadAppropriateCart(context.read<ShoppingCartBloc>());
                });
              }

              if (state is ShoppingCartError) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE8F0FC),
                        Color(0xFFFCEBF1),
                        Color(0xFFEFE8FC),
                      ],
                      stops: [0.1, 0.54, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800),
                          onPressed: () {
                            _loadAppropriateCart(
                                context.read<ShoppingCartBloc>());
                          },
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container();
            },
          );
        },
      ),
    );
  }

  // Helper method to load appropriate cart based on login status
  void _loadAppropriateCart(ShoppingCartBloc bloc) async {
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = prefsOperator.isLoggedIn();

    log("🛒 Loading appropriate cart...");
    log("   User logged in: $isLoggedIn");

    if (isLoggedIn) {
      // User is logged in - get cart from server
      log("📤 Loading cart from server...");
      bloc.add(GetCartEvent());
    } else {
      // User is not logged in - get local cart
      log("📱 Loading local cart...");
      bloc.add(GetLocalCartEvent());
    }
  }

  // Build empty cart UI

  // Build server cart items UI
  Widget _buildCartItemsUI(ShoppingCart cart, AppLocalizations? l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F0FC),
            Color(0xFFFCEBF1),
            Color(0xFFEFE8FC),
          ],
          stops: [0.1, 0.54, 1.0],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  width: 360,
                  height: 144,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: MyColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        left: -10,
                        child: IconButton(
                          iconSize: 18,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context
                                .read<ShoppingCartBloc>()
                                .add(RemoveFromCartEvent(item.title));
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title),
                              Text(item.description),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Row(
                          children: [
                            Text(item.price.toString().addComma),
                            Text("تومان"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n?.total_price} ${cart.items.fold(0, (sum, item) => sum + item.price).addComma}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  width: 208,
                  height: 60,
                  lable: l10n?.pay_now ?? "Pay Now",
                  onPressed: () async {
                    try {
                      // Show loading message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('در حال پردازش...'),
                          backgroundColor: Colors.blue,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // Call checkout API directly
                      final apiProvider = locator<ShoppingCartApiProvider>();
                      final response = await apiProvider.checkoutCart();

                      log("✅ Checkout response: ${response.data}");

                      // Parse response and get URL
                      final url = response.data['data']['url'] as String;
                      log("🔗 Payment URL: $url");

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('در حال انتقال به درگاه پرداخت...'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // Launch payment URL
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      log("❌ Checkout failed: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطا در پردازش پرداخت: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build local cart items UI
  Widget _buildLocalCartItemsUI(
      List<Map<String, dynamic>> localCartItems, AppLocalizations? l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F0FC),
            Color(0xFFFCEBF1),
            Color(0xFFEFE8FC),
          ],
          stops: [0.1, 0.54, 1.0],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: localCartItems.length,
              itemBuilder: (context, index) {
                final item = localCartItems[index];
                final itemType = item['type'] as String;
                final itemId = item['itemId'] as String;

                // Create display title based on type
                String displayTitle = '';
                String displayDescription = '';
                int displayPrice = 0;

                if (itemType == 'IKnowCourse') {
                  displayTitle = 'دوره آموزشی';
                  displayDescription = 'دوره تک درس';
                  displayPrice = 75000; // Default price for single course
                } else if (itemType == 'IKnow') {
                  displayTitle = 'مجموعه کامل سیاره آی نو';
                  displayDescription = 'شامل تمام دوره ها و کتاب ها';
                  displayPrice = 750000; // Default price for bundle
                } else {
                  displayTitle = 'محصول';
                  displayDescription = 'محصول انتخابی';
                  displayPrice = 50000;
                }

                return Container(
                  width: 360,
                  height: 144,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: MyColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        left: -10,
                        child: IconButton(
                          iconSize: 18,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context.read<ShoppingCartBloc>().add(
                                RemoveFromLocalCartEvent(itemType, itemId));
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  itemType == 'IKnowCourse'
                                      ? Icons.school
                                      : Icons.library_books,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayDescription,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'نوع: ${itemType == 'IKnowCourse' ? 'دوره تکی' : 'مجموعه کامل'}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Row(
                          children: [
                            Text(displayPrice.toString().addComma),
                            const Text("تومان"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n?.total_price} ${_calculateTotalPrice(localCartItems).addComma}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  width: 208,
                  height: 60,
                  lable: l10n?.pay_now ?? "Pay Now",
                  onPressed: () async {
                    try {
                      // Show loading message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('در حال پردازش...'),
                          backgroundColor: Colors.blue,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // Call checkout API directly
                      final apiProvider = locator<ShoppingCartApiProvider>();
                      final response = await apiProvider.checkoutCart();

                      log("✅ Checkout response: ${response.data}");

                      // Parse response and get URL
                      final url = response.data['data']['url'] as String;
                      log("🔗 Payment URL: $url");

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('در حال انتقال به درگاه پرداخت...'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // Launch payment URL
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      log("❌ Checkout failed: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطا در پردازش پرداخت: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate total price from local cart items
  int _calculateTotalPrice(List<Map<String, dynamic>> localCartItems) {
    int total = 0;
    for (final item in localCartItems) {
      final itemType = item['type'] as String;
      if (itemType == 'IKnowCourse') {
        total += 75000; // Price for single course
      } else if (itemType == 'IKnow') {
        total += 750000; // Price for bundle
      } else {
        total += 50000; // Default price
      }
    }
    return total;
  }
}
