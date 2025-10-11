import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/single_book_cubit.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';

class PdfReaderScreen extends StatelessWidget {
  static const routeName = "/pdf_reader_screen";

  const PdfReaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookId = args?['bookId'] as String?;

    if (bookId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('خطا', style: MyTextStyle.textMatn14Bold),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('شناسه کتاب یافت نشد'),
        ),
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
      child: BlocBuilder<SingleBookCubit, SingleBookState>(
        buildWhen: (previous, current) {
          if (previous.singleBookDataStatus == current.singleBookDataStatus) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          /// loading
          if (state.singleBookDataStatus is SingleBookDataLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text('در حال بارگذاری...',
                    style: MyTextStyle.textMatn14Bold),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Container(
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
              ),
            );
          }

          /// completed
          if (state.singleBookDataStatus is SingleBookDataCompleted) {
            final SingleBookDataCompleted bookDataCompleted =
                state.singleBookDataStatus as SingleBookDataCompleted;
            final bookData = bookDataCompleted.data.data;

            return _buildPdfReaderContent(context, bookData);
          }

          /// error
          if (state.singleBookDataStatus is SingleBookDataError) {
            final SingleBookDataError bookDataError =
                state.singleBookDataStatus as SingleBookDataError;

            return Scaffold(
              appBar: AppBar(
                title: Text('خطا', style: MyTextStyle.textMatn14Bold),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Container(
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
                        bookDataError.errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800),
                        onPressed: () {
                          /// call data again
                          BlocProvider.of<SingleBookCubit>(context)
                              .fetchBookById(bookId);
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

  Widget _buildPdfReaderContent(BuildContext context, dynamic bookData) {
    // Determine which file to download based on purchase status
    String? fileToDownload;
    if (bookData.purchased && bookData.file.isNotEmpty) {
      fileToDownload = bookData.file;
    } else if (!bookData.purchased &&
        bookData.trialFile != null &&
        bookData.trialFile.isNotEmpty) {
      fileToDownload = bookData.trialFile;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookData.title,
          style: MyTextStyle.textMatn14Bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // This will trigger the download in the PDF reader
              // The download button is already handled by CustomPdfReader
            },
            tooltip: 'دانلود کتاب',
          ),
        ],
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Purchase button section (only show if not purchased)
              if (!bookData.purchased) ...[
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'نسخه پیش نمایش',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'برای دسترسی کامل به کتاب، آن را خریداری کنید',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showPurchaseModal(context, bookData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'خرید کتاب',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _addToCart(context, bookData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'افزودن به سبد خرید',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'قیمت: ${_toPersianNumbers(bookData.price)} تومان',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // PDF Reader
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: fileToDownload != null && fileToDownload.isNotEmpty
                        ? CustomPdfReader(
                            fileKey: fileToDownload,
                            fileName: '${bookData.title}.pdf',
                            fileId: 'book_${bookData.id}',
                            storageService: locator<StorageService>(),
                            showDownloadButton: true,
                            autoDownload: false,
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'فایل کتاب در دسترس نیست',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseModal(BuildContext context, dynamic bookData) {
    ReusableModal.show(
      context: context,
      title: 'تأیید خرید',
      message: 'آیا مطمئن هستید که می‌خواهید این کتاب را خریداری کنید؟',
      buttonText: 'خرید',
      type: ModalType.info,
      showSecondButton: true,
      secondButtonText: 'انصراف',
      onButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
        _addToCart(context, bookData);
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
      },
    );
  }

  void _addToCart(BuildContext context, dynamic bookData) {
    final prefsOperator = locator<PrefsOperator>();

    if (!prefsOperator.isLoggedIn()) {
      ReusableModal.show(
        context: context,
        title: 'ورود به حساب کاربری',
        message:
            'برای افزودن کتاب به سبد خرید، ابتدا وارد حساب کاربری خود شوید',
        buttonText: 'متوجه شدم',
        type: ModalType.info,
      );
      return;
    }

    // Add to cart using the shopping cart bloc
    final shoppingCartBloc = BlocProvider.of<ShoppingCartBloc>(context);
    shoppingCartBloc.add(AddToLocalCartEvent(
      CartType.IKnowBook.name,
      bookData.id,
    ));

    // Show success message
    ReusableModal.show(
      context: context,
      title: 'موفقیت',
      message: 'کتاب با موفقیت به سبد خرید اضافه شد',
      buttonText: 'متوجه شدم',
      type: ModalType.success,
    );
  }

  String _toPersianNumbers(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }
}
