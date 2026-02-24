import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'custom_video_player.dart';

class VideoContainerWidget extends StatelessWidget {
  final String? videoPath;
  final String? videoUrl;
  final String? thumbnailUrl;
  final bool isCheckingFiles;
  final bool isDownloading;
  final bool isDecrypting;
  final GlobalKey<CustomVideoPlayerState> videoPlayerKey;
  final bool hasAccess;
  final VoidCallback onVideoEnded;
  final Function()? onShowPurchaseDialog;

  const VideoContainerWidget({
    super.key,
    required this.videoPath,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.isCheckingFiles,
    required this.isDownloading,
    required this.isDecrypting,
    required this.videoPlayerKey,
    required this.hasAccess,
    required this.onVideoEnded,
    this.onShowPurchaseDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37.r),
        child: SizedBox(
          width: 350.w,
          height: 240.h,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isCheckingFiles || isDownloading || isDecrypting) {
      return _buildLoadingState(context);
    }

    if (videoPath == null && videoUrl == null) {
      return _buildErrorState(context);
    }

    return CustomVideoPlayer(
      key: videoPlayerKey,
      videoPath: videoPath ?? videoUrl!,
      isNetworkVideo: videoPath == null && videoUrl != null,
      width: 350.w,
      height: 240.h,
      borderRadius: 37.r,
      autoPlay: false,
      showControls: true,
      thumbnailUrl: thumbnailUrl,
      onVideoEnded: () {
        print('Video ended');
        // If user hasn't purchased and this was a trailer video, show purchase dialog
        if (!hasAccess && onShowPurchaseDialog != null) {
          onShowPurchaseDialog!();
        }
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: MyColors.brandSecondary,
            borderRadius: BorderRadius.circular(37.r),
          ),
        ),
        if (thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(37.r),
            child: Image.network(
              thumbnailUrl!,
              width: 350.w,
              height: 240.h,
              fit: BoxFit.cover,
            ),
          ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (thumbnailUrl == null)
                CircularProgressIndicator(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              SizedBox(height: 16.h),
              Text(
                isDecrypting
                    ? 'در حال رمزگشایی ویدیو...'
                    : isDownloading
                        ? 'در حال دانلود ویدیو...'
                        : 'در حال پردازش ویدیو...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 16.sp,
                  fontFamily: 'IranSans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.brandSecondary,
        borderRadius: BorderRadius.circular(37.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).textTheme.titleMedium?.color,
              size: 48.r,
            ),
            SizedBox(height: 16.h),
            Text(
              'خطا در بارگذاری ویدیو',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
