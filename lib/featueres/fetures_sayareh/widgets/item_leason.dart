import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/common/widgets/global_progress_bar.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/iknow_summary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';

class ItemLeason extends StatelessWidget {
  final Lesson item;
  final int index;
  final bool purchased;
  final Function() onTap;
  final CourseProgressItem? progress;
  final IKnowSummaryModel? summaryData;

  const ItemLeason({
    super.key,
    required this.item,
    required this.onTap,
    required this.purchased,
    required this.index,
    this.progress,
    this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = !purchased && !item.isDemo;

    double average = 0;
    if (progress != null) {
      average =
          (progress!.vocabulary + progress!.conversation + progress!.quiz) / 3;
    }

    return GestureDetector(
      onTap: () {
        // If isDemo is true OR user has access, go directly to lesson screen
        if (item.isDemo || purchased) {
          Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
            'index': index,
            'title': item.name,
            'lessonId': item.id,
            'purchased': purchased,
          });
        } else {
          // If isDemo is false AND user doesn't have access, show add to cart modal
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                DialogCart(item: item, summaryData: summaryData),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: Dimens.medium),
        height: Dimens.nh(104.0),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : MyColors.background,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(children: [
                SizedBox(
                  width: 67.r,
                  height: 67.r,
                  child: ClipOval(
                    child: FutureBuilder<String>(
                      future: GetImageUrlService().getImageUrl(item.thumbnail),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Icon(Icons.error);
                        }
                        return Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: MyTextStyle.textMatn17W700.copyWith(
                          color:
                              isDark ? const Color(0xFFFFFFFF) : MyColors.text2,
                          height: 1.0,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.description,
                        style: MyTextStyle.description10Medium.copyWith(
                          color: isDark
                              ? MyColors.loginTextSecondaryDark
                              : MyColors.text6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ]),
            ),
            Row(
              children: [
                if (progress != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: average >= 100
                        ? Row(
                            children: List.generate(
                                3,
                                (index) => Icon(Icons.star,
                                    color: Colors.amber, size: 20.r)))
                        : GlobalProgressBar(
                            percentage: average, width: 60.w, height: 8.h),
                  ),
                isLocked
                    ? SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: buildImageFromAssetOrEmbeddedSvg(
                          "assets/images/lock_image.svg",
                          width: 24.r,
                          height: 24.r,
                          fit: BoxFit.contain,
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: 4.w,
                ),
                SvgPicture.asset(
                  'assets/images/icons/iconamoon--arrow-left-2-duotone.svg',
                  width: 32.r,
                  height: 32.r,
                  colorFilter: ColorFilter.mode(
                    isDark
                        ? const Color(0xFFFFFFFF)
                        : Theme.of(context).textTheme.titleMedium?.color ??
                            Theme.of(context).iconTheme.color ??
                            Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
