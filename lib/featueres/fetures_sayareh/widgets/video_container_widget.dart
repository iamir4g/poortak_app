import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/dimens.dart';
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
      width: Dimens.nw(320), // Reduced from 360
      padding: EdgeInsets.all(Dimens.nr(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.nr(30)), // Reduced from 40
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.nr(27)), // Reduced from 37
        child: SizedBox(
          width: Dimens.nw(310), // Reduced from 350
          height: Dimens.nh(200), // Reduced from 240
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
      width: Dimens.nw(310),
      height: Dimens.nh(200),
      borderRadius: Dimens.nr(27),
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
            borderRadius: BorderRadius.circular(Dimens.nr(27)),
          ),
        ),
        if (thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.nr(27)),
            child: Image.network(
              thumbnailUrl!,
              width: Dimens.nw(310),
              height: Dimens.nh(200),
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
              SizedBox(height: Dimens.nh(16)),
              Text(
                isDecrypting
                    ? 'در حال رمزگشایی ویدیو...'
                    : isDownloading
                        ? 'در حال دانلود ویدیو...'
                        : 'در حال پردازش ویدیو...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: Dimens.nsp(14), // Reduced from 16
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
        borderRadius: BorderRadius.circular(Dimens.nr(27)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).textTheme.titleMedium?.color,
              size: Dimens.nr(40), // Reduced from 48
            ),
            SizedBox(height: Dimens.nh(16)),
            Text(
              'خطا در بارگذاری ویدیو',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontSize: Dimens.nsp(14), // Reduced from 16
              ),
            ),
          ],
        ),
      ),
    );
  }
}
