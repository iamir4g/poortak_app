import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_leason.dart';
import 'package:poortak/l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_book.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/locator.dart';
// import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'dart:developer';

class SayarehScreen extends StatefulWidget {
  static const routeName = "/sayareh_screen";
  const SayarehScreen({super.key});

  @override
  State<SayarehScreen> createState() => _SayarehScreenState();
}

class _SayarehScreenState extends State<SayarehScreen> {
  final PrefsOperator _prefsOperator = locator<PrefsOperator>();

  // Helper method to add item to cart based on login status

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
                        return ItemLeason(
                            item: item, onTap: () {}, index: index);
                        // GestureDetector(
                        //     onTap: () {
                        //       if (item.price != "0") {
                        //         showDialog(
                        //             context: context,
                        //             builder: (context) {
                        //               return buildDialog(context, item);
                        //             });
                        //       } else {
                        //         Navigator.pushNamed(
                        //             context, LessonScreen.routeName,
                        //             arguments: {
                        //               'index': index,
                        //               'title': item.name,
                        //               'lessonId': item.id,
                        //             });
                        //       }
                        //     },
                        //     child: Container(
                        //         width: 360,
                        //         height: 80,
                        //         margin: const EdgeInsets.symmetric(
                        //             horizontal: 16, vertical: 8),
                        //         padding: const EdgeInsets.all(16),
                        //         decoration: BoxDecoration(
                        //           color: MyColors.background,
                        //           borderRadius: BorderRadius.circular(40),
                        //         ),
                        //         child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Container(
                        //               child: Row(children: [
                        //                 CircleAvatar(
                        //                   maxRadius: 30,
                        //                   minRadius: 30,
                        //                   child: FutureBuilder<String>(
                        //                     future: GetImageUrlService()
                        //                         .getImageUrl(item.thumbnail),
                        //                     // _getImageUrl(item.thumbnail),
                        //                     builder: (context, snapshot) {
                        //                       if (snapshot.connectionState ==
                        //                           ConnectionState.waiting) {
                        //                         return const CircularProgressIndicator();
                        //                       }
                        //                       if (snapshot.hasError ||
                        //                           !snapshot.hasData ||
                        //                           snapshot.data!.isEmpty) {
                        //                         return const Icon(Icons.error);
                        //                       }
                        //                       return Image.network(
                        //                         snapshot.data!,
                        //                         fit: BoxFit.cover,
                        //                         errorBuilder: (context, error,
                        //                             stackTrace) {
                        //                           return const Icon(
                        //                               Icons.error);
                        //                         },
                        //                       );
                        //                     },
                        //                   ),
                        //                 ),
                        //                 const SizedBox(width: 8),
                        //                 Column(
                        //                   mainAxisAlignment:
                        //                       MainAxisAlignment.start,
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.start,
                        //                   children: [
                        //                     Text(item.name),
                        //                     Text(item.description),
                        //                   ],
                        //                 )
                        //               ]),
                        //             ),
                        //             Row(
                        //               children: [
                        //                 item.price != "0"
                        //                     ? Image(
                        //                         image: AssetImage(
                        //                             "assets/images/lock_image.png"))
                        //                     : SizedBox(),
                        //                 SizedBox(
                        //                   width: 8,
                        //                 ),
                        //                 Icon(Icons.arrow_forward_ios,
                        //                     color: Colors.black),
                        //               ],
                        //             ),
                        //           ],
                        //         )));
                      },
                    ),

                    // Additional Boxes Section
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          if (sayarehDataCompleted.bookListData.data != null &&
                              sayarehDataCompleted
                                  .bookListData.data!.isNotEmpty)
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sayarehDataCompleted
                                  .bookListData.data!.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 12);
                              },
                              itemBuilder: (context, index) {
                                return ItemBook(
                                  title: sayarehDataCompleted
                                      .bookListData.data![index].title,
                                  description: sayarehDataCompleted
                                      .bookListData.data![index].description,
                                  thumbnail: sayarehDataCompleted
                                      .bookListData.data![index].thumbnail,
                                  fileKey: sayarehDataCompleted
                                      .bookListData.data![index].file,
                                  // price: sayarehDataCompleted.bookListData.data![index].price,
                                );
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: const Center(
                                child: Text(
                                  "هیچ کتابی یافت نشد",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          // Example Box 1

                          // const SizedBox(height: 12),
                          // Example Box 2
                          // Container(
                          //   width: 360,
                          //   height: 100,
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: const Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text('Box 2',
                          //           style: TextStyle(color: Colors.white)),
                          //       Icon(Icons.arrow_forward_ios,
                          //           color: Colors.white),
                          //     ],
                          //   ),
                          // ),
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
}
