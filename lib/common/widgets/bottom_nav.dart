import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

import '../blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

// import '../../features/feature_auth/presentation/screens/mobile_signup_screen.dart';

class BottomNav extends StatelessWidget {
  final PageController controller;

  const BottomNav({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var primaryColor = Theme.of(context).primaryColor;
    // TextTheme textTheme = Theme.of(context).textTheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      color: Colors.white,
      elevation: 0,
      child: Container(
          height: 50,
          padding: EdgeInsets.only(bottom: 8),
          child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => BottomNavCubit(),
                ),
                BlocProvider(
                  create: (context) {
                    final bloc = ShoppingCartBloc(repository: locator());
                    bloc.add(GetCartEvent());
                    return bloc;
                  },
                )
              ],
              child: Builder(builder: (context) {
                return BlocBuilder<BottomNavCubit, int>(
                    builder: (context, state) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildNavItem(
                          context: context,
                          state: state,
                          index: 0,
                          icon: "mage:video-player",
                          label: 'سیاره آینو',
                          controller: controller,
                        ),
                        _buildNavItem(
                          context: context,
                          state: state,
                          index: 1,
                          icon: "mage:search", //mdi:text-box-search-outline
                          label: 'کاوش',
                          controller: controller,
                          // useCustomIcon: false,
                        ),
                        _buildNavItem(
                          context: context,
                          state: state,
                          index: 2,
                          label: 'سبد خرید',
                          icon:
                              "hugeicons:shopping-cart-02", //"mage:shopping-cart",
                          controller: controller,
                          // useCustomIcon: false,
                          // materialIcon: Icons.shopping_cart_outlined,
                        ),
                        _buildNavItem(
                          context: context,
                          state: state,
                          index: 3,
                          label: 'لایتنر',
                          icon: "hugeicons:book-open-02", //"mage:book",
                          controller: controller,
                          // useCustomIcon: false,
                          // materialIcon: Icons.folder_outlined,
                        ),
                        _buildNavItem(
                          context: context,
                          state: state,
                          index: 4,
                          label: 'پروفایل',
                          controller: controller,
                          icon: "mynaui:user-square", //"mage:user",
                          // useCustomIcon: false,
                          // materialIcon: Icons.account_box_outlined,
                        ),
                      ]);
                });
              }))),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int state,
    required int index,
    required String label,
    required PageController controller,
    String icon = "",
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(index);
          controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (state == index
                  ? state == 2 && index == 2
                      ? BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
                          listener: (context, state) {
                            if (state is ShoppingCartLoaded) {
                              // You can add any side effects here when cart changes
                              // For example, showing a snackbar or updating other UI elements
                            }
                          },
                          builder: (context, cartState) {
                            if (cartState is ShoppingCartInitial) {
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            if (cartState is ShoppingCartLoading) {
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            if (cartState is ShoppingCartLoaded) {
                              final cart = cartState.cart;
                              if (cart.items.isNotEmpty) {
                                return badges.Badge(
                                  badgeContent:
                                      Text(cart.items.length.toString()),
                                  child: IconifyIcon(
                                      icon: icon, color: MyColors.primary),
                                );
                              }
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            return IconifyIcon(icon: icon, color: Colors.grey);
                          },
                        )
                      : IconifyIcon(
                          icon: icon,
                          color:
                              index == 1 ? MyColors.primary : MyColors.primary)
                  : index == 2
                      ? BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
                          listener: (context, state) {
                            if (state is ShoppingCartLoaded) {
                              // You can add any side effects here when cart changes
                              // For example, showing a snackbar or updating other UI elements
                            }
                          },
                          builder: (context, cartState) {
                            if (cartState is ShoppingCartInitial) {
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            if (cartState is ShoppingCartLoading) {
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            if (cartState is ShoppingCartLoaded) {
                              final cart = cartState.cart;
                              if (cart.items.isNotEmpty) {
                                return badges.Badge(
                                  badgeContent:
                                      Text(cart.items.length.toString()),
                                  child: IconifyIcon(
                                      icon: icon, color: Colors.grey),
                                );
                              }
                              return IconifyIcon(
                                  icon: icon, color: Colors.grey);
                            }

                            return IconifyIcon(icon: icon, color: Colors.grey);
                          },
                        )
                      : IconifyIcon(icon: icon, color: Colors.grey)),
              if (state == index)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: MyTextStyle.bottomNavEnabledTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> getDataFromPrefs() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('user_loggedIn') ?? false;

    return loggedIn;
  }
}
