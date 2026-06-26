import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';

import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/iknow_summary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/single_book_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/cart_summary_section.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/cart_item_card.dart';
import 'package:poortak/featueres/feature_shopping_cart/utils/cart_item_pricing.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'dart:developer';

class _LocalCartDisplayItem {
  final String title;
  final String description;
  final int price;
  final String? thumbnailId;
  final String type;

  const _LocalCartDisplayItem({
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    this.thumbnailId,
  });
}

class ShoppingCartScreen extends StatefulWidget {
  static const routeName = "/shopping_cart_screen";
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final SayarehRepository _sayarehRepository = locator<SayarehRepository>();
  final Map<String, Future<_LocalCartDisplayItem>> _localCartItemCache = {};
  Future<IKnowSummaryModel>? _summaryFuture;

  String? _getCartItemOverlayIconPath(String type) {
    if (type == 'IKnowBook') {
      return 'assets/images/icons/arcticons--pdf-viewer.svg';
    }
    if (type == 'IKnowCourse') {
      return 'assets/images/icons/carbon--play-outline.svg';
    }
    return null;
  }

  Widget _buildCartItemOverlayIcon(String type) {
    final assetPath = _getCartItemOverlayIconPath(type);
    if (assetPath == null) return const SizedBox.shrink();

    return Positioned(
      right: Dimens.nw(6),
      bottom: Dimens.nh(6),
      child: Container(
        width: Dimens.nr(24),
        height: Dimens.nr(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(Dimens.nr(6)),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: Dimens.nr(16),
            height: Dimens.nr(16),
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load appropriate cart when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ShoppingCartBloc>();
      _loadAppropriateCart(bloc);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ShoppingCartBloc, ShoppingCartState>(
      builder: (context, state) {
        log("🔄 Builder called with state: ${state.runtimeType}");

        if (state is ShoppingCartLoading) {
          return Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF171926),
                        MyColors.darkBackground,
                        Color(0xFF171926),
                      ],
                      stops: [0.1, 0.54, 1.0],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MyColors.shoppingCartBackground,
                        MyColors.shoppingCartBackground,
                      ],
                    ),
            ),
            child: Center(child: DotLoadingWidget(size: Dimens.nr(100))),
          );
        }

        // Handle server cart (for logged-in users)
        if (state is ShoppingCartLoaded) {
          log("📦 Builder: ShoppingCartLoaded state - Cart has ${state.cart.items.length} items");
          log("💰 Cart totals - SubTotal: ${state.cart.subTotal}, GrandTotal: ${state.cart.grandTotal}");
          log("🆔 Cart ID: ${state.cart.id}");

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
        if (state is LocalCartItemAdded || state is LocalCartItemRemoved) {
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
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF171926),
                        MyColors.darkBackground,
                        Color(0xFF171926),
                      ],
                      stops: [0.1, 0.54, 1.0],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MyColors.shoppingCartBackground,
                        MyColors.shoppingCartBackground,
                      ],
                    ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(
                      color: isDark ? MyColors.darkTextPrimary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800),
                    onPressed: () {
                      _loadAppropriateCart(context.read<ShoppingCartBloc>());
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

  Future<IKnowSummaryModel?> _getSummaryData() async {
    _summaryFuture ??= () async {
      final DataState<IKnowSummaryModel> summaryState =
          await _sayarehRepository.fetchIknowSummary();
      if (summaryState is DataSuccess<IKnowSummaryModel> &&
          summaryState.data != null) {
        return summaryState.data!;
      }
      throw Exception(summaryState.error ?? 'خطا در دریافت اطلاعات مجموعه');
    }();

    return _summaryFuture;
  }

  int _calculateBundlePayableAmount(IKnowSummaryModel summary) {
    final subtotal =
        MoneyUtils.parseRialToTomanInt(summary.data.settings.price);
    final isPercent =
        summary.data.settings.discountType.toLowerCase() == 'percent';

    final discountAmount = isPercent
        ? subtotal *
            MoneyUtils.parseRial(summary.data.settings.discountAmount) ~/
            100
        : MoneyUtils.parseRialToTomanInt(summary.data.settings.discountAmount);
    final payable = subtotal - discountAmount;
    return payable < 0 ? 0 : payable;
  }

  Future<_LocalCartDisplayItem> _loadLocalCartItemData(
      String itemType, String itemId) async {
    if (itemType == 'IKnowCourse') {
      final DataState<Lesson> courseState =
          await _sayarehRepository.fetchCourseById(itemId);
      if (courseState is DataSuccess<Lesson> && courseState.data != null) {
        final course = courseState.data!;
        return _LocalCartDisplayItem(
          title: course.name,
          description: course.description,
          price: MoneyUtils.parseRialToTomanInt(course.price),
          thumbnailId: course.videoThumbnailOrThumbnail,
          type: itemType,
        );
      }
    } else if (itemType == 'IKnowBook') {
      final DataState<SingleBookModel> bookState =
          await _sayarehRepository.fetchBookById(itemId);
      if (bookState is DataSuccess<SingleBookModel> && bookState.data != null) {
        final book = bookState.data!.data;
        return _LocalCartDisplayItem(
          title: book.title,
          description: book.description ?? '',
          price: MoneyUtils.parseRialToTomanInt(book.price),
          thumbnailId: book.thumbnail,
          type: itemType,
        );
      }
    } else if (itemType == 'IKnow') {
      final summary = await _getSummaryData();
      if (summary != null) {
        return _LocalCartDisplayItem(
          title: 'مجموعه کامل سیاره آی نو',
          description:
              'شامل ${summary.data.courses.length} درس و ${summary.data.books.length} کتاب',
          price: _calculateBundlePayableAmount(summary),
          type: itemType,
        );
      }
    }

    return _LocalCartDisplayItem(
      title: 'محصول',
      description: 'اطلاعات این آیتم در دسترس نیست',
      price: 0,
      type: itemType,
    );
  }

  Future<_LocalCartDisplayItem> _resolveLocalCartItem(
      Map<String, dynamic> item) {
    final itemType = item['type'] as String;
    final itemId = item['itemId'] as String;
    final cacheKey = '$itemType::$itemId';

    return _localCartItemCache.putIfAbsent(
      cacheKey,
      () => _loadLocalCartItemData(itemType, itemId),
    );
  }

  Future<int> _calculateTotalPrice(
      List<Map<String, dynamic>> localCartItems) async {
    final resolvedItems =
        await Future.wait(localCartItems.map(_resolveLocalCartItem));
    return resolvedItems.fold<int>(0, (sum, item) => sum + item.price);
  }

  // Build header section with points
  Widget _buildPointsHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.nw(32),
        vertical: Dimens.nh(12),
      ),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.nr(15)),
          bottomRight: Radius.circular(Dimens.nr(15)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Points section with star animation
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Star animation
              SizedBox(
                width: Dimens.nw(90),
                height: Dimens.nh(90),
                child: Lottie.asset(
                  'assets/images/cart/star.json',
                  fit: BoxFit.cover,
                ),
              ),
              // SizedBox(width: Dimens.nw(8)),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Dimens.nw(8),
                  runSpacing: Dimens.nh(4),
                  children: [
                    Text(
                      'مجموع امتیاز های شما : ',
                      style: TextStyle(
                        fontSize: Dimens.nsp(16),
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? MyColors.darkTextPrimary
                            : const Color(0xFF29303D),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimens.nw(12), vertical: Dimens.nh(6)),
                      decoration: BoxDecoration(
                        color: isDark
                            ? MyColors.primary.withValues(alpha: 0.18)
                            : const Color(0xFFFFE8CC),
                        borderRadius: BorderRadius.circular(Dimens.nr(10)),
                      ),
                      child: Text(
                        '۲۰۰ سکه',
                        style: TextStyle(
                          fontSize: Dimens.nsp(16),
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : const Color(0xFF29303D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimens.nh(12)),
          // Progress bar section
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.nw(12),
                  vertical: Dimens.nh(8),
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.text6),
                  borderRadius: BorderRadius.circular(Dimens.nr(22)),
                ),
                child: Center(
                  child: Text(
                    'راهنما ؟',
                    style: TextStyle(
                      fontSize: Dimens.nsp(14),
                      fontWeight: FontWeight.bold,
                      color: MyColors.text6,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimens.small),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: Dimens.nh(8)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? MyColors.darkBorder
                          : const Color(0xFFFFA73F),
                    ),
                    borderRadius: BorderRadius.circular(Dimens.nr(22)),
                  ),
                  child: Center(
                    child: Text(
                      'محاسبه امتیاز بر روی سبد خرید',
                      style: TextStyle(
                        fontSize: Dimens.nsp(14),
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? MyColors.darkTextSecondary
                            : const Color(0xFFFFA73F),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build empty cart UI
  Widget buildEmptyCartUI() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? MyColors.darkBackground : MyColors.shoppingCartBackground,
      ),
      child: Column(
        children: [
          // Header section with points
          _buildPointsHeader(),
          // Main content - empty cart
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: Dimens.nh(24)),
                  // White card container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Dimens.medium),
                    padding: EdgeInsets.all(Dimens.nw(24)),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isDark ? MyColors.termsBackgroundDark : Colors.white,
                      borderRadius: BorderRadius.circular(Dimens.nr(22)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'سبد خرید شما خالی است!',
                          style: TextStyle(
                            fontSize: Dimens.nsp(16),
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : const Color(0xFF3D495C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Dimens.nh(20)),
                        SizedBox(
                          width: Dimens.nw(138),
                          height: Dimens.nh(117),
                          child: buildImageFromAssetOrEmbeddedSvg(
                            'assets/images/cart/shopping_cart.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimens.nh(24)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totals = resolveCartTotals(cart);
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? MyColors.darkBackground : MyColors.shoppingCartBackground,
      ),
      child: Column(
        children: [
          // Header section with points
          _buildPointsHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + Dimens.nh(12),
              ),
              itemCount: cart.items.length + 1,
              itemBuilder: (context, index) {
                if (index == cart.items.length) {
                  return CartSummarySection(
                    subTotal: totals.subTotal,
                    discount: totals.discount,
                    payable: totals.payable,
                    onReferralSubmit: (code) {
                      log("🎟️ Referral code submitted: $code");
                    },
                  );
                }
                final item = cart.items[index];
                final pricing = resolveServerCartItemPricing(item);
                final typeLabel =
                    item.type != null ? _getItemTypeLabel(item.type!) : null;
                final subtitle = item.quantity != null && item.quantity! > 1
                    ? 'تعداد: ${item.quantity}'
                    : typeLabel;
                return CartItemCard(
                  title: item.title,
                  subtitle: subtitle,
                  pricing: pricing,
                  onRemove: () {
                    if (item.itemId != null) {
                      context
                          .read<ShoppingCartBloc>()
                          .add(RemoveFromCartEvent(item.itemId!));
                    }
                  },
                  image: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCartItemImage(item),
                      if (item.type != null)
                        _buildCartItemOverlayIcon(item.type!),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(Dimens.medium),
            decoration: BoxDecoration(
              color: isDark
                  ? MyColors.darkBackgroundSecondary
                  : MyColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimens.nr(20)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryButton(
                  width: Dimens.nw(160),
                  height: Dimens.nh(50),
                  lable: l10n?.pay_now ?? "Pay Now",
                  backgroundColor:
                      isDark ? MyColors.primary : MyColors.secondary,
                  onPressed: () async {
                    try {
                      // Call checkout API directly
                      final apiProvider = locator<ShoppingCartApiProvider>();
                      final response = await apiProvider.checkoutCart();

                      log("✅ Checkout response: ${response.data}");

                      // Parse response and get URL
                      final url = response.data['data']['url'] as String;
                      log("🔗 Payment URL: $url");

                      // Launch payment URL immediately without showing SnackBar
                      // to avoid showing "در حال پردازش..." when user returns
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      log("❌ Checkout failed: $e");
                      if (mounted) {
                        // Check if error is UnauthorisedException (user not logged in)
                        if (e is UnauthorisedException) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('برای ادامه پرداخت باید لاگین کنید'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطا در پردازش پرداخت: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                // SizedBox(width: double.infinity),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                              color: isDark
                                  ? MyColors.darkTextPrimary
                                  : MyColors.textMatn1,
                              height: 1.0,
                            ),
                        children: [
                          // TextSpan(
                          //   text: '${l10n?.total_price ?? 'جمع کل: '}',
                          //   style: TextStyle(
                          //     fontSize: Dimens.nsp(14),
                          //     fontWeight: FontWeight.w400,
                          //   ),
                          // ),
                          TextSpan(
                            text: MoneyUtils.formatTomanDisplay(totals.payable),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimens.nsp(18),
                            ),
                          ),
                          TextSpan(
                            text: ' ${l10n?.toman ?? 'تومان'}',
                            style: TextStyle(
                              fontSize: Dimens.nsp(12),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // if (totals.discount > 0)
                    //   Text(
                    //     'قیمت اصلی: ${MoneyUtils.formatTomanDisplay(totals.subTotal)} تومان',
                    //     style: TextStyle(
                    //       color: isDark
                    //           ? MyColors.darkTextSecondary
                    //           : Colors.grey[600],
                    //       fontSize: Dimens.nsp(12),
                    //       decoration: TextDecoration.lineThrough,
                    //     ),
                    //   ),
                  ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? MyColors.darkBackground : MyColors.shoppingCartBackground,
      ),
      child: Column(
        children: [
          // Header section with points
          _buildPointsHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + Dimens.nh(12),
              ),
              itemCount: localCartItems.length + 1,
              itemBuilder: (context, index) {
                if (index == localCartItems.length) {
                  return FutureBuilder<int>(
                    future: _calculateTotalPrice(localCartItems),
                    builder: (context, snapshot) {
                      final totalPrice = snapshot.data ?? 0;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          Dimens.medium,
                          Dimens.small,
                          Dimens.medium,
                          Dimens.nh(12),
                        ),
                        child: CartSummarySection(
                          subTotal: totalPrice,
                          discount: 0,
                          payable: totalPrice,
                          onReferralSubmit: (code) {
                            log("🎟️ Referral code submitted: $code");
                          },
                        ),
                      );
                    },
                  );
                }
                final item = localCartItems[index];
                final itemType = item['type'] as String;
                final itemId = item['itemId'] as String;
                return FutureBuilder<_LocalCartDisplayItem>(
                  future: _resolveLocalCartItem(item),
                  builder: (context, snapshot) {
                    final resolvedItem = snapshot.data;
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting &&
                            resolvedItem == null;

                    return CartItemCard(
                      title: resolvedItem?.title ??
                          (isLoading ? 'در حال بارگذاری...' : 'محصول'),
                      subtitle: 'نوع: ${_getItemTypeLabel(itemType)}',
                      pricing: resolveCartItemPricing(
                        finalPriceToman: resolvedItem?.price ?? 0,
                      ),
                      onRemove: () {
                        context
                            .read<ShoppingCartBloc>()
                            .add(RemoveFromLocalCartEvent(itemType, itemId));
                      },
                      image: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildLocalCartItemImage(
                            resolvedItem,
                            itemType,
                          ),
                          _buildCartItemOverlayIcon(itemType),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(Dimens.medium),
            decoration: BoxDecoration(
              color: isDark
                  ? MyColors.darkBackgroundSecondary
                  : MyColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimens.nr(20)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryButton(
                  width: Dimens.nw(160),
                  height: Dimens.nh(50),
                  lable: l10n?.pay_now ?? "Pay Now",
                  backgroundColor:
                      isDark ? MyColors.primary : MyColors.secondary,
                  onPressed: () async {
                    try {
                      // Call checkout API directly
                      final apiProvider = locator<ShoppingCartApiProvider>();
                      final response = await apiProvider.checkoutCart();

                      log("✅ Checkout response: ${response.data}");

                      // Parse response and get URL
                      final url = response.data['data']['url'] as String;
                      log("🔗 Payment URL: $url");

                      // Launch payment URL immediately without showing SnackBar
                      // to avoid showing "در حال پردازش..." when user returns
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      log("❌ Checkout failed: $e");
                      if (mounted) {
                        // Check if error is UnauthorisedException (user not logged in)
                        if (e is UnauthorisedException) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('برای ادامه پرداخت باید لاگین کنید'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطا در پردازش پرداخت: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                FutureBuilder<int>(
                  future: _calculateTotalPrice(localCartItems),
                  builder: (context, snapshot) {
                    final totalPrice = snapshot.data ?? 0;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  color: isDark
                                      ? MyColors.darkTextPrimary
                                      : MyColors.textMatn1,
                                  height: 1.0,
                                ),
                            children: [
                              TextSpan(
                                text: MoneyUtils.formatTomanDisplay(totalPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.nsp(16),
                                ),
                              ),
                              TextSpan(
                                text: ' ${l10n?.toman ?? 'تومان'}',
                                style: TextStyle(
                                  fontSize: Dimens.nsp(12),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  String _getItemTypeLabel(String itemType) {
    if (itemType == 'IKnowCourse') {
      return 'دوره تکی';
    }
    if (itemType == 'IKnowBook') {
      return 'کتاب';
    }
    if (itemType == 'IKnow') {
      return 'مجموعه کامل';
    }
    return 'محصول';
  }

  Widget _buildLocalCartItemImage(
      _LocalCartDisplayItem? item, String itemType) {
    if (item?.thumbnailId != null && item!.thumbnailId!.isNotEmpty) {
      return FutureBuilder<String>(
        future: GetImageUrlService().getImageUrl(item.thumbnailId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _buildLocalCartFallbackImage(itemType);
          }
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return _buildLocalCartFallbackImage(itemType);
            },
          );
        },
      );
    }

    if (itemType == 'IKnow') {
      return Image.asset(
        'assets/images/cart/bundle_lesson.png',
        fit: BoxFit.cover,
      );
    }

    return _buildLocalCartFallbackImage(itemType);
  }

  Widget _buildLocalCartFallbackImage(String itemType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final IconData icon;
    if (itemType == 'IKnowCourse') {
      icon = Icons.school;
    } else if (itemType == 'IKnowBook') {
      icon = Icons.menu_book;
    } else {
      icon = Icons.library_books;
    }

    return Container(
      color: isDark ? MyColors.darkCardBackground : Colors.grey[300],
      child: Icon(
        icon,
        size: Dimens.nr(40),
        color: isDark ? MyColors.darkTextSecondary : Colors.grey[600],
      ),
    );
  }

  String? _resolveCartItemThumbnailId(ShoppingCartItem item) {
    final source = item.source;
    if (source == null) return null;

    if (item.type == 'IKnowCourse') {
      final videoThumbnail = source['videoThumbnail']?.toString();
      if (videoThumbnail != null && videoThumbnail.isNotEmpty) {
        return videoThumbnail;
      }
    }

    final thumbnail = source['thumbnail']?.toString();
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return thumbnail;
    }

    return null;
  }

  // Helper method to build cart item image
  Widget _buildCartItemImage(ShoppingCartItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbnailId = _resolveCartItemThumbnailId(item);

    // If we have a thumbnail ID, use GetImageUrlService
    if (thumbnailId != null && thumbnailId.isNotEmpty) {
      return FutureBuilder<String>(
        future: GetImageUrlService().getImageUrl(thumbnailId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Container(
              color: isDark ? MyColors.darkCardBackground : Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                size: Dimens.nr(40),
                color: isDark ? MyColors.darkTextSecondary : Colors.grey,
              ),
            );
          }
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: isDark ? MyColors.darkCardBackground : Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  size: Dimens.nr(40),
                  color: isDark ? MyColors.darkTextSecondary : Colors.grey,
                ),
              );
            },
          );
        },
      );
    }

    if (item.type == 'IKnow') {
      return Image.asset(
        'assets/images/cart/bundle_lesson.png',
        fit: BoxFit.cover,
      );
    }

    // If we have a direct image URL
    if (item.image.isNotEmpty) {
      return Image.network(
        item.image,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: isDark ? MyColors.darkCardBackground : Colors.grey[300],
            child: Icon(
              Icons.image_not_supported,
              size: Dimens.nr(40),
              color: isDark ? MyColors.darkTextSecondary : Colors.grey,
            ),
          );
        },
      );
    }

    // Default placeholder
    return Container(
      color: isDark ? MyColors.darkCardBackground : Colors.grey[300],
      child: Icon(
        Icons.shopping_cart,
        size: Dimens.nr(40),
        color: isDark ? MyColors.darkTextSecondary : Colors.grey,
      ),
    );
  }
}
