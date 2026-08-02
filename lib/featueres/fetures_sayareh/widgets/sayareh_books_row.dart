import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/book_list_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/book_detail_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/pdf_reader_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/utils/book_pdf_playback_resolver.dart';
import 'package:poortak/locator.dart';

class SayarehBooksRow extends StatelessWidget {
  final List<BookList> books;

  const SayarehBooksRow({
    super.key,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'هیچ کتابی یافت نشد',
            style: MyTextStyle.body14SecondaryFor(context),
          ),
        ),
      );
    }

    return SizedBox(
      height: 168.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: books.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return _BookCard(book: books[index]);
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookList book;

  const _BookCard({required this.book});

  void _handleTap(BuildContext context) {
    final bookId = book.id;
    if (bookId.isEmpty) return;

    final isLoggedIn = locator<PrefsOperator>().isLoggedIn();
    final hasBookAccess =
        isLoggedIn && locator<IknowAccessBloc>().hasBookAccess(bookId);
    final canOpen = BookPdfPlaybackResolver.canOpenReaderDirectly(
      purchasedFromApi: book.purchased,
      hasBookAccess: hasBookAccess,
    );
    final canDecrypt = BookPdfPlaybackResolver.canDecryptFullBook(
      hasBookAccess: hasBookAccess,
      purchasedFromApi: book.purchased,
      isDemo: book.isDemo,
    );

    if (isLoggedIn && canOpen) {
      Navigator.pushNamed(
        context,
        PdfReaderScreen.routeName,
        arguments: {
          'bookId': bookId,
          'isTrialRead': !canDecrypt,
        },
      );
      return;
    }

    Navigator.pushNamed(
      context,
      BookDetailScreen.routeName,
      arguments: {'bookId': bookId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 148.w,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isDark ? MyColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: SizedBox.expand(
                        child: FutureBuilder<String>(
                          future:
                              GetImageUrlService().getImageUrl(book.thumbnail),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return ColoredBox(
                                color: isDark
                                    ? MyColors.darkBackgroundSecondary
                                    : MyColors.background3,
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: MyColors.sayarehHomePurple,
                                  size: 28.r,
                                ),
                              );
                            }
                            return Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: MyColors.background3,
                                child: Icon(Icons.broken_image_outlined,
                                    size: 24.r),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: MyColors.sayarehHomePurple,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                book.title,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
                ),
              ),
              if (book.description != null &&
                  book.description!.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  book.description!,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MyTextStyle.description10Medium.copyWith(
                    color: isDark
                        ? MyColors.darkTextSecondary
                        : MyColors.text6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
