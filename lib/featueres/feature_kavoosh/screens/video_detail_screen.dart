import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/video_course_detail_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/session_item.dart';
import 'package:poortak/locator.dart';

class VideoDetailScreen extends StatefulWidget {
  static const String routeName = '/video-detail';
  final String courseId;
  final String? title;

  const VideoDetailScreen({
    super.key,
    required this.courseId,
    this.title,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final KavooshRepository _repository = locator<KavooshRepository>();

  bool _isDescriptionExpanded = false;
  bool _loading = true;
  String? _error;
  VideoCourseDetailResponse? _detail;
  String? _playingLessonId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repository.fetchVideoCourseDetail(
      courseId: widget.courseId,
    );

    if (!mounted) return;

    if (result is DataFailed) {
      setState(() {
        _loading = false;
        _error = result.error ?? 'خطا در دریافت جزئیات دوره';
      });
      return;
    }

    setState(() {
      _detail = (result as DataSuccess<VideoCourseDetailResponse>).data;
      _loading = false;
    });
  }

  String _formatDurationMinutes(int minutes) {
    if (minutes <= 0) return '—';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${toPersianDigits('$hours')} ساعت و ${toPersianDigits('$mins')} دقیقه';
    }
    if (hours > 0) {
      return '${toPersianDigits('$hours')} ساعت';
    }
    return '${toPersianDigits('$mins')} دقیقه';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final course = _detail?.course;
    final title = course?.title ?? widget.title ?? 'جزئیات دوره';
    final priceLabel = course == null
        ? ''
        : '${MoneyUtils.formatTomanFromRial(course.price)} تومان';

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background1,
      appBar: PoortakAppBar(
        title: title,
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
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildHero(isDark, course),
                      SizedBox(height: 16.h),
                      _buildInfoCard(isDark, course, priceLabel),
                      SizedBox(height: 16.h),
                      _buildLessonsCard(isDark),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _detail == null
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('افزودن به سبد خرید به‌زودی فعال می‌شود'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? MyColors.primary : MyColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: isDark ? 0 : 4,
                  ),
                  child: Text(
                    'اضافه به سبد خرید',
                    style: MyTextStyle.textHeader16Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHero(bool isDark, VideoCourseInfo? course) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
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
      clipBehavior: Clip.antiAlias,
      child: course?.thumbnailId == null
          ? _buildHeroPlaceholder(isDark)
          : FutureBuilder<String>(
              future: GetImageUrlService().getImageUrl(course!.thumbnailId!),
              builder: (context, snapshot) {
                final url = snapshot.data;
                if (url == null || url.isEmpty) {
                  return _buildHeroPlaceholder(isDark);
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildHeroPlaceholder(isDark),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 56.r,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHeroPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: isDark
                ? MyColors.darkBackgroundSecondary
                : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Icon(
            Icons.movie_creation_outlined,
            color: isDark ? MyColors.secondary : const Color(0xFF2196F3),
            size: 30.r,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'برای تماشای ویدئو روی بخش مورد نظر\nکلیک کنید.',
          textAlign: TextAlign.center,
          style: MyTextStyle.textMatn14Bold.copyWith(
            color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
            fontWeight: FontWeight.normal,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    VideoCourseInfo? course,
    String priceLabel,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: course?.thumbnailId == null
                      ? ColoredBox(
                          color: isDark
                              ? MyColors.darkBackgroundSecondary
                              : Colors.grey[200]!,
                        )
                      : FutureBuilder<String>(
                          future: GetImageUrlService()
                              .getImageUrl(course!.thumbnailId!),
                          builder: (context, snapshot) {
                            final url = snapshot.data;
                            if (url == null || url.isEmpty) {
                              return ColoredBox(
                                color: isDark
                                    ? MyColors.darkBackgroundSecondary
                                    : Colors.grey[200]!,
                              );
                            }
                            return Image.network(url, fit: BoxFit.cover);
                          },
                        ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.title ?? '',
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        color: isDark
                            ? MyColors.darkTextPrimary
                            : MyColors.textMatn2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'قیمت دوره:',
                            style: MyTextStyle.textMatn12W500.copyWith(
                              color: isDark
                                  ? MyColors.darkTextSecondary
                                  : MyColors.text4,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            priceLabel,
                            style: MyTextStyle.textMatn12Bold.copyWith(
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
                  ],
                ),
              ),
            ],
          ),
          if (_isDescriptionExpanded) ...[
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'درباره دوره:',
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                (course?.description.isNotEmpty ?? false)
                    ? course!.description
                    : 'توضیحی ثبت نشده است.',
                style: MyTextStyle.textMatn12W500.copyWith(
                  color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
                  height: 1.6,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.darkBackgroundSecondary
                    : MyColors.background1,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مدت زمان کل این دوره:',
                    style: MyTextStyle.textMatn12W500.copyWith(
                      color:
                          isDark ? MyColors.darkTextSecondary : MyColors.text4,
                    ),
                  ),
                  Text(
                    _formatDurationMinutes(course?.totalDuration ?? 0),
                    style: MyTextStyle.textMatn12Bold.copyWith(
                      color: isDark
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn2,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isDescriptionExpanded ? 'بستن اطلاعات' : 'اطلاعات دوره',
                  style: MyTextStyle.textMatn12Bold.copyWith(
                    color: MyColors.primary,
                  ),
                ),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_left,
                  color: MyColors.primary,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsCard(bool isDark) {
    final lessons = _detail?.lessons ?? const [];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
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
      child: lessons.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'جلسه‌ای برای این دوره ثبت نشده است',
                style: MyTextStyle.textMatn12W500.copyWith(
                  color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: lessons.map((lesson) {
                final locked = !lesson.isFree;
                return SessionItem(
                  title: lesson.title,
                  isLocked: locked,
                  isPlaying: _playingLessonId == lesson.id,
                  onTap: () {
                    if (locked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('این جلسه پس از خرید دوره در دسترس است'),
                        ),
                      );
                      return;
                    }
                    setState(() => _playingLessonId = lesson.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(lesson.title)),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
