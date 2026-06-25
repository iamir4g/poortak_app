import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/single_book_bloc/single_book_cubit.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:dio/dio.dart';

class BookDetailScreen extends StatefulWidget {
  static const routeName = "/book_detail_screen";

  const BookDetailScreen({super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    locator<IknowAccessBloc>().add(FetchIknowAccessEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookId = args?['bookId'] as String?;

    if (bookId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطا')),
        body: const Center(child: Text('شناسه کتاب یافت نشد')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = SingleBookCubit(sayarehRepository: locator());
            cubit.fetchBookById(bookId);
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) => ShoppingCartBloc(repository: locator()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? MyColors.darkBackground
            : Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? MyColors.darkBackgroundSecondary
              : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Theme.of(context).brightness == Brightness.dark
                  ? MyColors.darkTextPrimary
                  : Colors.black,
            ),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).brightness == Brightness.dark
                    ? MyColors.darkTextPrimary
                    : Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<IknowAccessBloc, IknowAccessState>(
            bloc: locator<IknowAccessBloc>(),
            builder: (context, accessState) {
              return BlocBuilder<SingleBookCubit, SingleBookState>(
            builder: (context, state) {
              if (state.singleBookDataStatus is SingleBookDataLoading) {
                return Center(child: DotLoadingWidget(size: 50.r));
              }

              if (state.singleBookDataStatus is SingleBookDataCompleted) {
                final bookData =
                    (state.singleBookDataStatus as SingleBookDataCompleted)
                        .data
                        .data;
                return _buildContent(context, bookData);
              }

              if (state.singleBookDataStatus is SingleBookDataError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('خطا در دریافت اطلاعات'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SingleBookCubit>().fetchBookById(bookId);
                        },
                        child: const Text('تلاش دوباره'),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic bookData) {
    final bool hasAccess = locator<IknowAccessBloc>().hasBookAccess(bookData.id);
    final bool hasDemo = bookData.isDemo ?? false;
    final String? trialFile = bookData.trialFile;
    final bool showSampleButton =
        hasDemo && trialFile != null && trialFile.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Dimens.nw(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Dimens.nh(20)),
                // Book Cover
                Center(
                  child: Container(
                    width: Dimens.nw(261.0),
                    height: Dimens.nh(216.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.nr(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.nr(12)),
                      child: FutureBuilder<String>(
                        future: GetImageUrlService()
                            .getImageUrl(bookData.thumbnail ?? ""),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.book, size: 50)),
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimens.nh(24)),
                // Title
                Text(
                  bookData.title ?? "",
                  style: TextStyle(
                    fontSize: Dimens.nsp(20),
                    fontWeight: FontWeight.bold,
                    color: isDark ? MyColors.darkTextPrimary : MyColors.text2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimens.nh(8)),
                Text(
                  "نسخه الکترونیکی",
                  style: TextStyle(
                    fontSize: Dimens.nsp(14),
                    color: isDark ? MyColors.darkTextSecondary : MyColors.text5,
                  ),
                ),
                // const SizedBox(height: 2),
                // Price
                if (!hasAccess) ...[
                  Divider(
                    height: Dimens.nh(32),
                    color: isDark ? MyColors.darkBorder : MyColors.dividerGray,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "قیمت:",
                        style: TextStyle(
                          fontSize: Dimens.nsp(16),
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.textMatn1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            bookData.price != null
                                ? MoneyUtils.formatTomanFromRial(bookData.price)
                                : "0",
                            style: TextStyle(
                              fontSize: Dimens.nsp(16),
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? MyColors.darkTextPrimary
                                  : MyColors.textMatn1,
                            ),
                          ),
                          SizedBox(width: Dimens.nw(4)),
                          Text(
                            "تومان",
                            style: TextStyle(
                              fontSize: Dimens.nsp(14),
                              color: isDark
                                  ? MyColors.darkTextSecondary
                                  : MyColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                SizedBox(height: Dimens.nh(32)),
                SizedBox(
                  height: Dimens.nh(40),
                  // child: Align(
                  // alignment: Alignment.centerRight,
                  child: TabBar(
                    dividerColor:
                        isDark ? MyColors.darkBorder : MyColors.dividerGray,
                    controller: _tabController,
                    isScrollable: true,
                    labelStyle: MyTextStyle.tabLabel16.copyWith(
                      color: isDark
                          ? MyColors.darkTextPrimary
                          : MyColors.activeTabBackground,
                    ),
                    unselectedLabelStyle: MyTextStyle.tabLabel16.copyWith(
                      color: isDark
                          ? MyColors.darkTextSecondary
                          : MyColors.inactiveTabBackground,
                    ),
                    indicatorColor: MyColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: Dimens.nw(2),
                    tabs: const [
                      Tab(text: "درباره کالا"),
                      Tab(text: "ویژگی های کالا"),
                    ],
                  ),
                  // ),
                ),
                SizedBox(height: Dimens.nh(16)),
                SizedBox(
                  height: Dimens.nh(200),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // درباره کالا
                      SingleChildScrollView(
                        child: Text(
                          bookData.description ?? "توضیحاتی موجود نیست.",
                          style: TextStyle(
                            fontSize: Dimens.nsp(14),
                            height: 1.5,
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.textMatn1,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      // ویژگی های کالا
                      Column(
                        children: [
                          _buildAttributeRow(
                              "ناشر:", bookData.publisher ?? "-"),
                          _buildAttributeRow(
                              "نویسنده:", bookData.author ?? "-"),
                          _buildAttributeRow("فرمت:", "PDF"), // Assumed
                          _buildAttributeRow("تعداد صفحه:",
                              bookData.pageCount?.toString() ?? "-"),
                          _buildAttributeRow("تاریخ نشر:",
                              bookData.publishDate?.toString() ?? "-"),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimens.nh(100)),
              ],
            ),
          ),
        ),
        // Bottom Buttons
        Container(
          padding: EdgeInsets.all(Dimens.medium),
          decoration: BoxDecoration(
            color: isDark ? MyColors.darkBackgroundSecondary : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSampleButton && !hasAccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: Dimens.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/pdf_reader_screen',
                        arguments: {
                          'bookId': bookData.id,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? MyColors.darkBorder : Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(12)),
                      ),
                    ),
                    child: Text(
                      "خواندن نمونه",
                      style: TextStyle(
                        color:
                            isDark ? MyColors.darkTextSecondary : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimens.nh(12)),
              ],
              PrimaryButton(
                width: double.infinity,
                height: Dimens.buttonHeight,
                lable: hasAccess ? "خواندن کتاب" : "خرید کتاب",
                onPressed: () {
                  if (hasAccess) {
                    Navigator.pushNamed(
                      context,
                      '/pdf_reader_screen',
                      arguments: {
                        'bookId': bookData.id,
                      },
                    );
                  } else {
                    _addItemToCart(context, bookData);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.nh(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? MyColors.darkTextSecondary : Colors.grey,
              fontSize: Dimens.nsp(14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? MyColors.darkTextPrimary : Colors.black,
              fontSize: Dimens.nsp(14),
            ),
          ),
        ],
      ),
    );
  }

  void _addItemToCart(BuildContext context, dynamic bookData) async {
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = prefsOperator.isLoggedIn();
    final String type = CartType.IKnowBook.name;
    final String itemId = bookData.id;
    final String itemName = bookData.title;

    if (isLoggedIn) {
      try {
        final apiProvider = locator<ShoppingCartApiProvider>();
        final cartType = CartType.values.firstWhere((e) => e.name == type);
        await apiProvider.addToCart(cartType, itemId);

        if (context.mounted) {
          context.read<ShoppingCartBloc>().add(GetCartEvent());
          _showSuccessModal(context, itemName);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_extractErrorMessage(e)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));
      _showSuccessModal(context, itemName);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) return data['message'];
        if (data is Map && data.containsKey('error')) return data['error'];
        if (data is String) return data;
      }
      return error.message ?? 'خطا در افزودن به سبد خرید';
    }
    return error.toString();
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
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
          MainWrapper.routeName,
          (route) => false,
          arguments: {'initialIndex': 2},
        );
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
