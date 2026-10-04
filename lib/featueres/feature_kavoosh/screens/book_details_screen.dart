import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/services/screen_security_service.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_book_detail_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/utils/kavoosh_book_pdf_playback_resolver.dart';
import 'package:poortak/locator.dart';

class BookDetailsScreen extends StatefulWidget {
  static const String routeName = '/book-detail';
  final String bookId;
  final String? title;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.title,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  final KavooshRepository _repository = locator<KavooshRepository>();
  late TabController _tabController;

  bool _loading = true;
  String? _error;
  KavooshBookDetail? _book;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repository.fetchBookDetail(bookId: widget.bookId);

    if (!mounted) return;

    if (result is DataFailed) {
      setState(() {
        _loading = false;
        _error = result.error ?? 'خطا در دریافت جزئیات کتاب';
      });
      return;
    }

    setState(() {
      _book = (result as DataSuccess<KavooshBookDetail>).data;
      _loading = false;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '—';
    if (bytes >= 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      final text = mb >= 10 ? mb.toStringAsFixed(0) : mb.toStringAsFixed(1);
      return '${toPersianDigits(text)} مگابایت';
    }
    final kb = (bytes / 1024).ceil();
    return '${toPersianDigits('$kb')} کیلوبایت';
  }

  bool get _hasFullAccess {
    final book = _book;
    if (book == null) return false;
    return KavooshBookPdfPlaybackResolver.hasFullBookAccess(
      purchasedFromApi: book.purchased,
      hasAccessFromApi: book.hasAccess,
    );
  }

  bool get _showSampleButton {
    final trialFile = _book?.demoFileId?.trim();
    return trialFile != null && trialFile.isNotEmpty && !_hasFullAccess;
  }

  void _openSample() => _openPdf(forceTrial: true);

  void _openFullBook() => _openPdf(forceTrial: false);

  void _openPdf({required bool forceTrial}) {
    final book = _book;
    if (book == null) return;

    final target = KavooshBookPdfPlaybackResolver.resolve(
      book: book,
      forceTrial: forceTrial,
    );

    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            forceTrial
                ? 'نمونه کتاب در دسترس نیست'
                : 'فایل کتاب در دسترس نیست',
          ),
        ),
      );
      return;
    }

    if (!forceTrial && !target.usePublicUrl && target.decryptionFileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فایل کامل کتاب موجود نیست')),
      );
      return;
    }

    final titlePrefix = target.usePublicUrl ? 'نمونه ' : '';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _KavooshPdfReaderPage(
          title: '$titlePrefix${book.title}',
          fileName: book.title,
          target: target,
          enableScreenSecurity: !target.usePublicUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _book;
    final appBarTitle = book?.category?.title.isNotEmpty == true
        ? 'کتاب ${book!.category!.title}'
        : 'کتاب الکترونیکی';

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : Colors.white,
      appBar: PoortakAppBar(
        title: appBarTitle,
        foregroundColor:
            isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            style: MyTextStyle.textMatn14Bold.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: _load,
                            child: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildContent(isDark, book!),
      ),
    );
  }

  Widget _buildContent(bool isDark, KavooshBookDetail book) {
    final hasFullAccess = _hasFullAccess;
    final showSampleButton = _showSampleButton;
    final title = book.title.isNotEmpty
        ? book.title
        : (widget.title ?? 'جزئیات کتاب');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Dimens.nw(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Dimens.nh(20)),
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
                      child: _buildCover(isDark, book),
                    ),
                  ),
                ),
                SizedBox(height: Dimens.nh(24)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Dimens.nsp(20),
                    fontWeight: FontWeight.bold,
                    color: isDark ? MyColors.darkTextPrimary : MyColors.text2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimens.nh(8)),
                Text(
                  'نسخه الکترونیکی',
                  style: TextStyle(
                    fontSize: Dimens.nsp(14),
                    color:
                        isDark ? MyColors.darkTextSecondary : MyColors.text5,
                  ),
                ),
                if (!hasFullAccess) ...[
                  Divider(
                    height: Dimens.nh(32),
                    color: isDark ? MyColors.darkBorder : MyColors.dividerGray,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قیمت:',
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
                            MoneyUtils.formatTomanFromRial(book.price),
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
                            'تومان',
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
                      Tab(text: 'درباره کالا'),
                      Tab(text: 'ویژگی های کالا'),
                    ],
                  ),
                ),
                SizedBox(height: Dimens.nh(16)),
                SizedBox(
                  height: Dimens.nh(200),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Text(
                          book.description.isNotEmpty
                              ? book.description
                              : 'توضیحاتی موجود نیست.',
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
                      Column(
                        children: [
                          _buildAttributeRow(
                            'ناشر:',
                            book.publisher.isNotEmpty ? book.publisher : '-',
                          ),
                          _buildAttributeRow(
                            'نویسنده:',
                            book.authorName.isNotEmpty ? book.authorName : '-',
                          ),
                          _buildAttributeRow(
                            'فرمت:',
                            book.formatLabel,
                          ),
                          _buildAttributeRow(
                            'حجم:',
                            _formatFileSize(book.size),
                          ),
                          _buildAttributeRow(
                            'تعداد صفحه:',
                            book.pages > 0
                                ? toPersianDigits('${book.pages}')
                                : '-',
                          ),
                          _buildAttributeRow(
                            'تاریخ نشر:',
                            book.publishDate.isNotEmpty
                                ? toPersianDigits(book.publishDate)
                                : '-',
                          ),
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
              if (showSampleButton) ...[
                SizedBox(
                  width: double.infinity,
                  height: Dimens.buttonHeight,
                  child: OutlinedButton(
                    onPressed: _openSample,
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          MyColors.bookSampleButtonBackgroundColor(isDark),
                      foregroundColor:
                          MyColors.bookSampleButtonTextColor(isDark),
                      side: BorderSide(
                        color: MyColors.bookSampleButtonBorderColor(isDark),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimens.radiusMedium),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'خواندن نمونه',
                      style: MyTextStyle.textHeader16Bold.copyWith(
                        color: MyColors.bookSampleButtonTextColor(isDark),
                        fontSize: Dimens.nsp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimens.nh(12)),
              ],
              PrimaryButton(
                width: double.infinity,
                height: Dimens.buttonHeight,
                backgroundColor: MyColors.secondary,
                lable: hasFullAccess ? 'خواندن کتاب' : 'خرید کتاب',
                onPressed: () {
                  if (hasFullAccess) {
                    _openFullBook();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('افزودن به سبد خرید به‌زودی فعال می‌شود'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCover(bool isDark, KavooshBookDetail book) {
    final placeholder = Container(
      color: isDark ? MyColors.darkBackgroundSecondary : Colors.grey[200],
      child: Icon(Icons.book, size: 50.r, color: Colors.grey),
    );

    if (book.thumbnailId == null) return placeholder;

    return FutureBuilder<String>(
      future: GetImageUrlService().getImageUrl(book.thumbnailId!),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return placeholder;
        }
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        );
      },
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
}

class _KavooshPdfReaderPage extends StatefulWidget {
  final String title;
  final String fileName;
  final KavooshBookPdfPlaybackTarget target;
  final bool enableScreenSecurity;

  const _KavooshPdfReaderPage({
    required this.title,
    required this.fileName,
    required this.target,
    required this.enableScreenSecurity,
  });

  @override
  State<_KavooshPdfReaderPage> createState() => _KavooshPdfReaderPageState();
}

class _KavooshPdfReaderPageState extends State<_KavooshPdfReaderPage> {
  @override
  void initState() {
    super.initState();
    if (widget.enableScreenSecurity) {
      ScreenSecurityService.setEnabled(true);
    }
  }

  @override
  void dispose() {
    if (widget.enableScreenSecurity) {
      ScreenSecurityService.setEnabled(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = widget.target;

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background1,
      appBar: PoortakAppBar(
        title: widget.title,
        foregroundColor:
            isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
      ),
      body: CustomPdfReader(
        fileName: widget.fileName,
        fileId: target.cacheFileId,
        bookId: target.bookId,
        fileKey: target.publicStorageKey,
        decryptionFileId: target.decryptionFileId,
        usePublicUrl: target.usePublicUrl,
        autoDownload: true,
        showDownloadButton: false,
        downloadSource: ContentDownloadSource.kavoosh,
        storageService: locator<StorageService>(),
      ),
    );
  }
}
