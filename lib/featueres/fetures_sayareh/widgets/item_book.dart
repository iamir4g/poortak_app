import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
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
          width: 360.w,
          height: 100.h,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        description!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 81.w,
                  height: 81.h,
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
                        width: 81.w,
                        height: 81.h,
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
              // const SizedBox(width: 8),
              // Icon(
              //   Icons.arrow_forward_ios,
              //   color: Theme.of(context).textTheme.bodySmall?.color,
              // ),
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
