import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/storage_service.dart';

class SayarehScreen extends StatefulWidget {
  static const routeName = "/sayareh_screen";
  const SayarehScreen({super.key});

  @override
  State<SayarehScreen> createState() => _SayarehScreenState();
}

class _SayarehScreenState extends State<SayarehScreen> {
  final StorageService _storageService = locator<StorageService>();
  Map<String, String> _imageUrls = {};

  Future<String> _getImageUrl(String thumbnailId) async {
    if (_imageUrls.containsKey(thumbnailId)) {
      return _imageUrls[thumbnailId]!;
    }

    try {
      final response = await _storageService.callGetDownloadUrl(thumbnailId);
      _imageUrls[thumbnailId] = response.data;
      return response.data;
    } catch (e) {
      print('Error getting image URL: $e');
      return ''; // Return empty string or a placeholder image URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = SayarehCubit(sayarehRepository: locator());
            // Initialize the cubit right after creation
            cubit.callSayarehDataEvent();
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final bloc = ShoppingCartBloc(repository: locator());
            bloc.add(GetCartEvent());
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<SayarehCubit, SayarehState>(
        buildWhen: (previous, current) {
          if (previous.sayarehDataStatus == current.sayarehDataStatus) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          /// loading
          if (state.sayarehDataStatus is SayarehDataLoading) {
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

          /// completed
          if (state.sayarehDataStatus is SayarehDataCompleted) {
            final SayarehDataCompleted sayarehDataCompleted =
                state.sayarehDataStatus as SayarehDataCompleted;
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 28,
                    ),
                    Text(
                      l10n?.sayareh ?? "",
                      style: MyTextStyle.textMatn14Bold,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    // Sayareh List Section

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sayarehDataCompleted.data.data.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final item = sayarehDataCompleted.data.data[index];
                        return GestureDetector(
                            onTap: () {
                              if (item.price != "0") {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return buildDialog(context, item);
                                    });
                              } else {
                                Navigator.pushNamed(
                                    context, LessonScreen.routeName,
                                    arguments: {
                                      'index': index,
                                      'title': item.name,
                                      'lessonId': item.id,
                                    });
                              }
                            },
                            child: Container(
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
                                    Container(
                                      child: Row(children: [
                                        CircleAvatar(
                                          maxRadius: 30,
                                          minRadius: 30,
                                          child: FutureBuilder<String>(
                                            future:
                                                _getImageUrl(item.thumbnail),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              }
                                              if (snapshot.hasError ||
                                                  !snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Icon(Icons.error);
                                              }
                                              return Image.network(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name),
                                            Text(item.description),
                                          ],
                                        )
                                      ]),
                                    ),
                                    Row(
                                      children: [
                                        item.price != "0"
                                            ? Image(
                                                image: AssetImage(
                                                    "assets/images/lock_image.png"))
                                            : SizedBox(),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Icon(Icons.arrow_forward_ios,
                                            color: Colors.black),
                                      ],
                                    ),
                                  ],
                                )));
                      },
                    ),

                    // Additional Boxes Section
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFF7F1), //#FFF7F1
                            Color(0xFFFFE2CE), //#FFE2CE
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                      // margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "کتاب های سیاره آی نو",
                            style: MyTextStyle.textMatn14Bold,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          // Example Box 1
                          Container(
                            width: 360,
                            height: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Box 1',
                                    style: TextStyle(color: Colors.white)),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Example Box 2
                          Container(
                            width: 360,
                            height: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Box 2',
                                    style: TextStyle(color: Colors.white)),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          /// error
          if (state.sayarehDataStatus is SayarehDataError) {
            final SayarehDataError sayarehDataError =
                state.sayarehDataStatus as SayarehDataError;

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
                      sayarehDataError.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800),
                      onPressed: () {
                        /// call all data again
                        BlocProvider.of<SayarehCubit>(context)
                            .callSayarehDataEvent();
                      },
                      child: const Text("تلاش دوباره"),
                    )
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget buildDialog(BuildContext context, dynamic item) {
    final cartItem = ShoppingCartItem(
      title: item.name,
      description: item.description,
      image: item.thumbnail,
      isLock: item.price != "0",
      price: int.parse(item.price),
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
                          Tab(text: "خرید مجموعه"),
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
                                                "${item.price.toString().addComma} "),
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
                                    context
                                        .read<ShoppingCartBloc>()
                                        .add(AddToCartEvent(cartItem));
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
                                      padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
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
                            PrimaryButton(
                                width: 286,
                                height: 65,
                                lable: l10n.add_to_cart,
                                onPressed: () {
                                  context
                                      .read<ShoppingCartBloc>()
                                      .add(AddToCartEvent(cartItem));
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
              ],
            ),
          ),
        ));
  }
}
