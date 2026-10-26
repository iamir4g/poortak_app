import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/system_ui_helper.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/widgets/bookmark_toggle_button.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/short_video_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/locator.dart';

class ShortVideoPlayerScreen extends StatefulWidget {
  static const String routeName = '/short-video-player';

  final String videoId;
  final String? title;

  const ShortVideoPlayerScreen({
    super.key,
    required this.videoId,
    this.title,
  });

  static void open(
    BuildContext context, {
    required String videoId,
    String? title,
  }) {
    if (videoId.isEmpty) return;
    Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        'videoId': videoId,
        if (title != null && title.isNotEmpty) 'title': title,
      },
    );
  }

  @override
  State<ShortVideoPlayerScreen> createState() => _ShortVideoPlayerScreenState();
}

class _ShortVideoPlayerScreenState extends State<ShortVideoPlayerScreen> {
  final KavooshRepository _repository = locator<KavooshRepository>();

  bool _loading = true;
  String? _error;
  String? _playbackUrl;
  String? _thumbnailUrl;
  String? _title;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _title = widget.title;
    _load();
  }

  @override
  void dispose() {
    applyAppSystemUiMode();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.videoId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'ویدیو کوتاه یافت نشد';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait([
      _repository.fetchShortVideoDetail(shortVideoId: widget.videoId),
      _repository.fetchShortVideoDownloadUrl(shortVideoId: widget.videoId),
    ]);

    if (!mounted) return;

    final detailResult = results[0] as DataState<ShortVideoDetail>;
    final downloadResult = results[1] as DataState<String>;

    if (detailResult is DataSuccess<ShortVideoDetail>) {
      final detail = detailResult.data;
      if (detail != null) {
        _title = detail.title;
        context.read<BookmarkCubit>().syncFromDetail(
              type: BookmarkType.ShortVideo,
              itemId: detail.id,
              isBookmarked: detail.isBookmarked,
            );
        if (detail.thumbnailId.isNotEmpty) {
          _thumbnailUrl =
              await GetImageUrlService().getImageUrl(detail.thumbnailId);
        }
      }
    }

    if (!mounted) return;

    if (downloadResult is DataFailed) {
      setState(() {
        _loading = false;
        _error = downloadResult.error ?? 'ویدیو کوتاه یافت نشد';
      });
      return;
    }

    final url = (downloadResult as DataSuccess<String>).data?.trim() ?? '';
    if (url.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'آدرس پخش ویدیو نامعتبر است';
      });
      return;
    }

    setState(() {
      _playbackUrl = url;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _error!,
                            style: MyTextStyle.textMatn14Bold.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CustomVideoPlayer(
                        videoPath: _playbackUrl!,
                        isNetworkVideo: true,
                        autoPlay: true,
                        showControls: true,
                        allowFullscreen: false,
                        width: size.width,
                        height: size.height,
                        borderRadius: 0,
                        thumbnailUrl: _thumbnailUrl,
                      ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  BackButton(color: Colors.white),
                  Expanded(
                    child: Text(
                      _title ?? 'ویدیو کوتاه',
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.videoId.isNotEmpty)
                    BookmarkToggleButton(
                      type: BookmarkType.ShortVideo,
                      itemId: widget.videoId,
                      iconColor: Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
