import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/book_detail_screen.dart';

class ItemBook extends StatelessWidget {
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? fileKey;
  final String? trialFile;
  final bool purchased;
  final String? price;
  final String? bookId;
  const ItemBook({
    super.key,
    this.title,
    this.description,
    this.thumbnail,
    this.fileKey,
    this.trialFile,
    this.purchased = false,
    this.price,
    this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          if (bookId != null && bookId!.isNotEmpty) {
            _navigateToPdfReader(context);
          }
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: MyColors.background, //Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1.r,
                blurRadius: 3.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title ?? 'بدون عنوان',
                      style: MyTextStyle.textMatn17W700.copyWith(
                        color: MyColors.text2,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        description!,
                        style: MyTextStyle.text10MediumText6,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: FutureBuilder<String>(
                    future: GetImageUrlService().getImageUrl(thumbnail ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Icon(Icons.error),
                        );
                      }
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPdfReader(BuildContext context) {
    if (bookId == null || bookId!.isEmpty) return;

    // Navigate to BookDetailScreen with book ID
    Navigator.pushNamed(
      context,
      BookDetailScreen.routeName,
      arguments: {
        'bookId': bookId!,
      },
    );
  }
}
