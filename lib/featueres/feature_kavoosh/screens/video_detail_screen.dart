import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/video_download_service.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/video_course_detail_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/utils/kavoosh_video_playback_resolver.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/session_item.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/video_container_widget.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/video_progress_bar_widget.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
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
  final VideoDownloadService _downloadService = locator<VideoDownloadService>();
  final VideoDownloadCubit _downloadCubit = locator<VideoDownloadCubit>();
  final GlobalKey<CustomVideoPlayerState> _videoPlayerKey =
      GlobalKey<CustomVideoPlayerState>();

  StreamSubscription<VideoDownloadState>? _downloadSubscription;

  bool _isDescriptionExpanded = false;
  bool _loading = true;
  String? _error;
  VideoCourseDetailResponse? _detail;
  String? _playingLessonId;
  String? _currentVideoName;
  String? _localVideoPath;
  String? _thumbnailUrl;
  bool _isCheckingFiles = false;
  bool _isDownloading = false;
  bool _isDecrypting = false;
  double _downloadProgress = 0.0;
  double _decryptionProgress = 0.0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _downloadSubscription = _downloadCubit.stream.listen((state) {
      if (_isDisposed || !mounted || _currentVideoName == null) return;
      if (state is! VideoDownloadLoaded) return;
      final info = state.downloads[_currentVideoName];
      if (info != null) {
        _updateLocalStateFromCubit(info);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _downloadSubscription?.cancel();
    _videoPlayerKey.currentState?.stopVideo();
    super.dispose();
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

  bool _hasCourseAccess(VideoCourseInfo course) {
    return KavooshVideoPlaybackResolver.hasFullCourseAccess(
      purchasedFromApi: course.purchased,
      hasAccessFromApi: course.hasAccess,
    );
  }

  Future<void> _addItemToCart(VideoCourseInfo course) async {
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = prefsOperator.isLoggedIn();
    final type = CartType.VideoCourse.name;
    final itemId = course.id;
    final itemName = course.title;

    if (isLoggedIn) {
      try {
        final apiProvider = locator<ShoppingCartApiProvider>();
        await apiProvider.addToCart(CartType.VideoCourse, itemId);

        if (!mounted) return;
        context.read<ShoppingCartBloc>().add(GetCartEvent());
        _showSuccessModal(itemName);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_extractErrorMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));
      _showSuccessModal(itemName);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) return data['message'];
        if (data is Map && data.containsKey('error')) return data['error'];
        if (data is String) return data;
      }
      return error.message ?? 'خطا در افزودن به سبد خرید';
    }
    return error.toString();
  }

  void _showSuccessModal(String itemName) {
    ReusableModal.showSuccess(
      context: context,
      title: 'اضافه به سبد خرید',
      message: '($itemName) به سبد خرید شما اضافه شد',
      buttonText: 'مشاهده سبد خرید',
      secondButtonText: 'بستن',
      showSecondButton: true,
      cartSuccessStyle: true,
      onButtonPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
          MainWrapper.routeName,
          (route) => false,
          arguments: {'initialIndex': 2},
        );
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _onLessonTap(VideoCourseLesson lesson) async {
    final detail = _detail;
    if (detail == null) return;

    final canPlay = KavooshVideoPlaybackResolver.canPlayLesson(
      lesson: lesson,
      course: detail.course,
    );

    if (!canPlay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('این جلسه پس از خرید دوره در دسترس است'),
        ),
      );
      return;
    }

    final target = KavooshVideoPlaybackResolver.resolve(
      lesson: lesson,
      course: detail.course,
    );

    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فایل ویدئو برای این جلسه موجود نیست')),
      );
      return;
    }

    setState(() => _playingLessonId = lesson.id);
    await _prepareLessonPlayback(lesson: lesson, target: target);
  }

  Future<void> _prepareLessonPlayback({
    required VideoCourseLesson lesson,
    required KavooshVideoPlaybackTarget target,
    bool autoStart = false,
  }) async {
    final videoId = target.videoId;

    if (_currentVideoName != videoId) {
      _videoPlayerKey.currentState?.stopVideo();
      if (!_isDisposed && mounted) {
        setState(() {
          _localVideoPath = null;
          _isCheckingFiles = true;
          _isDownloading = false;
          _isDecrypting = false;
          _downloadProgress = 0.0;
          _decryptionProgress = 0.0;
          _thumbnailUrl = null;
        });
      }
      _currentVideoName = videoId;
      await _loadLessonThumbnail(lesson.thumbnailId);
    }

    final hasPaidAccess =
        !target.usePublicUrl && _hasCourseAccess(_detail!.course);

    await _downloadService.checkAndDownloadVideo(
      videoName: videoId,
      lessonId: target.lessonId,
      courseId: target.courseId,
      downloadSource: ContentDownloadSource.kavoosh,
      hasAccess: hasPaidAccess,
      isEncrypted: target.isEncrypted,
      usePublicUrl: target.usePublicUrl,
      videoKey: videoId,
      autoStart: autoStart,
    );
  }

  Future<void> _loadLessonThumbnail(String? thumbnailId) async {
    if (thumbnailId == null || thumbnailId.isEmpty) {
      if (mounted) setState(() => _thumbnailUrl = null);
      return;
    }
    try {
      final url = await GetImageUrlService().getImageUrl(thumbnailId);
      if (!_isDisposed && mounted) {
        setState(() => _thumbnailUrl = url.isEmpty ? null : url);
      }
    } catch (_) {
      if (!_isDisposed && mounted) {
        setState(() => _thumbnailUrl = null);
      }
    }
  }

  void _updateLocalStateFromCubit(VideoDownloadInfo downloadInfo) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isCheckingFiles = downloadInfo.isCheckingFiles;
      _isDownloading = downloadInfo.isDownloading;
      _downloadProgress = downloadInfo.downloadProgress;
      _isDecrypting = downloadInfo.isDecrypting;
      _decryptionProgress = downloadInfo.decryptionProgress;
      if (downloadInfo.localPath != null) {
        _localVideoPath = downloadInfo.localPath;
      }
    });

    if (downloadInfo.status == DownloadStatus.error &&
        downloadInfo.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(downloadInfo.error!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startDownload() {
    final detail = _detail;
    final lessonId = _playingLessonId;
    if (detail == null || lessonId == null) return;

    VideoCourseLesson? lesson;
    for (final item in detail.lessons) {
      if (item.id == lessonId) {
        lesson = item;
        break;
      }
    }
    if (lesson == null) return;

    final target = KavooshVideoPlaybackResolver.resolve(
      lesson: lesson,
      course: detail.course,
    );
    if (target == null) return;

    _prepareLessonPlayback(
      lesson: lesson,
      target: target,
      autoStart: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final course = _detail?.course;
    final title = course?.title ?? widget.title ?? 'جزئیات دوره';
    final priceLabel = course == null
        ? ''
        : '${MoneyUtils.formatTomanFromRial(course.price)} تومان';
    final showCartFab = course == null || !_hasCourseAccess(course);

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background1,
      appBar: PoortakAppBar(
        title: title,
        foregroundColor: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
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
                      _buildPlayerSection(isDark, course),
                      SizedBox(height: 16.h),
                      _buildInfoCard(isDark, course, priceLabel),
                      SizedBox(height: 16.h),
                      _buildLessonsCard(isDark),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !showCartFab
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    final course = _detail?.course;
                    if (course == null) return;
                    _addItemToCart(course);
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

  Widget _buildPlayerSection(bool isDark, VideoCourseInfo? course) {
    if (_playingLessonId == null) {
      return _buildEmptyPlayerPlaceholder(isDark);
    }

    return BlocBuilder<VideoDownloadCubit, VideoDownloadState>(
      bloc: _downloadCubit,
      builder: (context, state) {
        VideoDownloadInfo? downloadInfo;
        if (_currentVideoName != null && state is VideoDownloadLoaded) {
          downloadInfo = state.downloads[_currentVideoName];
        }

        final currentIsCheckingFiles =
            downloadInfo?.isCheckingFiles ?? _isCheckingFiles;
        final currentIsDownloading =
            downloadInfo?.isDownloading ?? _isDownloading;
        final currentDownloadProgress =
            downloadInfo?.downloadProgress ?? _downloadProgress;
        final currentIsDecrypting = downloadInfo?.isDecrypting ?? _isDecrypting;
        final currentDecryptionProgress =
            downloadInfo?.decryptionProgress ?? _decryptionProgress;
        final currentLocalPath = downloadInfo?.localPath ?? _localVideoPath;
        final hasAccess = course == null ? false : _hasCourseAccess(course);

        return Center(
          child: Column(
            children: [
              VideoContainerWidget(
                videoPath: currentLocalPath,
                videoUrl: null,
                thumbnailUrl: _thumbnailUrl,
                isCheckingFiles: currentIsCheckingFiles,
                isDownloading: currentIsDownloading,
                isDecrypting: currentIsDecrypting,
                videoPlayerKey: _videoPlayerKey,
                hasAccess: hasAccess,
                onVideoEnded: () {},
                onDownload: _startDownload,
              ),
              VideoProgressBarWidget(
                isVisible: currentIsDownloading,
                progress: currentDownloadProgress,
                label: 'در حال دانلود...',
              ),
              DecryptionProgressBarWidget(
                isVisible: currentIsDecrypting,
                progress: currentDecryptionProgress,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyPlayerPlaceholder(bool isDark) {
    return Container(
      height: 230.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : MyColors.background,
        borderRadius: BorderRadius.circular(20.r),
        border: isDark ? Border.all(color: MyColors.darkBorder) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/kavoosh/video_not_selected.png',
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'برای تماشای ویدیو روی بخش مورد نظر کلیک کنید.',
              textAlign: TextAlign.center,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
    final detail = _detail;
    final lessons = detail?.lessons ?? const [];

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
                final locked = detail == null
                    ? !lesson.isFree
                    : !KavooshVideoPlaybackResolver.canPlayLesson(
                        lesson: lesson,
                        course: detail.course,
                      );
                return SessionItem(
                  title: lesson.title,
                  isLocked: locked,
                  isPlaying: _playingLessonId == lesson.id,
                  onTap: () => _onLessonTap(lesson),
                );
              }).toList(),
            ),
    );
  }
}
