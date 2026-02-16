import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/single_book_bloc/single_book_cubit.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';

class PdfReaderScreen extends StatelessWidget {
  static const routeName = "/pdf_reader_screen";

  const PdfReaderScreen({super.key});

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
    // Determine which file to download based on login and purchase status
    String? fileToDownload;
    bool usePublicUrl = false;

    // Check if user is logged in
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = prefsOperator.isLoggedIn();

    if (isLoggedIn) {
      // User is logged in
      print(
          "User is logged in. purchased: ${bookData.purchased}, file: ${bookData.file}, trialFile: ${bookData.trialFile}");
      if (bookData.purchased == true &&
          bookData.file != null &&
          bookData.file.toString().trim().isNotEmpty) {
        // User has purchased the book, use the full file
        fileToDownload = bookData.file;
        usePublicUrl = false;
        print("Using purchased file: $fileToDownload with authenticated URL");
      } else if (bookData.trialFile != null &&
          bookData.trialFile.toString().trim().isNotEmpty) {
        // User hasn't purchased or file is not available, use trial file with public URL
        fileToDownload = bookData.trialFile;
        usePublicUrl = true;
        print("Using trial file: $fileToDownload with public URL");
      }
    } else {
      // User is not logged in, always use trial file with public URL
      print("User is not logged in. trialFile: ${bookData.trialFile}");
      if (bookData.trialFile != null &&
          bookData.trialFile.toString().trim().isNotEmpty) {
        fileToDownload = bookData.trialFile;
        usePublicUrl = true;
        print("Using trial file: $fileToDownload with public URL");
      } else {
        print("Trial file is not available for non-logged in user");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookData.title,
          style: MyTextStyle.textMatn14Bold,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
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
                            showDownloadButton: false,
                            autoDownload: true,
                            usePublicUrl: usePublicUrl,
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
}
