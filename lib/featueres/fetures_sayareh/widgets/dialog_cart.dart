import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  int _parsePrice(String? value) {
    return int.tryParse(value ?? "") ?? 0;
  }

  int _calculateBundleSubtotal(IKnowSummaryModel summary) {
    final settingsPrice = _parsePrice(summary.data.settings.price);
    if (settingsPrice > 0) {
      return settingsPrice;
    }

    final coursesTotal = summary.data.courses.fold<int>(
      0,
      (total, course) => total + _parsePrice(course.price),
    );
    final booksTotal = summary.data.books.fold<int>(
      0,
      (total, book) => total + _parsePrice(book.price),
    );
    return coursesTotal + booksTotal;
  }

  int _calculateDiscountAmount(IKnowSummaryModel summary) {
    final subtotal = _calculateBundleSubtotal(summary);
    final settings = summary.data.settings;
    final discountValue = _parsePrice(settings.discountAmount);

    if (settings.discountType.toLowerCase() == "percent") {
      return subtotal * discountValue ~/ 100;
    }

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
    return Dialog(
        backgroundColor: MyColors.background,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 700),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SizedBox(
                  height: 18.h,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TabBar(
                        isScrollable: false,
                        dividerHeight: 0.0,
                        labelStyle:
                            MyTextStyle.tabLabel16.copyWith(fontSize: 14.sp),
                        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                        indicatorColor: Colors.transparent,
                        labelColor: MyColors.textLight,
                        unselectedLabelColor: MyColors.textSecondary,
                        indicator: BoxDecoration(
                          color: MyColors.darkBackground,
                          borderRadius: BorderRadius.circular(20.r),
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
                  height: 16.h,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 286.w,
                                    height: 177.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(27.r)),
                                      color: MyColors.background,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(27.r),
                                      ),
                                      child: FutureBuilder<String>(
                                        future: GetImageUrlService()
                                            .getImageUrl(widget.item.thumbnail),
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
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                                    bottom: 5.h,
                                    left: 8.w,
                                    child: Container(
                                      width: 104.w,
                                      height: 30.h,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.r)),
                                          color: MyColors.background),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                                "assets/images/star_icon.png"),
                                            Text(
                                              convertEnToFa("+5"),
                                              style: MyTextStyle
                                                  .textMatn13PrimaryShade1,
                                            ),
                                            Text(
                                              l10n.coin_with_buy,
                                              style: MyTextStyle.textMatn9,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 26.h,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        image: AssetImage(
                                            "assets/images/lock_image.png")),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Text(
                                      widget.item.name,
                                      style: MyTextStyle.textMatn12W500,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    if (widget.item.description.isNotEmpty) ...[
                                      // SizedBox(
                                      //   height: 12.h,
                                      // ),
                                      Text(
                                        widget.item.description,
                                        style:
                                            MyTextStyle.textMatn14Bold.copyWith(
                                                // color: MyColors.textSecondary,
                                                ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18.h,
                              ),
                              Container(
                                  height: 54.h,
                                  decoration: BoxDecoration(
                                    color: MyColors.cardBackground1,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.price,
                                          style: MyTextStyle.textMatn15,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                style: MyTextStyle.textMatn16,
                                                "${widget.item.price.toString().addComma} "),
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
                                height: 20.h,
                              ),
                              PrimaryButton(
                                  width: 286.w,
                                  height: 65.h,
                                  lable: l10n.add_to_cart,
                                  onPressed: () {
                                    // Add single course to cart using item ID and IKnowCourse type
                                    _addItemToCart(CartType.IKnowCourse.name,
                                        widget.item.id, widget.item.name);
                                  })
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: summaryData == null
                            ? Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Column(
                                  children: [
                                    SizedBox(height: 40.h),
                                    const CircularProgressIndicator(),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "اطلاعات خرید مجموعه در حال بارگذاری است",
                                      style: MyTextStyle.textMatn12W500,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24.h),
                                  ],
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  final sortedCourses =
                                      _sortedCourses(summaryData);
                                  final sortedBooks = _sortedBooks(summaryData);
                                  final subtotal =
                                      _calculateBundleSubtotal(summaryData);
                                  final discountAmount =
                                      _calculateDiscountAmount(summaryData);
                                  final payableAmount =
                                      _calculatePayableAmount(summaryData);
                                  final settings = summaryData.data.settings;
                                  final isPercentDiscount =
                                      settings.discountType.toLowerCase() ==
                                          "percent";

                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 16.h,
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            width: 286.w,
                                            height: 177.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(27.r)),
                                              color: MyColors.background,
                                            ),
                                            child: Image.asset(
                                              "assets/images/cart/bundle_lesson.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 35.h,
                                              right: 8.w,
                                              child: SizedBox(
                                                width: 30.w,
                                                height: 30.h,
                                                child: IconifyIcon(
                                                    color: MyColors.textLight,
                                                    icon:
                                                        "arcticons:pdf-viewer"),
                                              )),
                                          Positioned(
                                            bottom: 5.h,
                                            right: 8.w,
                                            child: SizedBox(
                                              width: 30.w,
                                              height: 30.h,
                                              child: IconifyIcon(
                                                  color: MyColors.textLight,
                                                  icon: "carbon:play-outline"),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5.h,
                                            left: 8.w,
                                            child: Container(
                                              width: 104.w,
                                              height: 30.h,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.r)),
                                                  color: MyColors.background),
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    4.w, 0, 2.w, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/star_icon.png"),
                                                    Text(
                                                      convertEnToFa("+50"),
                                                      style: MyTextStyle
                                                          .textMatn13PrimaryShade1,
                                                    ),
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
                                        ],
                                      ),
                                      SizedBox(
                                        height: 26.h,
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: MyColors.background1),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 16.h,
                                            ),
                                            Center(
                                              child: Text(
                                                _bundleName,
                                                style:
                                                    MyTextStyle.textMatn14Bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 18.h,
                                            ),
                                            SizedBox(
                                              width: 248.w,
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: sortedCourses.length,
                                                separatorBuilder:
                                                    (context, index) {
                                                  return SizedBox(height: 6.h);
                                                },
                                                itemBuilder: (context, index) {
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
                                              height: 20.h,
                                            ),
                                            Center(
                                              child: Text(
                                                "کتاب های الکترونیکی",
                                                style:
                                                    MyTextStyle.textMatn14Bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16.h,
                                            ),
                                            SizedBox(
                                              width: 248.w,
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: sortedBooks.length,
                                                separatorBuilder:
                                                    (context, index) {
                                                  return SizedBox(height: 6.h);
                                                },
                                                itemBuilder: (context, index) {
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
                                              height: 14.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
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
                                              height: 16.h,
                                            ),
                                            Container(
                                              width: 286.w,
                                              height: 42.h,
                                              decoration: ShapeDecoration(
                                                color:
                                                    MyColors.discountBackground,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
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
                                                          width: 40.w,
                                                          height: 17.84.h,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: MyColors
                                                                .darkErrorLight,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          11.50
                                                                              .r),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "${settings.discountAmount}%",
                                                            style: MyTextStyle
                                                                .textMatn10W300,
                                                          ),
                                                        ),
                                                      if (isPercentDiscount)
                                                        SizedBox(width: 4.w),
                                                      Text(
                                                        discountAmount
                                                            .toString()
                                                            .addComma,
                                                        style: MyTextStyle
                                                            .textMatn12W300,
                                                      ),
                                                      SizedBox(
                                                        width: 4.w,
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
                                              height: 16.h,
                                            ),
                                            Container(
                                              width: 286.w,
                                              height: 54.h,
                                              decoration: ShapeDecoration(
                                                color: MyColors.background2,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 2.w,
                                                    color: MyColors.primary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
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
                                                        width: 4.w,
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
                                              height: 16.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                      PrimaryButton(
                                          width: 286.w,
                                          height: 65.h,
                                          lable: l10n.add_to_cart,
                                          onPressed: () {
                                            if (settings.id.isEmpty) {
                                              return;
                                            }
                                            _addItemToCart(
                                              CartType.IKnow.name,
                                              settings.id,
                                              _bundleName,
                                            );
                                          }),
                                      SizedBox(
                                        height: 20.h,
                                      )
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 360.w,
                  height: 112.h,
                  decoration: ShapeDecoration(
                    color: MyColors.cartFooterBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.r),
                        bottomRight: Radius.circular(25.r),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/cart/subtract.png"),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "جهت کسب اطلاعات بیشتر به وبسایت پورتک به نشانی www.poortak.ir مراجه کنید.",
                          style: MyTextStyle.textMatn11,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
