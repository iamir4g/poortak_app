import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/services/payment_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zarinpal/zarinpal.dart';
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
                log("📦 Processing ShoppingCartLoaded state");
                final ShoppingCart cart = state.cart;
                log("   Cart has ${cart.items.length} items");

                if (cart.items.isEmpty) {
                  log("📭 Server cart is empty - showing empty UI");
                  return _buildEmptyCartUI();
                }

                log("✅ Server cart has items - showing cart UI");
                return _buildCartItemsUI(cart, l10n);
              }

              // Handle local cart (for non-logged-in users)
              if (state is LocalCartLoaded) {
                log("📱 Processing LocalCartLoaded state");
                final List<Map<String, dynamic>> localCartItems = state.items;
                log("   Local cart has ${localCartItems.length} items");

                if (localCartItems.isEmpty) {
                  log("📭 Local cart is empty - showing empty UI");
                  return _buildEmptyCartUI();
                }

                log("✅ Local cart has items - showing local cart UI");
                return _buildLocalCartItemsUI(localCartItems, l10n);
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
  Widget _buildEmptyCartUI() {
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
          const SizedBox(height: 40),
          // Top section: star icon and score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/star_icon.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'مجموع امتیاز های شما : ',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF29303D),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '۲۰۰ سکه',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF29303D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Body: white container with border, illustration, and text
          Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color(0xFFC2C9D6), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/empty_cart_illustration.png',
                    width: 140,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'سبد خرید شما خالی است!',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF3D495C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  onPressed: () {
                    final totalAmount =
                        cart.items.fold(0, (sum, item) => sum + item.price);
                    PaymentService paymentService = PaymentService();

                    paymentService.startPayment(
                      amount: totalAmount *
                          10, // Convert to Rials (1 Toman = 10 Rials)
                      description: "پرداخت سفارش از پورتک",
                      callbackUrl: "poortak://payment",
                      onPaymentComplete: (isSuccess, refId) async {
                        print('Payment completion status: $isSuccess');
                        print('Payment reference ID: $refId');

                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'پرداخت با موفقیت انجام شد. کد پیگیری: $refId'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear cart after successful payment
                          context
                              .read<ShoppingCartBloc>()
                              .add(ClearCartEvent());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'پرداخت با خطا مواجه شد. لطفا دوباره تلاش کنید.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
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
                  onPressed: () {
                    final totalAmount = _calculateTotalPrice(localCartItems);
                    PaymentService paymentService = PaymentService();

                    paymentService.startPayment(
                      amount: totalAmount *
                          10, // Convert to Rials (1 Toman = 10 Rials)
                      description: "پرداخت سفارش از پورتک",
                      callbackUrl: "return://payment",
                      onPaymentComplete: (isSuccess, refId) async {
                        print('Payment completion status: $isSuccess');
                        print('Payment reference ID: $refId');

                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'پرداخت با موفقیت انجام شد. کد پیگیری: $refId'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear local cart after successful payment
                          context
                              .read<ShoppingCartBloc>()
                              .add(ClearLocalCartEvent());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'پرداخت با خطا مواجه شد. لطفا دوباره تلاش کنید.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
