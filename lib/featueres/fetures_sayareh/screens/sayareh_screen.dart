import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_leason.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_bloc/sayareh_cubit.dart';
import 'package:poortak/featueres/feature_match/screens/main_match_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';

import 'package:poortak/featueres/fetures_sayareh/widgets/item_book.dart';

import 'package:poortak/featueres/fetures_sayareh/widgets/contest_card.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
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

  @override
  void initState() {
    super.initState();
    // Fetch access data every time this screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessBloc = locator<IknowAccessBloc>();
      accessBloc.add(FetchIknowAccessEvent(forceRefresh: true));
    });
  }

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
        BlocProvider.value(
          value: locator<IknowAccessBloc>(),
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
              child:
                  SafeArea(child: Center(child: DotLoadingWidget(size: 100.r))),
            );
          }

          /// completed
          if (state.sayarehDataStatus is SayarehDataCompleted) {
            final SayarehDataCompleted sayarehDataCompleted =
                state.sayarehDataStatus as SayarehDataCompleted;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
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
                    child: SafeArea(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 28.h,
                          ),
                          Text(
                            l10n?.sayareh ?? "",
                            style: MyTextStyle.textMatn12W700.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          // Sayareh List Section

                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sayarehDataCompleted.data.data.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 4.h);
                            },
                            itemBuilder: (context, index) {
                              final item =
                                  sayarehDataCompleted.data.data[index];
                              CourseProgressItem? progress;
                              if (sayarehDataCompleted.progressData != null) {
                                try {
                                  progress = sayarehDataCompleted
                                      .progressData!.data
                                      .firstWhere((element) =>
                                          element.iKnowCourseId == item.id);
                                } catch (e) {
                                  progress = null;
                                }
                              }
                              return ItemLeason(
                                  item: item,
                                  onTap: () {},
                                  index: index,
                                  purchased: item.purchased,
                                  progress: progress);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
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
                          height: 30.h,
                        ),
                        Text(
                          "کتاب های سیاره آی نو",
                          style: MyTextStyle.textMatn12W700.copyWith(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        if (sayarehDataCompleted.bookListData.data != null &&
                            sayarehDataCompleted.bookListData.data!.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                sayarehDataCompleted.bookListData.data!.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 4.h);
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
                                trialFile: sayarehDataCompleted
                                    .bookListData.data![index].trialFile,
                                purchased: sayarehDataCompleted
                                    .bookListData.data![index].purchased,
                                price: sayarehDataCompleted
                                    .bookListData.data![index].price,
                                bookId: sayarehDataCompleted
                                    .bookListData.data![index].id,
                              );
                            },
                          )
                        else
                          Container(
                            // padding: const EdgeInsets.all(20),
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
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),

                  // Contest Card Section
                  const SizedBox(height: 20),
                  ContestCard(
                    onTap: () {
                      if (locator<PrefsOperator>().isLoggedIn()) {
                        Navigator.pushNamed(context, MainMatchScreen.routeName);
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
                  const SizedBox(height: 100),
                ],
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
              child: SafeArea(
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
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
