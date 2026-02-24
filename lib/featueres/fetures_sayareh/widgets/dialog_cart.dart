import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';

class DialogCart extends StatefulWidget {
  final Lesson item;
  const DialogCart({super.key, required this.item});

  @override
  State<DialogCart> createState() => _DialogCartState();
}

class _DialogCartState extends State<DialogCart> {
  final PrefsOperator _prefsOperator = locator<PrefsOperator>();

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

  void _addItemToCart(
      BuildContext context, String type, String itemId, String itemName) async {
    final isLoggedIn = _prefsOperator.isLoggedIn();

    log("🛒 Adding item to cart: $itemName");
    log("   Type: $type");
    log("   ID: $itemId");
    log("   User logged in: $isLoggedIn");

    // Get root navigator context before closing dialog
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    if (isLoggedIn) {
      // User is logged in - add to server cart via API
      log("📤 Adding item to server cart via API");
      try {
        final apiProvider = locator<ShoppingCartApiProvider>();
        final cartType = CartType.values.firstWhere((e) => e.name == type);
        await apiProvider.addToCart(cartType, itemId);
        log("✅ Item added to server cart successfully");
        // Refresh cart after adding
        context.read<ShoppingCartBloc>().add(GetCartEvent());

        // Close current dialog
        Navigator.of(context).pop();

        // Show success modal after dialog is closed
        Future.microtask(() {
          _showSuccessModal(rootContext, itemName);
        });
      } catch (e) {
        log("❌ Failed to add item to server cart: $e");
        final errorMessage = _extractErrorMessage(e);
        log("📝 Extracted error message: $errorMessage");

        Navigator.of(context).pop(); // Close dialog even on error
        if (mounted) {
          Future.microtask(() {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: MyColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }
      }
    } else {
      // User is not logged in - add to local cart
      log("📱 Adding item to local cart");
      context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));

      // Close current dialog
      Navigator.of(context).pop();

      // Show success modal after dialog is closed
      Future.microtask(() {
        _showSuccessModal(rootContext, itemName);
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
    final l10n = AppLocalizations.of(context);
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
                                    child: Image.asset(
                                        "assets/images/cart/single_lesson.png"),
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
                                              l10n?.coin_with_buy ?? "",
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
                                      "درس اول انیمیشن سیاره آی نو",
                                      style: MyTextStyle.textMatn12W500,
                                    )
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
                                          l10n!.price,
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
                                    _addItemToCart(
                                        context,
                                        CartType.IKnowCourse.name,
                                        widget.item.id,
                                        widget.item.name);
                                  })
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(27.r)),
                                    color: MyColors.background,
                                  ),
                                  child: Image.asset(
                                      "assets/images/cart/bundle_lesson.png"),
                                ),
                                Positioned(
                                    bottom: 35.h,
                                    right: 8.w,
                                    child: SizedBox(
                                      width: 30.w,
                                      height: 30.h,
                                      // decoration: BoxDecoration(
                                      //   color: Colors.white,
                                      //   borderRadius: BorderRadius.circular(15),
                                      // ),
                                      child: IconifyIcon(
                                          color: MyColors.textLight,
                                          icon: "arcticons:pdf-viewer"),
                                    )),
                                Positioned(
                                  bottom: 5.h,
                                  right: 8.w,
                                  child: SizedBox(
                                    width: 30.w,
                                    height: 30.h,
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(15),
                                    // ),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.r)),
                                        color: MyColors.background),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(4.w, 0, 2.w, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
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
                                            l10n.coin_with_buy ?? "",
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
                                    "انیمیشن سیاره آی نو",
                                    style: MyTextStyle.textMatn14Bold,
                                  )),
                                  SizedBox(
                                    height: 18.h,
                                  ),
                                  //items in shopping cart
                                  SizedBox(
                                    width: 248.w,
                                    child: ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 8,
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 6.h);
                                        },
                                        itemBuilder: (context, index) {
                                          return ItemMultiCard(
                                            title:
                                                "درس ${index + 1} سیاره آی نو",
                                            price: "75000",
                                          );
                                        }),
                                  ),

                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Center(
                                      child: Text(
                                    "کتاب های الکترونیکی",
                                    style: MyTextStyle.textMatn14Bold,
                                  )),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  ItemMultiCard(
                                    title: "فرهنگ لغت پورتک ",
                                    price: "75000",
                                  ),
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  ItemMultiCard(
                                    title: "گرامر پورتک",
                                    price: "75000",
                                  ),
                                  SizedBox(
                                    height: 14.h,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "جمع دروس و کتاب ها",
                                        style: MyTextStyle.textMatn12W300,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${widget.item.price.toString().addComma} ",
                                            style: MyTextStyle.textMatn14Bold,
                                          ),
                                          Text(
                                            l10n.toman,
                                            style: MyTextStyle.textMatn10W300,
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
                                      color: MyColors.discountBackground,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "تخفیف",
                                          style: MyTextStyle.textMatn12W300,
                                        ),
                                        Row(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              width: 33.w,
                                              height: 17.84.h,
                                              alignment: Alignment.center,
                                              decoration: ShapeDecoration(
                                                color: MyColors.darkErrorLight,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          11.50.r),
                                                ),
                                              ),
                                              child: Text(
                                                "10%",
                                                style:
                                                    MyTextStyle.textMatn10W300,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              "150000",
                                              style: MyTextStyle.textMatn12W300,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              l10n.toman,
                                              style: MyTextStyle.textMatn10W300,
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
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "مبلغ قابل پرداخت",
                                          style: MyTextStyle.textMatn12W300,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "60000",
                                              style: MyTextStyle.textMatn14Bold,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              l10n.toman,
                                              style: MyTextStyle.textMatn10W300,
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
                                  // Add bundle to cart using specific item ID and IKnow type
                                  _addItemToCart(
                                      context,
                                      CartType.IKnow.name,
                                      "4a61cc6b-8e3c-46e5-ad3c-5f52d0aff181",
                                      "مجموعه کامل سیاره آی نو");
                                }),
                            SizedBox(
                              height: 20.h,
                            )
                          ],
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
