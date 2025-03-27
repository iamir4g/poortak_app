import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/featueres/fetures_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/fetures_shopping_cart/presentation/bloc/shopping_cart_cubit.dart';
import 'package:poortak/locator.dart';

class SayarehScreen extends StatelessWidget {
  const SayarehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SayarehCubit(sayarehRepository: locator()),
        ),
        BlocProvider(
          create: (context) =>
              ShoppingCartCubit(shoppingCartRepository: locator()),
        ),
      ],
      child: Builder(builder: (context) {
        BlocProvider.of<SayarehCubit>(context).callSayarehDataEvent();
        return BlocBuilder<SayarehCubit, SayarehState>(
            buildWhen: (previous, current) {
          if (previous.sayarehDataStatus == current.sayarehDataStatus) {
            return false;
          }
          return true;
        }, builder: (context, state) {
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
                    Text(l10n?.sayareh ?? ""),
                    // Sayareh List Section
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sayarehDataCompleted.data.sayareh.length,
                      itemBuilder: (context, index) {
                        final item = sayarehDataCompleted.data.sayareh[index];
                        return GestureDetector(
                            onTap: () {
                              if (!item.isLock) {
                                final cartItem = ShoppingCartItem(
                                  title: item.title,
                                  description: item.description,
                                  image: item.image,
                                  isLock: item.isLock,
                                );
                                context
                                    .read<ShoppingCartCubit>()
                                    .addToCart(cartItem);
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
                                          backgroundImage:
                                              NetworkImage(item.image),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.title),
                                            Text(item.description),
                                          ],
                                        )
                                      ]),
                                    ),
                                    Row(
                                      children: [
                                        item.isLock
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
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Example Box 1
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
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
        });
      }),
    );
  }
}
