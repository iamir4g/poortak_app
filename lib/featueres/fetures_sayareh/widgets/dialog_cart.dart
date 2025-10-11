import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/locator.dart';

class DialogCart extends StatefulWidget {
  final Lesson item;
  const DialogCart({super.key, required this.item});

  @override
  State<DialogCart> createState() => _DialogCartState();
}

class _DialogCartState extends State<DialogCart> {
  final PrefsOperator _prefsOperator = locator<PrefsOperator>();

  void _addItemToCart(
      BuildContext context, String type, String itemId, String itemName) {
    final isLoggedIn = _prefsOperator.isLoggedIn();

    log("🛒 Adding item to cart: $itemName");
    log("   Type: $type");
    log("   ID: $itemId");
    log("   User logged in: $isLoggedIn");

    if (isLoggedIn) {
      // User is logged in - add to server cart
      log("📤 Adding item to server cart via API");
      context.read<ShoppingCartBloc>().add(AddToCartEvent(
            ShoppingCartItem(
              title: itemName,
              description:
                  type == 'IKnowCourse' ? 'دوره تک درس' : 'مجموعه کامل',
              image: '',
              isLock: false,
              price: type == 'IKnowCourse' ? 75000 : 750000,
            ),
          ));
    } else {
      // User is not logged in - add to local cart
      log("📱 Adding item to local cart");
      context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItem = ShoppingCartItem(
      title: widget.item.name,
      description: widget.item.description,
      image: widget.item.thumbnail,
      isLock: widget.item.price != "0",
      price: int.parse(widget.item.price),
    );

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
                  height: 18,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                        dividerHeight: 0.0,
                        labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "IranSans"),
                        indicatorColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: MyColors.darkBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            text: "خرید تکی",
                          ),
                          Tab(text: "خرید مجموعه %"),
                        ])),
                SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 286,
                                    height: 177,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(27)),
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    left: 8,
                                    child: Container(
                                      width: 104,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          color: Colors.white),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(4, 0, 4, 0),
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
                                height: 26,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        image: AssetImage(
                                            "assets/images/lock_image.png")),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "درس اول انیمیشن سیاره آی نو",
                                      style: MyTextStyle.textMatn12W500,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: MyColors.cardBackground1,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
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
                                              "${l10n!.toman}",
                                              style: MyTextStyle.textMatn13,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              PrimaryButton(
                                  width: 286,
                                  height: 65,
                                  lable: l10n.add_to_cart,
                                  onPressed: () {
                                    // Add single course to cart using item ID and IKnowCourse type
                                    _addItemToCart(
                                        context,
                                        CartType.IKnowCourse.name,
                                        widget.item.id,
                                        widget.item.name);
                                    Navigator.pop(context);
                                  })
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: 286,
                                  height: 177,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(27)),
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Positioned(
                                    bottom: 35,
                                    right: 8,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      // decoration: BoxDecoration(
                                      //   color: Colors.white,
                                      //   borderRadius: BorderRadius.circular(15),
                                      // ),
                                      child: IconifyIcon(
                                          color: Colors.white,
                                          icon: "arcticons:pdf-viewer"),
                                    )),
                                Positioned(
                                  bottom: 5,
                                  right: 8,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(15),
                                    // ),
                                    child: IconifyIcon(
                                        color: Colors.white,
                                        icon: "carbon:play-outline"),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 8,
                                  child: Container(
                                    width: 104,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.white),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(4, 0, 2, 0),
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
                              height: 26,
                            ),
                            Container(
                              decoration:
                                  BoxDecoration(color: MyColors.background1),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Center(
                                      child: Text(
                                    "انیمیشن سیاره آی نو",
                                    style: MyTextStyle.textMatn14Bold,
                                  )),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  //items in shopping cart
                                  SizedBox(
                                    width: 248,
                                    child: ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 10,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 6);
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
                                    height: 20,
                                  ),
                                  Center(
                                      child: Text(
                                    "کتاب های الکترونیکی",
                                    style: MyTextStyle.textMatn14Bold,
                                  )),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  ItemMultiCard(
                                    title: "فرهنگ لغت پورتک ",
                                    price: "75000",
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  ItemMultiCard(
                                    title: "گرامر پورتک",
                                    price: "75000",
                                  ),
                                  SizedBox(
                                    height: 14,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
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
                                            l10n!.toman,
                                            style: MyTextStyle.textMatn10W300,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: 286,
                                    height: 42,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFEF3E6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
                                              width: 33,
                                              height: 17.84,
                                              alignment: Alignment.center,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFFF5353),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          11.50),
                                                ),
                                              ),
                                              child: Text(
                                                "10%",
                                                style:
                                                    MyTextStyle.textMatn10W300,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "150000",
                                              style: MyTextStyle.textMatn12W300,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              l10n!.toman,
                                              style: MyTextStyle.textMatn10W300,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: 286,
                                    height: 54,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF5F6F9),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 2,
                                          color: const Color(0xFFFFA63E),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                              width: 4,
                                            ),
                                            Text(
                                              l10n!.toman,
                                              style: MyTextStyle.textMatn10W300,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            ),
                            PrimaryButton(
                                width: 286,
                                height: 65,
                                lable: l10n.add_to_cart,
                                onPressed: () {
                                  // Add bundle to cart using specific item ID and IKnow type
                                  _addItemToCart(
                                      context,
                                      CartType.IKnow.name,
                                      "4a61cc6b-8e3c-46e5-ad3c-5f52d0aff181",
                                      "مجموعه کامل سیاره آی نو");
                                  Navigator.pop(context);
                                }),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 360,
                  height: 112,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEFF1F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/cart/subtract.png"),
                      Container(
                        // margin: EdgeInsets.only(right: 10),
                        width: 230,
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
