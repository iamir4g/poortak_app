import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/iknow_summary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';

class SayarehEpisodeCard extends StatelessWidget {
  final Lesson item;
  final int index;
  final bool purchased;
  final CourseProgressItem? progress;
  final IKnowSummaryModel? summaryData;

  const SayarehEpisodeCard({
    super.key,
    required this.item,
    required this.index,
    required this.purchased,
    this.progress,
    this.summaryData,
  });

  bool get _isFirstLesson => index == 0;

  bool get _isLocked => _isFirstLesson
      ? false
      : !purchased && !item.isDemo && item.trailerVideo.isEmpty;

  double get _average {
    if (progress == null) return 0;
    return (progress!.vocabulary + progress!.conversation + progress!.quiz) / 3;
  }

  void _onTap(BuildContext context) {
    if (_isFirstLesson) {
      Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
        'index': index,
        'title': item.name,
        'lessonId': item.id,
        'purchased': purchased,
      });
      return;
    }

    final canPreviewTrailer = item.trailerVideo.isNotEmpty;
    if (item.isDemo || purchased || canPreviewTrailer) {
      Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
        'index': index,
        'title': item.name,
        'lessonId': item.id,
        'purchased': purchased,
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => DialogCart(item: item, summaryData: summaryData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final average = _average;
    final isActive = !_isLocked && average > 0 && average < 100;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Opacity(
        opacity: _isLocked ? 0.72 : 1,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(12.r),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.name,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: isDark
                            ? MyColors.darkTextPrimary
                            : MyColors.text1,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    if (_isLocked)
                      Text(
                        'با تکمیل قسمت قبلی باز می‌شود',
                        textAlign: TextAlign.right,
                        style: MyTextStyle.description10Medium.copyWith(
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.text5,
                        ),
                      )
                    else ...[
                      if (isActive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: MyColors.sayarehHomeEpisodeActiveBadge
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'در حال مشاهده',
                            style: MyTextStyle.textMatn10W300.copyWith(
                              color: MyColors.sayarehHomeEpisodeActiveBadge,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (progress != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              '${average.toInt()}%',
                              textDirection: TextDirection.ltr,
                              style: MyTextStyle.textProgressBar.copyWith(
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: (average / 100).clamp(0.0, 1.0),
                                  minHeight: 6.h,
                                  backgroundColor:
                                      MyColors.progressBarBackground,
                                  color: MyColors.progressBarColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          item.description,
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
              SizedBox(width: 12.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: SizedBox(
                      width: 88.w,
                      height: 64.h,
                      child: FutureBuilder<String>(
                        future: GetImageUrlService()
                            .getImageUrl(item.videoThumbnailOrThumbnail),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return ColoredBox(
                              color: isDark
                                  ? MyColors.darkBackgroundSecondary
                                  : MyColors.background3,
                              child: Icon(
                                Icons.play_circle_outline_rounded,
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
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 24.r,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_isLocked)
                    Container(
                      width: 88.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: buildImageFromAssetOrEmbeddedSvg(
                          'assets/images/lock_image.svg',
                          width: 22.r,
                          height: 22.r,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28.r,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
