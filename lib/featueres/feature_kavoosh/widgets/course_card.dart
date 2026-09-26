import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final String? thumbnailId;
  final Color? backgroundColor;
  final bool showPlayBadge;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.title,
    this.imagePath,
    this.thumbnailId,
    this.backgroundColor,
    this.showPlayBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        margin: EdgeInsetsDirectional.only(end: Dimens.medium),
        constraints: BoxConstraints(minHeight: 180.h),
        decoration: BoxDecoration(
          color: isDark
              ? MyColors.termsBackgroundDark
              : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: isDark ? Border.all(color: MyColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? MyColors.darkBackgroundSecondary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(20.r)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.r)),
                        child: _buildImage(isDark),
                      ),
                    ),
                  ),
                  if (showPlayBadge)
                    PositionedDirectional(
                      bottom: 8.h,
                      end: 8.w,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 18.r,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Text(
                title,
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color:
                      isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final placeholder = Center(
      child: Icon(
        Icons.image,
        color: isDark ? MyColors.darkTextSecondary : Colors.grey,
        size: 40.r,
      ),
    );

    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.asset(imagePath!, fit: BoxFit.cover);
    }

    if (thumbnailId != null && thumbnailId!.isNotEmpty) {
      return FutureBuilder<String>(
        future: GetImageUrlService().getImageUrl(thumbnailId!),
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

    return placeholder;
  }
}
