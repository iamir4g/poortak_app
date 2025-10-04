import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
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
import 'package:poortak/featueres/feature_match/screens/main_match_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_book.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_multi_card.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/contest_card.dart';
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
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1D2E),
                          Color(0xFF2C2E3F),
                          Color(0xFF3B3D54),
                        ],
                        stops: [0.1, 0.54, 1.0],
                      )
                    : const LinearGradient(
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
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1D2E),
                          Color(0xFF2C2E3F),
                          Color(0xFF3B3D54),
                        ],
                        stops: [0.1, 0.54, 1.0],
                      )
                    : const LinearGradient(
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
                      style: MyTextStyle.textMatn17W700?.copyWith(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
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
                            item: item,
                            onTap: () {},
                            index: index,
                            purchased: item.purchased);
                      },
                    ),

                    // Additional Boxes Section
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: Theme.of(context).brightness ==
                                Brightness.dark
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF2C2E3F), // Dark card background
                                  Color(0xFF3B3D54), // Darker card background
                                ],
                                stops: [0.0, 1.0],
                              )
                            : LinearGradient(
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
                            style: MyTextStyle.textMatn14Bold?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
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
                                      .bookListData.data![index].id,
                                  // price: sayarehDataCompleted.bookListData.data![index].price,
                                );
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  "هیچ کتابی یافت نشد",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ),
                            ),
                          // Example Box 1
                        ],
                      ),
                    ),

                    // Contest Card Section
                    const SizedBox(height: 20),
                    ContestCard(
                      onTap: () {
                        if (locator<PrefsOperator>().isLoggedIn()) {
                          Navigator.pushNamed(
                              context, MainMatchScreen.routeName);
                        } else {
                          ReusableModal.show(
                            context: context,
                            title: '',
                            message: 'لطفا ابتدا وارد حساب کاربری خود شوید',
                            type: ModalType.info,
                          );
                        }
                      },
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
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1D2E),
                          Color(0xFF2C2E3F),
                          Color(0xFF3B3D54),
                        ],
                        stops: [0.1, 0.54, 1.0],
                      )
                    : const LinearGradient(
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
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
