import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SelfAssessmentSubjectCard extends StatelessWidget {
  final String title;
  final String? iconPath;
  final String? thumbnailId;
  final Color backgroundColor;
  final VoidCallback onTap;

  const SelfAssessmentSubjectCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onTap,
    this.iconPath,
    this.thumbnailId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : backgroundColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.darkBackgroundSecondary.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 80.r,
                height: 80.r,
                child: _buildIcon(),
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                title,
                style: MyTextStyle.textMatn14Bold.copyWith(
                  color: isDark ? MyColors.darkTextPrimary : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final fallback = Icon(
      Icons.quiz_outlined,
      size: 80.r,
      color: MyColors.primary,
    );

    if (thumbnailId != null && thumbnailId!.isNotEmpty) {
      return FutureBuilder<String>(
        future: GetImageUrlService().getImageUrl(thumbnailId!),
        builder: (context, snapshot) {
          final url = snapshot.data;
          if (url == null || url.isEmpty) {
            return _assetOrFallback(fallback);
          }
          return Image.network(
            url,
            width: 80.r,
            height: 80.r,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _assetOrFallback(fallback),
          );
        },
      );
    }

    return _assetOrFallback(fallback);
  }

  Widget _assetOrFallback(Widget fallback) {
    if (iconPath != null && iconPath!.isNotEmpty) {
      return Image.asset(
        iconPath!,
        width: 50.r,
        height: 50.r,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}
