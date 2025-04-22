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
import 'package:poortak/locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zarinpal/zarinpal.dart';
import 'package:url_launcher/url_launcher.dart';

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
      create: (context) =>
          ShoppingCartBloc(repository: locator())..add(GetCartEvent()),
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

              if (state is ShoppingCartLoaded) {
                final ShoppingCart cart = state.cart;

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
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                                            RemoveFromCartEvent(item.title));
                                        // }
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.red,
                                          // shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                final totalAmount = cart.items
                                    .fold(0, (sum, item) => sum + item.price);
                                PaymentService paymentService =
                                    PaymentService();

                                paymentService.startPayment(
                                  amount: totalAmount *
                                      10, // Convert to Rials (1 Toman = 10 Rials)
                                  description: "پرداخت سفارش از پورتک",
                                  callbackUrl: "poortak://payment",
                                  onPaymentComplete: (isSuccess, refId) async {
                                    print(
                                        'Payment completion status: $isSuccess');
                                    print('Payment reference ID: $refId');

                                    if (isSuccess) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                            context
                                .read<ShoppingCartBloc>()
                                .add(GetCartEvent());
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

// paymentService.startPayment(
                                //   amount:
                                //       totalAmount, // Convert to Rials (1 Toman = 10 Rials)
                                //   description: "پرداخت سفارش از پورتک",
                                //   callbackUrl: "poortak://payment",
                                //   onPaymentComplete: (isSuccess, refId) {
                                //     if (isSuccess) {
                                //       ScaffoldMessenger.of(context)
                                //           .showSnackBar(
                                //         SnackBar(
                                //           content: Text(
                                //               'پرداخت با موفقیت انجام شد. کد پیگیری: $refId'),
                                //           backgroundColor: Colors.green,
                                //         ),
                                //       );
                                //       // Clear cart after successful payment
                                //       context
                                //           .read<ShoppingCartBloc>()
                                //           .add(ClearCartEvent());
                                //     } else {
                                //       ScaffoldMessenger.of(context)
                                //           .showSnackBar(
                                //         const SnackBar(
                                //           content: Text(
                                //               'پرداخت با خطا مواجه شد. لطفا دوباره تلاش کنید.'),
                                //           backgroundColor: Colors.red,
                                //         ),
                                //       );
                                //     }
                                //   },
                                // );