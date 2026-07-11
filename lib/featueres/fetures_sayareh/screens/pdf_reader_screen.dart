import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/single_book_bloc/single_book_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/utils/book_pdf_playback_resolver.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';

class PdfReaderScreen extends StatefulWidget {
  static const routeName = "/pdf_reader_screen";

  const PdfReaderScreen({super.key});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _appBarBackground(BuildContext context) => _isDark(context)
      ? MyColors.darkBackgroundSecondary
      : Theme.of(context).colorScheme.inversePrimary;

  Color _primaryTextColor(BuildContext context) => _isDark(context)
      ? MyColors.darkTextPrimary
      : MyColors.textMatn1;

  BoxDecoration _screenDecoration(BuildContext context) => BoxDecoration(
        gradient: _isDark(context)
            ? MyColors.sayarehScreenGradientDark
            : MyColors.sayarehScreenGradientLight,
      );

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required String title,
    bool showBack = true,
  }) {
    final primaryTextColor = _primaryTextColor(context);
    return AppBar(
      title: Text(
        title,
        style: MyTextStyle.textMatn14BoldFor(context),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: _appBarBackground(context),
      foregroundColor: primaryTextColor,
      iconTheme: IconThemeData(color: primaryTextColor),
      actions: [
        if (showBack)
          IconButton(
            icon: Icon(Icons.arrow_forward, color: primaryTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Widget _buildScreenBody(BuildContext context, {required Widget child}) {
    return Container(
      decoration: _screenDecoration(context),
      child: SafeArea(child: child),
    );
  }

  @override
  void initState() {
    super.initState();
    locator<IknowAccessBloc>().add(FetchIknowAccessEvent(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookId = args?['bookId'] as String?;
    final isTrialRead = args?['isTrialRead'] as bool? ?? false;

    if (bookId == null) {
      return Scaffold(
        backgroundColor: _isDark(context)
            ? MyColors.profileBackgroundDark
            : MyColors.background,
        appBar: _buildAppBar(context, title: 'خطا'),
        body: Center(
          child: Text(
            'شناسه کتاب یافت نشد',
            style: MyTextStyle.body16For(context),
          ),
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
      child: BlocBuilder<IknowAccessBloc, IknowAccessState>(
        bloc: locator<IknowAccessBloc>(),
        builder: (context, accessState) {
          return BlocBuilder<SingleBookCubit, SingleBookState>(
            builder: (context, state) {
              /// loading
              if (state.singleBookDataStatus is SingleBookDataLoading) {
                return Scaffold(
                  backgroundColor: _isDark(context)
                      ? MyColors.profileBackgroundDark
                      : null,
                  appBar: _buildAppBar(context, title: 'در حال بارگذاری...'),
                  body: _buildScreenBody(
                    context,
                    child: Center(
                      child: DotLoadingWidget(size: Dimens.nr(100)),
                    ),
                  ),
                );
              }

              /// completed
              if (state.singleBookDataStatus is SingleBookDataCompleted) {
                if (accessState is IknowAccessLoading) {
                  return Scaffold(
                    backgroundColor: _isDark(context)
                        ? MyColors.profileBackgroundDark
                        : null,
                    appBar:
                        _buildAppBar(context, title: 'در حال بارگذاری...'),
                    body: _buildScreenBody(
                      context,
                      child: Center(
                        child: DotLoadingWidget(size: Dimens.nr(100)),
                      ),
                    ),
                  );
                }

                final SingleBookDataCompleted bookDataCompleted =
                    state.singleBookDataStatus as SingleBookDataCompleted;
                final bookData = bookDataCompleted.data.data;

                return _buildPdfReaderContent(
                  context,
                  bookData,
                  isTrialRead: isTrialRead,
                );
              }

              /// error
              if (state.singleBookDataStatus is SingleBookDataError) {
                final SingleBookDataError bookDataError =
                    state.singleBookDataStatus as SingleBookDataError;

                return Scaffold(
                  backgroundColor: _isDark(context)
                      ? MyColors.profileBackgroundDark
                      : null,
                  appBar: _buildAppBar(context, title: 'خطا'),
                  body: _buildScreenBody(
                    context,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bookDataError.errorMessage,
                            style: MyTextStyle.body16For(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              BlocProvider.of<SingleBookCubit>(context)
                                  .fetchBookById(bookId);
                            },
                            child: const Text('تلاش دوباره'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildPdfReaderContent(
    BuildContext context,
    dynamic bookData, {
    required bool isTrialRead,
  }) {
    final isDark = _isDark(context);
    final isLoggedIn = locator<PrefsOperator>().isLoggedIn();
    final hasBookAccess = isLoggedIn &&
        locator<IknowAccessBloc>().hasBookAccess(bookData.id);
    final canDecrypt = isLoggedIn &&
        BookPdfPlaybackResolver.canDecryptFullBook(
          hasBookAccess: hasBookAccess,
          purchasedFromApi: bookData.purchased ?? false,
          isDemo: bookData.isDemo ?? false,
        );
    final effectiveTrialRead = isTrialRead || !canDecrypt;

    final playbackTarget = BookPdfPlaybackResolver.resolve(
      book: bookData,
      forceTrial: effectiveTrialRead,
      hasBookAccess: hasBookAccess,
    );

    if (playbackTarget == null) {
      return Scaffold(
        backgroundColor:
            isDark ? MyColors.profileBackgroundDark : MyColors.background,
        appBar: _buildAppBar(context, title: bookData.title),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? MyColors.darkError : MyColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'فایل کتاب در دسترس نیست',
                style: MyTextStyle.body16For(context).copyWith(
                  color: isDark ? MyColors.darkError : MyColors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    debugPrint(
      playbackTarget.usePublicUrl
          ? "Using trial file: ${playbackTarget.publicStorageKey} with public URL (no decryption)"
          : "Using full book download for bookId: ${playbackTarget.bookId}, decrypt with fileId: ${playbackTarget.decryptionFileId}",
    );

    return Scaffold(
      backgroundColor:
          isDark ? MyColors.profileBackgroundDark : MyColors.background,
      appBar: _buildAppBar(context, title: bookData.title),
      body: Container(
        decoration: _screenDecoration(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimens.nw(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? MyColors.darkCardBackground
                          : Colors.white,
                      borderRadius: BorderRadius.circular(Dimens.nr(16)),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : Colors.grey)
                              .withValues(alpha: isDark ? 0.35 : 0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.nr(16)),
                      child: CustomPdfReader(
                        fileKey: playbackTarget.publicStorageKey,
                        decryptionFileId: playbackTarget.decryptionFileId,
                        fileName: '${bookData.title}.pdf',
                        fileId: playbackTarget.cacheFileId,
                        bookId: playbackTarget.bookId,
                        storageService: locator<StorageService>(),
                        showDownloadButton: false,
                        autoDownload: true,
                        usePublicUrl: playbackTarget.usePublicUrl,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
