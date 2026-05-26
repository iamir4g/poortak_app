import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/iknow_summary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';

class DialogCart extends StatefulWidget {
  final Lesson item;
  final IKnowSummaryModel? summaryData;
  const DialogCart({super.key, required this.item, this.summaryData});

  @override
  State<DialogCart> createState() => _DialogCartState();
}

class _DialogCartState extends State<DialogCart> {
  final PrefsOperator _prefsOperator = locator<PrefsOperator>();
  static const String _bundleName = "مجموعه کامل سیاره آی نو";

  Widget _buildCartFooter() {
    return Container(
      width: Dimens.nw(360.0),
      height: Dimens.nh(112.0),
      decoration: ShapeDecoration(
        color: MyColors.cartFooterBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Dimens.nr(25.0)),
            bottomRight: Radius.circular(Dimens.nr(25.0)),
          ),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/cart/subtract.png"),
          Expanded(
            child: Text(
              "جهت کسب اطلاعات بیشتر به وبسایت پورتک به نشانی www.poortak.ir مراجه کنید.",
              style: MyTextStyle.textMatn11,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateBundleSubtotal(IKnowSummaryModel summary) {
    final settingsPrice =
        MoneyUtils.parseRialToTomanInt(summary.data.settings.price);
    if (settingsPrice > 0) {
      return settingsPrice;
    }

    final coursesTotal = summary.data.courses.fold<int>(
      0,
      (total, course) => total + MoneyUtils.parseRialToTomanInt(course.price),
    );
    final booksTotal = summary.data.books.fold<int>(
      0,
      (total, book) => total + MoneyUtils.parseRialToTomanInt(book.price),
    );
    return coursesTotal + booksTotal;
  }

  int _calculateDiscountAmount(IKnowSummaryModel summary) {
    final subtotal = _calculateBundleSubtotal(summary);
    final settings = summary.data.settings;
    if (settings.discountType.toLowerCase() == "percent") {
      final discountPercent = MoneyUtils.parseRial(settings.discountAmount);
      if (discountPercent <= 0) return 0;
      if (discountPercent >= 100) return subtotal;
      return subtotal * discountPercent ~/ 100;
    }

    final discountValue =
        MoneyUtils.parseRialToTomanInt(settings.discountAmount);
    if (discountValue <= 0) return 0;
    if (discountValue >= subtotal) return subtotal;
    return discountValue;
  }

  int _calculatePayableAmount(IKnowSummaryModel summary) {
    final payable =
        _calculateBundleSubtotal(summary) - _calculateDiscountAmount(summary);
    return payable < 0 ? 0 : payable;
  }

  List<IKnowSummaryCourse> _sortedCourses(IKnowSummaryModel summary) {
    final courses = List<IKnowSummaryCourse>.from(summary.data.courses);
    courses.sort((a, b) => a.order.compareTo(b.order));
    return courses;
  }

  List<IKnowSummaryBook> _sortedBooks(IKnowSummaryModel summary) {
    final books = List<IKnowSummaryBook>.from(summary.data.books);
    books.sort((a, b) => a.order.compareTo(b.order));
    return books;
  }

  /// Extracts error message from DioException or other exceptions
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      // Check if there's a response with data
      if (error.response != null && error.response!.data != null) {
        final responseData = error.response!.data;

        // Try to extract message from response data
        if (responseData is Map<String, dynamic>) {
          // Check for 'message' field
          if (responseData.containsKey('message')) {
            final message = responseData['message'];
            if (message is String && message.isNotEmpty) {
              return message;
            }
          }
          // Check for 'error' field
          if (responseData.containsKey('error')) {
            final errorMsg = responseData['error'];
            if (errorMsg is String && errorMsg.isNotEmpty) {
              return errorMsg;
            }
          }
        } else if (responseData is String) {
          // If response data is a string, use it directly
          return responseData;
        }
      }
      // Fallback to DioException message
      return error.message ?? 'خطا در افزودن به سبد خرید';
    }
    // For other exceptions, return string representation
    return error.toString();
  }

  void _addItemToCart(String type, String itemId, String itemName) async {
    final isLoggedIn = _prefsOperator.isLoggedIn();

    debugPrint("🛒 Adding item to cart: $itemName");
    debugPrint("   Type: $type");
    debugPrint("   ID: $itemId");
    debugPrint("   User logged in: $isLoggedIn");

    // Get root navigator context before closing dialog
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    if (isLoggedIn) {
      // User is logged in - add to server cart via API
      debugPrint("📤 Adding item to server cart via API");
      try {
        final apiProvider = locator<ShoppingCartApiProvider>();
        final cartType = CartType.values.firstWhere((e) => e.name == type);
        await apiProvider.addToCart(cartType, itemId);
        debugPrint("✅ Item added to server cart successfully");

        if (!mounted) return;

        // Refresh cart after adding
        context.read<ShoppingCartBloc>().add(GetCartEvent());

        // Close current dialog
        Navigator.of(context).pop();

        // Show success modal after dialog is closed
        Future.microtask(() {
          if (rootContext.mounted) {
            _showSuccessModal(rootContext, itemName);
          }
        });
      } catch (e) {
        debugPrint("❌ Failed to add item to server cart: $e");
        final errorMessage = _extractErrorMessage(e);
        debugPrint("📝 Extracted error message: $errorMessage");

        if (!mounted) return;

        Navigator.of(context).pop(); // Close dialog even on error
        Future.microtask(() {
          if (rootContext.mounted) {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: MyColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } else {
      // User is not logged in - add to local cart
      debugPrint("📱 Adding item to local cart");
      context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));

      if (!mounted) return;

      // Close current dialog
      Navigator.of(context).pop();

      // Show success modal after dialog is closed
      Future.microtask(() {
        if (rootContext.mounted) {
          _showSuccessModal(rootContext, itemName);
        }
      });
    }
  }

  void _showSuccessModal(BuildContext context, String itemName) {
    ReusableModal.showSuccess(
      context: context,
      title: 'اضافه به سبد خرید',
      message: '($itemName) به سبد خرید شما اضافه شد',
      buttonText: 'مشاهده سبد خرید',
      secondButtonText: 'بستن',
      showSecondButton: true,
      cartSuccessStyle: true,
      onButtonPressed: () {
        Navigator.of(context).pop(); // Close success modal
        // Navigate to MainWrapper and switch to shopping cart (index 2)
        Navigator.of(context).pushNamedAndRemoveUntil(
          MainWrapper.routeName,
          (route) => false,
          arguments: {'initialIndex': 2},
        );
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop(); // Close success modal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summaryData = widget.summaryData;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
        backgroundColor: MyColors.background,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Dimens.nh(700.0)),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SizedBox(
                  height: Dimens.nh(18.0),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
                    child: TabBar(
                        isScrollable: false,
                        dividerHeight: 0.0,
                        labelStyle: MyTextStyle.tabLabel16
                            .copyWith(fontSize: Dimens.nsp(14.0)),
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: Dimens.nw(4.0)),
                        indicatorColor: Colors.transparent,
                        labelColor: MyColors.textLight,
                        unselectedLabelColor: MyColors.textSecondary,
                        indicator: BoxDecoration(
                          color: MyColors.darkBackground,
                          borderRadius: BorderRadius.circular(Dimens.nr(20.0)),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "خرید تکی",
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "خرید مجموعه %",
                              ),
                            ),
                          ),
                        ])),
                SizedBox(
                  height: Dimens.nh(16.0),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                Dimens.medium,
                                Dimens.medium,
                                Dimens.medium,
                                0,
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: Dimens.nw(286.0),
                                        height: Dimens.nh(177.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(Dimens.nr(27.0))),
                                          color: MyColors.background,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(Dimens.nr(27.0)),
                                          ),
                                          child: FutureBuilder<String>(
                                            future: GetImageUrlService()
                                                .getImageUrl(
                                                    widget.item.thumbnail),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (snapshot.hasError ||
                                                  !snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Image.asset(
                                                  "assets/images/cart/single_lesson.png",
                                                  fit: BoxFit.cover,
                                                );
                                              }
                                              return Image.network(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    "assets/images/cart/single_lesson.png",
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: Dimens.nh(5.0),
                                        left: Dimens.small,
                                        child: Container(
                                          width: Dimens.nw(104.0),
                                          height: Dimens.nh(30.0),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      Dimens.nr(20.0))),
                                              color: MyColors.background),
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                Dimens.tiny, 0, Dimens.tiny, 0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "assets/images/star_icon.png",
                                                    width: Dimens.nw(18.0),
                                                    height: Dimens.nh(18.0),
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SizedBox(
                                                      width: Dimens.nw(2.0)),
                                                  Text(
                                                    convertEnToFa("+5"),
                                                    style: MyTextStyle
                                                        .textMatn13PrimaryShade1,
                                                  ),
                                                  SizedBox(
                                                      width: Dimens.nw(2.0)),
                                                  Text(
                                                    l10n.coin_with_buy,
                                                    style:
                                                        MyTextStyle.textMatn9,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: Dimens.nh(26.0),
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.item.name,
                                          style: MyTextStyle.textMatn12W500,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          width: Dimens.nw(14.0),
                                        ),
                                        if (widget.item.description.isNotEmpty)
                                          ...[],
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimens.nh(18.0),
                                  ),
                                  Container(
                                      height: Dimens.nh(54.0),
                                      decoration: BoxDecoration(
                                        color: MyColors.cardBackground1,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(Dimens.nr(10.0))),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Dimens.medium),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              l10n.price,
                                              style: TextStyle(
                                                fontFamily: "IRANSans",
                                                fontSize: Dimens.nsp(15.0),
                                                fontWeight: FontWeight.w300,
                                                fontStyle: FontStyle.normal,
                                                height: 1.0,
                                                letterSpacing: 0.0,
                                                color: MyColors.text1,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${MoneyUtils.formatTomanFromRial(widget.item.price)} ",
                                                  style: TextStyle(
                                                    fontFamily: "IRANSans",
                                                    fontSize: Dimens.nsp(16.0),
                                                    fontWeight: FontWeight.w300,
                                                    fontStyle: FontStyle.normal,
                                                    height: 1.0,
                                                    letterSpacing: 0.0,
                                                    color: MyColors.textMatn1,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  l10n.toman,
                                                  style: MyTextStyle.textMatn13,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: Dimens.nh(20.0),
                                  ),
                                  SizedBox(
                                    width: Dimens.nw(286.0),
                                    height: Dimens.nh(65.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _addItemToCart(
                                          CartType.IKnowCourse.name,
                                          widget.item.id,
                                          widget.item.name,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? MyColors.primary
                                            : MyColors.secondary,
                                        foregroundColor: MyColors.textLight,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            Dimens.radiusLarge,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.add_to_cart,
                                        style: MyTextStyle.textMatnBtn,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimens.nh(20.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _buildCartFooter(),
                            ),
                          ),
                        ],
                      ),
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: summaryData == null
                                ? Padding(
                                    padding: EdgeInsets.all(Dimens.large),
                                    child: Column(
                                      children: [
                                        SizedBox(height: Dimens.nh(40.0)),
                                        const CircularProgressIndicator(),
                                        SizedBox(height: Dimens.nh(16.0)),
                                        Text(
                                          "اطلاعات خرید مجموعه در حال بارگذاری است",
                                          style: MyTextStyle.textMatn12W500,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: Dimens.nh(24.0)),
                                      ],
                                    ),
                                  )
                                : Builder(
                                    builder: (context) {
                                      final sortedCourses =
                                          _sortedCourses(summaryData);
                                      final sortedBooks =
                                          _sortedBooks(summaryData);
                                      final subtotal =
                                          _calculateBundleSubtotal(summaryData);
                                      final discountAmount =
                                          _calculateDiscountAmount(summaryData);
                                      final payableAmount =
                                          _calculatePayableAmount(summaryData);
                                      final settings =
                                          summaryData.data.settings;
                                      final isPercentDiscount =
                                          settings.discountType.toLowerCase() ==
                                              "percent";

                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: Dimens.nh(16.0),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                width: Dimens.nw(286.0),
                                                height: Dimens.nh(177.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(
                                                        Dimens.nr(27.0)),
                                                  ),
                                                  color: MyColors.background,
                                                ),
                                                child: Image.asset(
                                                  "assets/images/cart/bundle_lesson.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: Dimens.nh(35.0),
                                                  right: Dimens.small,
                                                  child: SizedBox(
                                                    width: Dimens.nw(30.0),
                                                    height: Dimens.nh(30.0),
                                                    child: SvgPicture.asset(
                                                      'assets/images/icons/arcticons--pdf-viewer.svg',
                                                      width: Dimens.nw(30.0),
                                                      height: Dimens.nh(30.0),
                                                      colorFilter:
                                                          const ColorFilter
                                                              .mode(
                                                        MyColors.textLight,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  )),
                                              Positioned(
                                                bottom: Dimens.nh(5.0),
                                                right: Dimens.small,
                                                child: SizedBox(
                                                  width: Dimens.nw(30.0),
                                                  height: Dimens.nh(30.0),
                                                  child: SvgPicture.asset(
                                                    'assets/images/icons/carbon--play-outline.svg',
                                                    width: Dimens.nw(30.0),
                                                    height: Dimens.nh(30.0),
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      MyColors.textLight,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: Dimens.nh(5.0),
                                                left: Dimens.small,
                                                child: Container(
                                                  width: Dimens.nw(104.0),
                                                  height: Dimens.nh(30.0),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              Dimens.nr(20.0))),
                                                      color:
                                                          MyColors.background),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            Dimens.tiny,
                                                            0,
                                                            Dimens.nw(2.0),
                                                            0),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            "assets/images/star_icon.png",
                                                            width:
                                                                Dimens.nw(18.0),
                                                            height:
                                                                Dimens.nh(18.0),
                                                            fit: BoxFit.contain,
                                                          ),
                                                          SizedBox(
                                                              width: Dimens.nw(
                                                                  2.0)),
                                                          Text(
                                                            convertEnToFa(
                                                                "+50"),
                                                            style: MyTextStyle
                                                                .textMatn13PrimaryShade1,
                                                          ),
                                                          SizedBox(
                                                              width: Dimens.nw(
                                                                  2.0)),
                                                          Text(
                                                            l10n.coin_with_buy,
                                                            style: MyTextStyle
                                                                .textMatn9,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: Dimens.nh(26.0),
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: MyColors.background1),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: Dimens.nh(16.0),
                                                ),
                                                Center(
                                                  child: Text(
                                                    _bundleName,
                                                    style: MyTextStyle
                                                        .textMatn14Bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(18.0),
                                                ),
                                                SizedBox(
                                                  width: Dimens.nw(248.0),
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        sortedCourses.length,
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return SizedBox(
                                                          height:
                                                              Dimens.nh(6.0));
                                                    },
                                                    itemBuilder:
                                                        (context, index) {
                                                      final course =
                                                          sortedCourses[index];
                                                      return ItemMultiCard(
                                                        title: course.name,
                                                        price: course.price,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(20.0),
                                                ),
                                                Center(
                                                  child: Text(
                                                    "کتاب های الکترونیکی",
                                                    style: MyTextStyle
                                                        .textMatn14Bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(16.0),
                                                ),
                                                SizedBox(
                                                  width: Dimens.nw(248.0),
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        sortedBooks.length,
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return SizedBox(
                                                          height:
                                                              Dimens.nh(6.0));
                                                    },
                                                    itemBuilder:
                                                        (context, index) {
                                                      final book =
                                                          sortedBooks[index];
                                                      return ItemMultiCard(
                                                        title: book.title,
                                                        price: book.price,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(14.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimens.nh(16.0),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.medium),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      "جمع دروس و کتاب ها",
                                                      style: MyTextStyle
                                                          .textMatn12W300,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${subtotal.toString().addComma} ",
                                                          style: MyTextStyle
                                                              .textMatn14Bold,
                                                        ),
                                                        Text(
                                                          l10n.toman,
                                                          style: MyTextStyle
                                                              .textMatn10W300,
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(16.0),
                                                ),
                                                Container(
                                                  width: Dimens.nw(286.0),
                                                  height: Dimens.nh(42.0),
                                                  decoration: ShapeDecoration(
                                                    color: MyColors
                                                        .discountBackground,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimens.nr(10.0)),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "تخفیف",
                                                        style: MyTextStyle
                                                            .textMatn12W300,
                                                      ),
                                                      Row(
                                                        children: [
                                                          if (isPercentDiscount)
                                                            Container(
                                                              width: Dimens.nw(
                                                                  40.0),
                                                              height: Dimens.nh(
                                                                  17.84),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: MyColors
                                                                    .darkErrorLight,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              Dimens.nr(11.50)),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "${settings.discountAmount}%",
                                                                style: MyTextStyle
                                                                    .textMatn10W300,
                                                              ),
                                                            ),
                                                          if (isPercentDiscount)
                                                            SizedBox(
                                                                width:
                                                                    Dimens.nw(
                                                                        4.0)),
                                                          Text(
                                                            discountAmount
                                                                .toString()
                                                                .addComma,
                                                            style: MyTextStyle
                                                                .textMatn12W300,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                Dimens.nw(4.0),
                                                          ),
                                                          Text(
                                                            l10n.toman,
                                                            style: MyTextStyle
                                                                .textMatn10W300,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(16.0),
                                                ),
                                                Container(
                                                  width: Dimens.nw(286.0),
                                                  height: Dimens.nh(54.0),
                                                  decoration: ShapeDecoration(
                                                    color: MyColors.background2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: Dimens.nw(2.0),
                                                        color: MyColors.primary,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimens.nr(10.0)),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "مبلغ قابل پرداخت",
                                                        style: MyTextStyle
                                                            .textMatn12W300,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            payableAmount
                                                                .toString()
                                                                .addComma,
                                                            style: MyTextStyle
                                                                .textMatn14Bold,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                Dimens.nw(4.0),
                                                          ),
                                                          Text(
                                                            l10n.toman,
                                                            style: MyTextStyle
                                                                .textMatn10W300,
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Dimens.nh(16.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: Dimens.nw(286.0),
                                            height: Dimens.nh(65.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (settings.id.isEmpty) {
                                                  return;
                                                }
                                                _addItemToCart(
                                                  CartType.IKnow.name,
                                                  settings.id,
                                                  _bundleName,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark
                                                    ? MyColors.primary
                                                    : MyColors.secondary,
                                                foregroundColor:
                                                    MyColors.textLight,
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Dimens.radiusLarge,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                l10n.add_to_cart,
                                                style: MyTextStyle.textMatnBtn,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimens.nh(20.0),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _buildCartFooter(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
