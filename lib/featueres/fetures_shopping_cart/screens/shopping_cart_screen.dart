import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/fetures_shopping_cart/presentation/bloc/shopping_cart_cubit.dart';
import 'package:poortak/locator.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ShoppingCartCubit(shoppingCartRepository: locator())..getCart(),
      child: Builder(
        builder: (context) {
          return BlocBuilder<ShoppingCartCubit, ShoppingCartState>(
            buildWhen: (previous, current) {
              if (previous.cartDataStatus == current.cartDataStatus) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state.cartDataStatus is ShoppingCartDataLoading) {
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

              if (state.cartDataStatus is ShoppingCartDataCompleted) {
                final ShoppingCartDataCompleted cartDataCompleted =
                    state.cartDataStatus as ShoppingCartDataCompleted;
                final ShoppingCart cart = cartDataCompleted.data;

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
                                          Text('Quantity: ${item.quantity}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            context
                                                .read<ShoppingCartCubit>()
                                                .updateQuantity(item.title,
                                                    item.quantity - 1);
                                          } else {
                                            context
                                                .read<ShoppingCartCubit>()
                                                .removeFromCart(item.title);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          context
                                              .read<ShoppingCartCubit>()
                                              .updateQuantity(item.title,
                                                  item.quantity + 1);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          context
                                              .read<ShoppingCartCubit>()
                                              .removeFromCart(item.title);
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
                                Text(
                                  'Total Items: ${cart.totalItems}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Total Amount: \$${cart.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ShoppingCartCubit>().clearCart();
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

              if (state.cartDataStatus is ShoppingCartDataError) {
                final ShoppingCartDataError cartDataError =
                    state.cartDataStatus as ShoppingCartDataError;

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
                          cartDataError.errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800),
                          onPressed: () {
                            context.read<ShoppingCartCubit>().getCart();
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
