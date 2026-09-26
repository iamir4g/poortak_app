import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/widgets/custom_pdfReader.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_book_detail_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
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
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
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

  void _openSample() {
    final demoFileId = _book?.demoFileId;
    if (demoFileId == null || demoFileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نمونه کتاب در دسترس نیست')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: MyColors.background1,
          appBar: PoortakAppBar(
            title: 'نمونه ${_book?.title ?? ''}',
            foregroundColor: MyColors.textMatn2,
          ),
          body: CustomPdfReader(
            fileName: _book?.title ?? 'book',
            fileId: demoFileId,
            fileKey: demoFileId,
            usePublicUrl: true,
            showDownloadButton: false,
            storageService: locator<StorageService>(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final book = _book;
    final title = book?.title ?? widget.title ?? 'جزئیات کتاب';
    final appBarTitle = book?.category?.title.isNotEmpty == true
        ? 'کتاب ${book!.category!.title}'
        : 'کتاب الکترونیکی';
    final priceLabel = book == null
        ? ''
        : '${MoneyUtils.formatTomanFromRial(book.price)} تومان';

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background1,
      appBar: PoortakAppBar(
        title: appBarTitle,
        foregroundColor:
            isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
      ),
      body: _loading
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 200.w,
                              height: 280.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20.r,
                                    offset: Offset(0, 10.h),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: _buildCover(isDark, book),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                title,
                                style: MyTextStyle.textMatn18Bold.copyWith(
                                  fontSize: 20.sp,
                                  color: isDark
                                      ? MyColors.darkTextPrimary
                                      : MyColors.textMatn2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'نسخه الکترونیکی',
                              style: MyTextStyle.textMatn14Bold.copyWith(
                                color: isDark
                                    ? MyColors.darkTextSecondary
                                    : MyColors.text4,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'قیمت:',
                                    style:
                                        MyTextStyle.textHeader16Bold.copyWith(
                                      color: isDark
                                          ? MyColors.darkTextPrimary
                                          : MyColors.textMatn2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      priceLabel,
                                      style: MyTextStyle.textHeader16Bold
                                          .copyWith(
                                        color: isDark
                                            ? MyColors.darkTextPrimary
                                            : MyColors.textMatn2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? MyColors.darkBorder
                                  : MyColors.divider,
                              width: 1.h,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: MyColors.primary,
                          unselectedLabelColor: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.text4,
                          indicatorColor: MyColors.primary,
                          indicatorWeight: 3.h,
                          labelStyle: MyTextStyle.textMatn14Bold,
                          tabs: const [
                            Tab(text: 'درباره کالا'),
                            Tab(text: 'ویژگی های کالا'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.r),
                        child: _tabController.index == 0
                            ? Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  (book?.description.isNotEmpty ?? false)
                                      ? book!.description
                                      : 'توضیحی ثبت نشده است.',
                                  style: MyTextStyle.textMatn14Bold.copyWith(
                                    fontWeight: FontWeight.normal,
                                    height: 1.7,
                                    color: isDark
                                        ? MyColors.darkTextSecondary
                                        : MyColors.text3,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              )
                            : Column(
                                children: [
                                  _buildDetailRow(
                                    'ناشر:',
                                    book?.publisher.isNotEmpty == true
                                        ? book!.publisher
                                        : '—',
                                  ),
                                  _buildDetailRow(
                                    'نویسنده:',
                                    book?.authorName.isNotEmpty == true
                                        ? book!.authorName
                                        : '—',
                                  ),
                                  _buildDetailRow(
                                    'فرمت:',
                                    book?.formatLabel ?? '—',
                                  ),
                                  _buildDetailRow(
                                    'حجم:',
                                    _formatFileSize(book?.size ?? 0),
                                  ),
                                  _buildDetailRow(
                                    'تعداد صفحه:',
                                    (book?.pages ?? 0) > 0
                                        ? '${toPersianDigits('${book!.pages}')} صفحه'
                                        : '—',
                                  ),
                                  _buildDetailRow(
                                    'تاریخ نشر:',
                                    book?.publishDate.isNotEmpty == true
                                        ? toPersianDigits(book!.publishDate)
                                        : '—',
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: OutlinedButton(
                                onPressed: _openSample,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDark
                                        ? MyColors.darkBorder
                                        : MyColors.text4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'خواندن نمونه',
                                  style: MyTextStyle.textHeader16Bold.copyWith(
                                    color: isDark
                                        ? MyColors.darkTextSecondary
                                        : MyColors.text4,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'افزودن به سبد خرید به‌زودی فعال می‌شود',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? MyColors.primary
                                      : MyColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'افزودن به سبد خرید',
                                  style:
                                      MyTextStyle.textHeader16Bold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCover(bool isDark, KavooshBookDetail? book) {
    final placeholder = Container(
      color: isDark ? MyColors.darkBackgroundSecondary : Colors.grey[200],
      child: Icon(Icons.book, size: 80.r, color: Colors.grey),
    );

    if (book?.thumbnailId == null) return placeholder;

    return FutureBuilder<String>(
      future: GetImageUrlService().getImageUrl(book!.thumbnailId!),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null || url.isEmpty) return placeholder;
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              value,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: isDark ? MyColors.darkTextPrimary : MyColors.text3,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
