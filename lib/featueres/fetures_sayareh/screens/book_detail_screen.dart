import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/single_book_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/single_book_bloc/single_book_cubit.dart';
import 'package:poortak/locator.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'dart:developer';
import 'package:dio/dio.dart';

class BookDetailScreen extends StatelessWidget {
  static const routeName = "/book_detail_screen";

  const BookDetailScreen({super.key});

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
        body: BlocBuilder<SingleBookCubit, SingleBookState>(
          builder: (context, state) {
            if (state.singleBookDataStatus is SingleBookDataLoading) {
              return const Center(child: DotLoadingWidget(size: 50));
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
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic bookData) {
    // bookData is likely of type BookData from SingleBookModel
    // I need to check the fields. Based on user log:
    // id, title, description, price, author, publisher, pageCount, publishDate, isDemo, trialFile, purchased

    final bool isPurchased = bookData.purchased ?? false;
    final bool hasDemo = bookData.isDemo ?? false;
    final String? trialFile = bookData.trialFile;
    final bool showSampleButton =
        hasDemo && trialFile != null && trialFile.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Book Cover
                Center(
                  child: Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 24),
                // Title
                Text(
                  bookData.title ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3A4A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "نسخه الکترونیکی",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 24),
                // Price
                if (!isPurchased) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("قیمت:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            bookData.price != null
                                ? bookData.price.toString().addComma
                                : "0",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Text("تومان", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],

                // Attributes Tab/Section
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "ویژگی های کالا",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .orange, // Matches screenshot underline color roughly
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  width: 100,
                  color: Colors.orange,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                ),

                _buildAttributeRow("ناشر:", bookData.publisher ?? "-"),
                _buildAttributeRow("نویسنده:", bookData.author ?? "-"),
                _buildAttributeRow(
                    "قیمت ارزی:", "دلار"), // Placeholder based on screenshot
                _buildAttributeRow("فرمت:", "PDF"), // Assumed
                // _buildAttributeRow("حجم:", "۲۴ مگابایت"), // Placeholder
                _buildAttributeRow(
                    "تعداد صفحه:", bookData.pageCount?.toString() ?? "-"),
                _buildAttributeRow(
                    "تاریخ نشر:", bookData.publishDate?.toString() ?? "-"),

                const SizedBox(height: 20),
                // Description if needed, though screenshot focuses on attributes
                if (bookData.description != null) ...[
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text("درباره کالا",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookData.description!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        ),
        // Bottom Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSampleButton && !isPurchased) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("خواندن نمونه",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPurchased) {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4), // Blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isPurchased ? "خواندن کتاب" : "خرید کتاب",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
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
                backgroundColor: Colors.red),
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
