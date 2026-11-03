import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/system_ui_helper.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/widgets/bookmark_toggle_button.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/short_video_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/locator.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;
  String? _title;
  bool _showControls = true;
  bool _isPlaying = false;
  Timer? _hideTimer;

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
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    WakelockPlus.disable();
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

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onControllerUpdate);
      await controller.play();
      await WakelockPlus.enable();
      setState(() {
        _controller = controller;
        _isPlaying = true;
        _loading = false;
      });
      _startHideTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطا در پخش ویدیو';
      });
    }
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (!mounted || controller == null) return;
    final playing = controller.value.isPlaying;
    if (playing != _isPlaying) {
      setState(() => _isPlaying = playing);
      if (playing) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() => _showControls = true);
    _startHideTimer();
  }

  void _skipBy(Duration offset) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    var next = controller.value.position + offset;
    if (next.isNegative) next = Duration.zero;
    if (next > duration) next = duration;
    controller.seekTo(next);
    setState(() => _showControls = true);
    _startHideTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Widget _buildVideo() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final aspectRatio =
                CustomVideoPlayerState.displayAspectRatio(value);
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            if (screenWidth <= 0 || screenHeight <= 0) {
              return const SizedBox.shrink();
            }
            final screenAspect = screenWidth / screenHeight;

            final double width;
            final double height;
            if (aspectRatio > screenAspect) {
              width = screenWidth;
              height = width / aspectRatio;
            } else {
              height = screenHeight;
              width = height * aspectRatio;
            }

            return Center(
              child: SizedBox(
                width: width,
                height: height,
                child: VideoPlayer(controller),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControls() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final durationMs = value.duration.inMilliseconds.toDouble();
        final positionMs = value.position.inMilliseconds
            .clamp(0, durationMs.isNaN ? 0 : durationMs)
            .toDouble();
        final max = durationMs <= 0 ? 1.0 : durationMs;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const BackButton(color: Colors.white),
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
              Expanded(
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 80,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.3),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withValues(alpha: 0.3),
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                          ),
                          child: Slider(
                            value: positionMs,
                            min: 0,
                            max: max,
                            onChanged: (next) {
                              controller.seekTo(
                                Duration(milliseconds: next.toInt()),
                              );
                              setState(() => _showControls = true);
                              _startHideTimer();
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                _skipBy(const Duration(seconds: -10)),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                _skipBy(const Duration(seconds: 10)),
                          ),
                          const Spacer(),
                          Text(
                            '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _error != null
              ? Stack(
                  children: [
                    Center(
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
                    ),
                    const SafeArea(
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: BackButton(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: _toggleControlsVisibility,
                      behavior: HitTestBehavior.opaque,
                      child: ColoredBox(
                        color: Colors.black,
                        child: _buildVideo(),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !_showControls,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildControls(),
                      ),
                    ),
                  ],
                ),
    );
  }
}
