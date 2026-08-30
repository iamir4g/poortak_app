import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poortak/config/myColors.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import 'dart:io';

// Method Channel for screen security
const MethodChannel _securityChannel =
    MethodChannel('poortak.security.flutter.dev/channel');

class CustomVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isNetworkVideo;
  final double width;
  final double height;
  final double borderRadius;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullscreen;
  final VoidCallback? onVideoEnded;
  final String? thumbnailUrl;

  const CustomVideoPlayer({
    super.key,
    required this.videoPath,
    this.isNetworkVideo = false,
    this.width = 350,
    this.height = 240,
    this.borderRadius = 37,
    this.autoPlay = true,
    this.showControls = true,
    this.allowFullscreen = true,
    this.onVideoEnded,
    this.thumbnailUrl,
  });

  @override
  State<CustomVideoPlayer> createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _hasNotifiedEnded = false;
  bool _isFullscreenOpen = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _videoPlayerController.removeListener(_videoPlayerListener);
      _videoPlayerController.dispose();
    }
    // Disable FLAG_SECURE when video player is disposed
    _setSecureFlag(false);
    WakelockPlus.disable();
    _hideTimer?.cancel();
    super.dispose();
  }

  // Public method to stop video from external calls
  void stopVideo() {
    if (_isVideoInitialized) {
      _videoPlayerController.pause();
      setState(() {
        _isPlaying = false;
      });
    }
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

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> initializeVideoPlayer() async {
    try {
      final options = VideoPlayerOptions(mixWithOthers: true);
      _videoPlayerController = widget.isNetworkVideo
          ? VideoPlayerController.networkUrl(
              Uri.parse(widget.videoPath),
              videoPlayerOptions: options,
            )
          : VideoPlayerController.file(
              File(widget.videoPath),
              videoPlayerOptions: options,
            );

      await _videoPlayerController.initialize();

      // Add listener for video completion and buffering
      _videoPlayerController.addListener(_videoPlayerListener);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        if (widget.autoPlay) {
          _videoPlayerController.play();
          WakelockPlus.enable();
          setState(() {
            _isPlaying = true;
          });
        }
        // Enable secure flag once when initialized
        _setSecureFlag(true);
      }
    } catch (error) {
      debugPrint('Error initializing video player: $error');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _videoPlayerListener() {
    // Only update UI if buffering state changes
    if (mounted) {
      // You can add a local state for buffering if needed for UI
      // For now we just ensure UI updates on state changes
      if (_videoPlayerController.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _videoPlayerController.value.isPlaying;
        });
        if (_isPlaying) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      }
    }

    final value = _videoPlayerController.value;
    final duration = value.duration;
    if (duration != Duration.zero && value.position < duration) {
      _hasNotifiedEnded = false;
      return;
    }
    if (duration == Duration.zero || _hasNotifiedEnded) return;
    _hasNotifiedEnded = true;
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
    });
    WakelockPlus.disable();
    if (!_isFullscreenOpen) {
      widget.onVideoEnded?.call();
    }
  }

  void _togglePlayPause() {
    final isPlaying = _videoPlayerController.value.isPlaying;
    if (isPlaying) {
      _videoPlayerController.pause();
      WakelockPlus.disable();
    } else {
      _videoPlayerController.play();
      WakelockPlus.enable();
    }
    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  void _toggleControlsVisibility() {
    if (!_isVideoInitialized || !widget.showControls) {
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  Future<void> _setSecureFlag(bool enable) async {
    try {
      if (Platform.isAndroid) {
        await _securityChannel
            .invokeMethod('setSecureFlag', {'enable': enable});
      }
    } catch (e) {
      // Ignore errors - this is a security feature, not critical for functionality
      debugPrint('Error setting secure flag: $e');
    }
  }

  void _enterFullscreen() {
    _isFullscreenOpen = true;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoPlayerController: _videoPlayerController,
          videoPath: widget.videoPath,
          isNetworkVideo: widget.isNetworkVideo,
          onVideoEnded: widget.onVideoEnded,
        ),
        fullscreenDialog: true,
      ),
    )
        .then((_) {
      if (mounted) {
        _isFullscreenOpen = false;
      }
    });
  }

  /// Aspect ratio for layout, accounting for video rotation metadata.
  static double displayAspectRatio(VideoPlayerValue value) {
    if (!value.isInitialized || value.size.width == 0 || value.size.height == 0) {
      return 16 / 9;
    }
    final rotation = value.rotationCorrection % 360;
    if (rotation == 90 || rotation == 270) {
      return value.size.height / value.size.width;
    }
    return value.aspectRatio;
  }

  Widget _buildVideoControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder(
                valueListenable: _videoPlayerController,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Directionality(
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
                                  enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                            ),
                            child: Slider(
                              value: (_isDragging
                                      ? _dragValue
                                      : value.position.inMilliseconds
                                          .toDouble())
                                  .clamp(0.0,
                                      value.duration.inMilliseconds.toDouble()),
                              min: 0,
                              max: value.duration.inMilliseconds.toDouble(),
                              onChangeStart: (val) {
                                _hideTimer?.cancel();
                                setState(() {
                                  _isDragging = true;
                                  _dragValue = val;
                                });
                              },
                              onChanged: (val) {
                                setState(() {
                                  _dragValue = val;
                                });
                                _videoPlayerController.seekTo(
                                    Duration(milliseconds: val.toInt()));
                              },
                              onChangeEnd: (val) {
                                _videoPlayerController.seekTo(
                                    Duration(milliseconds: val.toInt()));
                                setState(() {
                                  _isDragging = false;
                                });
                                _startHideTimer();
                              },
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(_isDragging
                            ? Duration(milliseconds: _dragValue.toInt())
                            : value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (widget.allowFullscreen) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _enterFullscreen,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        color: MyColors.brandSecondary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        child: GestureDetector(
          onTap: () {
            _toggleControlsVisibility();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isVideoInitialized)
                Positioned.fill(
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoPlayerController.value.size.width,
                        height: _videoPlayerController.value.size.height,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.borderRadius)),
                    child: widget.thumbnailUrl != null
                        ? Image.network(
                            widget.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: widget.width,
                            height: widget.height,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ),

              if (_isVideoInitialized && widget.showControls)
                _buildVideoControls(),

              // Keep play/pause interaction centered while the controls are visible.
              if (_isVideoInitialized && widget.showControls && _showControls)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final String videoPath;
  final bool isNetworkVideo;
  final VoidCallback? onVideoEnded;

  const FullscreenVideoPlayer({
    super.key,
    required this.videoPlayerController,
    required this.videoPath,
    required this.isNetworkVideo,
    this.onVideoEnded,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isPlaying = false;
  bool _hasNotifiedEnded = false;

  @override
  void initState() {
    super.initState();
    // Hide system UI for fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _isPlaying = widget.videoPlayerController.value.isPlaying;
    _startHideTimer();

    // Add listener to update playing state
    widget.videoPlayerController.addListener(_videoListener);

    // Enable secure flag if video is playing
    if (_isPlaying) {
      _setSecureFlag(true);
      WakelockPlus.enable();
    }
  }

  void _videoListener() {
    if (mounted) {
      final wasPlaying = _isPlaying;
      setState(() {
        _isPlaying = widget.videoPlayerController.value.isPlaying;
      });
      // Update secure flag if playing state changed
      if (wasPlaying != _isPlaying) {
        _setSecureFlag(_isPlaying);
        if (_isPlaying) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      }
    }

    final value = widget.videoPlayerController.value;
    final duration = value.duration;
    if (duration != Duration.zero && value.position < duration) {
      _hasNotifiedEnded = false;
      return;
    }
    if (duration == Duration.zero || _hasNotifiedEnded) return;
    _hasNotifiedEnded = true;
    _handleVideoEndedInFullscreen();
  }

  void _handleVideoEndedInFullscreen() {
    if (!mounted) return;

    WakelockPlus.disable();
    _setSecureFlag(false);

    final onVideoEnded = widget.onVideoEnded;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onVideoEnded?.call();
    });
  }

  @override
  void dispose() {
    // Remove listener
    widget.videoPlayerController.removeListener(_videoListener);

    // Disable FLAG_SECURE when fullscreen player is disposed
    _setSecureFlag(false);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _hideTimer?.cancel();
    super.dispose();
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

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    final isPlaying = widget.videoPlayerController.value.isPlaying;
    if (isPlaying) {
      widget.videoPlayerController.pause();
      _setSecureFlag(false);
      WakelockPlus.disable();
    } else {
      widget.videoPlayerController.play();
      _setSecureFlag(true);
      WakelockPlus.enable();
    }
    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  Future<void> _setSecureFlag(bool enable) async {
    try {
      if (Platform.isAndroid) {
        await _securityChannel
            .invokeMethod('setSecureFlag', {'enable': enable});
      }
    } catch (e) {
      // Ignore errors - this is a security feature, not critical for functionality
      debugPrint('Error setting secure flag: $e');
    }
  }

  void _exitFullscreen() {
    Navigator.of(context).pop();
  }

  void _skipForward() {
    final currentPosition = widget.videoPlayerController.value.position;
    final duration = widget.videoPlayerController.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);

    if (newPosition > duration) {
      widget.videoPlayerController.seekTo(duration);
    } else {
      widget.videoPlayerController.seekTo(newPosition);
    }
    _showControls = true;
    _startHideTimer();
  }

  void _skipBackward() {
    final currentPosition = widget.videoPlayerController.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition.isNegative) {
      widget.videoPlayerController.seekTo(Duration.zero);
    } else {
      widget.videoPlayerController.seekTo(newPosition);
    }
    _showControls = true;
    _startHideTimer();
  }

  Widget _buildFullscreenControls() {
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
            // Top controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _exitFullscreen,
                  ),
                  // const Text(
                  //   'تمام صفحه',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Center play/pause button
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

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progress bar
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.3),
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        value: widget
                            .videoPlayerController.value.position.inMilliseconds
                            .toDouble(),
                        min: 0,
                        max: widget
                            .videoPlayerController.value.duration.inMilliseconds
                            .toDouble(),
                        onChanged: (value) {
                          final position =
                              Duration(milliseconds: value.toInt());
                          widget.videoPlayerController.seekTo(position);
                        },
                      ),
                    ),
                  ),

                  // Time display and skip buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Skip backward button
                      IconButton(
                        icon: const Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _skipBackward,
                        tooltip: '10 ثانیه به عقب',
                      ),
                      const SizedBox(width: 8),
                      // Skip forward button
                      IconButton(
                        icon: const Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _skipForward,
                        tooltip: '10 ثانیه به جلو',
                      ),
                      Spacer(),
                      // SizedBox(
                      //   width: double.infinity,
                      // ),
                      // Time display
                      Text(
                        _formatDuration(
                            widget.videoPlayerController.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const Text(
                        ' / ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        _formatDuration(
                            widget.videoPlayerController.value.duration),
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
          ],
        ),
      );
  }

  Widget _buildFullscreenVideo() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.videoPlayerController,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final aspectRatio =
                CustomVideoPlayerState.displayAspectRatio(value);
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final screenAspect = screenWidth / screenHeight;

            double width;
            double height;
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
                child: VideoPlayer(widget.videoPlayerController),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _toggleControlsVisibility,
            behavior: HitTestBehavior.opaque,
            child: _buildFullscreenVideo(),
          ),
          IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildFullscreenControls(),
            ),
          ),
        ],
      ),
    );
  }
}
