import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
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
      width: 360,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: Container(
          width: 350,
          height: 240,
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
      width: 350,
      height: 240,
      borderRadius: 37,
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
            borderRadius: BorderRadius.circular(37),
          ),
        ),
        if (thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(37),
            child: Image.network(
              thumbnailUrl!,
              width: 350,
              height: 240,
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
              const SizedBox(height: 16),
              Text(
                isDecrypting
                    ? 'در حال رمزگشایی ویدیو...'
                    : isDownloading
                        ? 'در حال دانلود ویدیو...'
                        : 'در حال پردازش ویدیو...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 16,
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
        borderRadius: BorderRadius.circular(37),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).textTheme.titleMedium?.color,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری ویدیو',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
