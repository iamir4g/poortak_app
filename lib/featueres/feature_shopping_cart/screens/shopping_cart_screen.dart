import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/locator.dart';

class ShoppingCartScreen extends StatelessWidget {
  static const routeName = "/shopping_cart_screen";
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                              height: 80,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        maxRadius: 30,
                                        minRadius: 30,
                                        backgroundImage:
                                            NetworkImage(item.image),
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
                                          // Text('Quantity: ${item.quantity}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          // if (item.quantity > 1) {
                                          //   context
                                          //       .read<ShoppingCartBloc>()
                                          //       .add(UpdateQuantityEvent(
                                          //           item.title,
                                          //           item.quantity - 1));
                                          // } else {
                                          context.read<ShoppingCartBloc>().add(
                                              RemoveFromCartEvent(item.title));
                                          // }
                                        },
                                      ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.add),
                                      //   onPressed: () {
                                      //     context.read<ShoppingCartBloc>().add(
                                      //         UpdateQuantityEvent(item.title,
                                      //             item.quantity + 1));
                                      //   },
                                      // ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          context.read<ShoppingCartBloc>().add(
                                              RemoveFromCartEvent(item.title));
                                        },
                                      ),
                                    ],
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
                                // Text(
                                //   'Total Items: ${cart.totalItems}',
                                //   style: const TextStyle(fontSize: 16),
                                // ),
                                // Text(
                                //   'Total Amount: \$${cart.totalAmount.toStringAsFixed(2)}',
                                //   style: const TextStyle(
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<ShoppingCartBloc>()
                                    .add(ClearCartEvent());
                              },
                              child: const Text('Clear Cart'),
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
}
