import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';

import 'package:poortak/common/resources/data_state.dart';
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
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';
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
            child: Center(child: DotLoadingWidget(size: 100.r)),
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

  int _parsePrice(String? price) {
    return int.tryParse(price ?? '') ?? 0;
  }

  int _calculateBundlePayableAmount(IKnowSummaryModel summary) {
    final subtotal = _parsePrice(summary.data.settings.price);
    final discountValue = _parsePrice(summary.data.settings.discountAmount);
    final isPercent =
        summary.data.settings.discountType.toLowerCase() == 'percent';

    final discountAmount =
        isPercent ? subtotal * discountValue ~/ 100 : discountValue;
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
          price: _parsePrice(course.price),
          thumbnailId: course.thumbnail,
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
          price: _parsePrice(book.price),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
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
                width: 50.w,
                height: 50.h,
                child: Lottie.asset(
                  'assets/images/cart/star.json',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Text(
                      'مجموع امتیاز های شما : ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF29303D),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8CC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '۲۰۰ سکه',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF29303D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Progress bar section
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFA73F)),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    'راهنما ؟',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA73F),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC2C9D6)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      'محاسبه امتیاز بر روی سبد خرید',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC2C9D6),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F9FE), // Background color from Figma
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
                  SizedBox(height: 24.h),
                  // White card container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(24.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shopping cart image
                        SizedBox(
                          width: 138.w,
                          height: 117.h,
                          child: Image.asset(
                            'assets/images/cart/shopping_cart.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // Empty cart text
                        Text(
                          'سبد خرید شما خالی است!',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3D495C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
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
          // Header section with points
          _buildPointsHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: MyColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10.h,
                        left: -10.w,
                        child: IconButton(
                          iconSize: 18.r,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (item.itemId != null) {
                              context
                                  .read<ShoppingCartBloc>()
                                  .add(RemoveFromCartEvent(item.itemId!));
                            }
                          },
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildCartItemImage(item),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                if (item.quantity != null && item.quantity! > 1)
                                  Text(
                                    'تعداد: ${item.quantity}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                if (item.source != null &&
                                    item.source!['discountAmount'] != null)
                                  Text(
                                    'تخفیف: ${item.source!['discountAmount']}%',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                SizedBox(
                                    height: 24.h), // Space for price at bottom
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
                            Text(
                              item.price.toString().addComma,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "تومان",
                              style: TextStyle(fontSize: 12.sp),
                            ),
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
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n?.total_price} ${cart.grandTotal?.addComma ?? cart.items.fold(0, (sum, item) => sum + item.price).addComma}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (cart.subTotal != null &&
                          cart.grandTotal != null &&
                          cart.subTotal != cart.grandTotal)
                        Text(
                          'قیمت اصلی: ${cart.subTotal!.addComma} تومان',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),
                PrimaryButton(
                  width: 160.w,
                  height: 50.h,
                  lable: l10n?.pay_now ?? "Pay Now",
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
          // Header section with points
          _buildPointsHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: localCartItems.length,
              itemBuilder: (context, index) {
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

                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: MyColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -10.h,
                            left: -10.w,
                            child: IconButton(
                              iconSize: 18.r,
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                context.read<ShoppingCartBloc>().add(
                                    RemoveFromLocalCartEvent(itemType, itemId));
                              },
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildLocalCartItemImage(
                                    resolvedItem,
                                    itemType,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resolvedItem?.title ??
                                          (isLoading
                                              ? 'در حال بارگذاری...'
                                              : 'محصول'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      resolvedItem?.description ??
                                          (isLoading
                                              ? 'در حال دریافت اطلاعات'
                                              : 'اطلاعات این آیتم در دسترس نیست'),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'نوع: ${_getItemTypeLabel(itemType)}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
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
                                Text(
                                  (resolvedItem?.price ?? 0)
                                      .toString()
                                      .addComma,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "تومان",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _calculateTotalPrice(localCartItems),
                    builder: (context, snapshot) {
                      final totalPrice = snapshot.data ?? 0;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.total_price} ${totalPrice.addComma}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                PrimaryButton(
                  width: 160.w,
                  height: 50.h,
                  lable: l10n?.pay_now ?? "Pay Now",
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
    final IconData icon;
    if (itemType == 'IKnowCourse') {
      icon = Icons.school;
    } else if (itemType == 'IKnowBook') {
      icon = Icons.menu_book;
    } else {
      icon = Icons.library_books;
    }

    return Container(
      color: Colors.grey[300],
      child: Icon(
        icon,
        size: 40.r,
        color: Colors.grey[600],
      ),
    );
  }

  // Helper method to build cart item image
  Widget _buildCartItemImage(ShoppingCartItem item) {
    // Check if source has thumbnail
    String? thumbnailId;
    if (item.source != null && item.source!['thumbnail'] != null) {
      thumbnailId = item.source!['thumbnail'] as String?;
    }

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
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
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
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          );
        },
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
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    // Default placeholder
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.shopping_cart,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
