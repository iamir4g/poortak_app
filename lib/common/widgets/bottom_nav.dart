import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:badges/badges.dart' as badges;
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

// import '../../features/feature_auth/presentation/screens/mobile_signup_screen.dart';

class BottomNav extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onTabSelected;

  const BottomNav({
    super.key,
    required this.controller,
    required this.onTabSelected,
  });

  static const _navAnimationDuration = Duration(milliseconds: 250);

  static const Map<String, String> _navIconAssets = {
    'mage:video-player': 'assets/images/icons/mage--video-player.svg',
    'mage:search': 'assets/images/icons/mage--search.svg',
    'hugeicons:shopping-cart-02':
        'assets/images/icons/hugeicons--shopping-cart-02.svg',
    'hugeicons:book-open-02': 'assets/images/icons/hugeicons--book-open-02.svg',
    'mynaui:user-square': 'assets/images/icons/mage--user-square.svg',
    'mage:user-square': 'assets/images/icons/mage--user-square.svg',
  };

  Widget _buildNavSvgIcon({
    required String icon,
    required double size,
    required Color color,
  }) {
    final assetPath = _navIconAssets[icon];
    if (assetPath == null) {
      return Icon(
        Icons.help_outline_rounded,
        size: size,
        color: color,
      );
    }

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  double _bottomInset(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    if (Platform.isIOS && inset > 0) {
      return 6;
    }
    return inset;
  }

  double _navBarHeight() {
    return Platform.isIOS ? 52.0 : Dimens.bottomNavHeight;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Container(
          decoration: BoxDecoration(
            color: themeState.isDark ? MyColors.darkBackground : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: themeState.isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFF92A2BE).withValues(alpha: 0.12),
                offset: Offset(0, -4.h),
                blurRadius: 10.r,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: _bottomInset(context)),
          child: SizedBox(
            height: _navBarHeight(),
            child: BlocBuilder<BottomNavCubit, int>(
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
                      onTabSelected: onTabSelected,
                    ),
                    _buildNavItem(
                      context: context,
                      state: state,
                      index: 1,
                      icon: "mage:search",
                      label: 'کاوش',
                      onTabSelected: onTabSelected,
                    ),
                    _buildNavItem(
                      context: context,
                      state: state,
                      index: 2,
                      label: 'سبد خرید',
                      icon: "hugeicons:shopping-cart-02",
                      onTabSelected: onTabSelected,
                    ),
                    _buildNavItem(
                      context: context,
                      state: state,
                      index: 3,
                      label: 'لایتنر',
                      icon: "hugeicons:book-open-02",
                      onTabSelected: onTabSelected,
                    ),
                    _buildNavItem(
                      context: context,
                      state: state,
                      index: 4,
                      label: 'پروفایل',
                      onTabSelected: onTabSelected,
                      icon: "mynaui:user-square",
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon({
    required BuildContext context,
    required int index,
    required int state,
    required String icon,
    required bool isSelected,
    required ThemeState themeState,
    required Color iconColor,
  }) {
    // برای کاوش (index 1) و لایتنر (index 3) از تصویر استفاده می‌کنیم
    if (index == 1 || index == 3) {
      String imagePath = index == 1
          ? 'assets/images/bottomNav/kavoshicon.png'
          : 'assets/images/bottomNav/litnericon.png';

      return Image.asset(
        imagePath,
        width: Dimens.iconMedium,
        height: Dimens.iconMedium,
        color: iconColor,
        colorBlendMode: BlendMode.srcIn,
      );
    }

    if (index == 2) {
      // برای سبد خرید با badge
      return BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
        listener: (context, state) {
          if (state is ShoppingCartLoaded || state is LocalCartLoaded) {
            // You can add any side effects here when cart changes
          }
        },
        builder: (context, cartState) {
          if (cartState is ShoppingCartInitial) {
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          if (cartState is ShoppingCartLoading) {
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          // Handle server cart (logged-in users)
          if (cartState is ShoppingCartLoaded) {
            final cart = cartState.cart;
            if (cart.items.isNotEmpty) {
              return badges.Badge(
                badgeStyle:
                    badges.BadgeStyle(badgeColor: MyColors.primaryShade2),
                badgeContent: Text(cart.items.length.toString(),
                    style: MyTextStyle.textBadge10W700),
                child: _buildNavSvgIcon(
                  icon: icon,
                  color: iconColor,
                  size: Dimens.iconMedium,
                ),
              );
            }
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          // Handle local cart (non-logged-in users)
          if (cartState is LocalCartLoaded) {
            if (cartState.items.isNotEmpty) {
              return badges.Badge(
                badgeStyle:
                    badges.BadgeStyle(badgeColor: MyColors.primaryShade2),
                badgeContent: Text(cartState.items.length.toString(),
                    style: MyTextStyle.textBadge10W700),
                child: _buildNavSvgIcon(
                  icon: icon,
                  color: iconColor,
                  size: Dimens.iconMedium,
                ),
              );
            }
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          // Handle local cart item added/removed states
          if (cartState is LocalCartItemAdded) {
            if (cartState.items.isNotEmpty) {
              return badges.Badge(
                badgeStyle:
                    badges.BadgeStyle(badgeColor: MyColors.primaryShade2),
                badgeContent: Text(cartState.items.length.toString()),
                child: _buildNavSvgIcon(
                  icon: icon,
                  color: iconColor,
                  size: Dimens.iconMedium,
                ),
              );
            }
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          if (cartState is LocalCartItemRemoved) {
            if (cartState.items.isNotEmpty) {
              return badges.Badge(
                badgeStyle:
                    badges.BadgeStyle(badgeColor: MyColors.primaryShade2),
                badgeContent: Text(cartState.items.length.toString()),
                child: _buildNavSvgIcon(
                  icon: icon,
                  color: iconColor,
                  size: Dimens.iconMedium,
                ),
              );
            }
            return _buildNavSvgIcon(
              icon: icon,
              color: iconColor,
              size: Dimens.iconMedium,
            );
          }

          return _buildNavSvgIcon(
            icon: icon,
            color: iconColor,
            size: Dimens.iconMedium,
          );
        },
      );
    }

    return _buildNavSvgIcon(
      icon: icon,
      color: iconColor,
      size: Dimens.iconMedium,
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int state,
    required int index,
    required String label,
    required ValueChanged<int> onTabSelected,
    String icon = "",
  }) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isSelected = state == index;
        final unselectedColor = themeState.isDark
            ? MyColors.darkTextSecondary
            : Colors.grey;

        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTabSelected(index),
              splashColor: MyColors.primary.withOpacity(0.08),
              highlightColor: MyColors.primary.withOpacity(0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: _navAnimationDuration,
                    curve: Curves.easeOutCubic,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        end: isSelected ? MyColors.primary : unselectedColor,
                      ),
                      duration: _navAnimationDuration,
                      curve: Curves.easeOutCubic,
                      builder: (context, color, child) {
                        return _buildIcon(
                          context: context,
                          index: index,
                          state: state,
                          icon: icon,
                          isSelected: isSelected,
                          themeState: themeState,
                          iconColor: color ?? unselectedColor,
                        );
                      },
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 8.sp,
                        height: 1.1,
                        color: MyColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> getDataFromPrefs() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('user_loggedIn') ?? false;

    return loggedIn;
  }
}
