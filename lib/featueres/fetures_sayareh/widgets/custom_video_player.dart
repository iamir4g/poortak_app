import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poortak/config/myColors.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

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

  const CustomVideoPlayer({
    Key? key,
    required this.videoPath,
    this.isNetworkVideo = false,
    this.width = 350,
    this.height = 240,
    this.borderRadius = 37,
    this.autoPlay = true,
    this.showControls = true,
    this.allowFullscreen = true,
    this.onVideoEnded,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoPlayerListener);
    _videoPlayerController.dispose();
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

  Future<void> initializeVideoPlayer() async {
    try {
      _videoPlayerController = widget.isNetworkVideo
          ? VideoPlayerController.network(widget.videoPath)
          : VideoPlayerController.file(File(widget.videoPath));

      await _videoPlayerController.initialize();

      // Add listener for video completion
      _videoPlayerController.addListener(_videoPlayerListener);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        if (widget.autoPlay) {
          _videoPlayerController.play();
          setState(() {
            _isPlaying = true;
          });
        }
      }
    } catch (error) {
      print('Error initializing video player: $error');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _videoPlayerListener() {
    if (_videoPlayerController.value.position >=
        _videoPlayerController.value.duration) {
      // Video has ended
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        // Call the callback if provided
        widget.onVideoEnded?.call();
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
    });
    _startHideTimer();
  }

  void _enterFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoPlayerController: _videoPlayerController,
          videoPath: widget.videoPath,
          isNetworkVideo: widget.isNetworkVideo,
          onVideoEnded: widget.onVideoEnded,
        ),
        fullscreenDialog: true,
      ),
    );
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
              Colors.black,
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.3),
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: _videoPlayerController
                            .value.position.inMilliseconds
                            .toDouble(),
                        min: 0,
                        max: _videoPlayerController
                            .value.duration.inMilliseconds
                            .toDouble(),
                        onChanged: (value) {
                          final position =
                              Duration(milliseconds: value.toInt());
                          _videoPlayerController.seekTo(position);
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(_videoPlayerController.value.position),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_videoPlayerController.value.duration),
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
            if (widget.showControls) {
              setState(() {
                _showControls = !_showControls;
              });
              if (_showControls) {
                _startHideTimer();
              }
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: _isVideoInitialized
                    ? VideoPlayer(_videoPlayerController)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              if (_isVideoInitialized && widget.showControls)
                _buildVideoControls(),
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
    Key? key,
    required this.videoPlayerController,
    required this.videoPath,
    required this.isNetworkVideo,
    this.onVideoEnded,
  }) : super(key: key);

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isPlaying = false;

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
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.videoPlayerController.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    // Remove listener
    widget.videoPlayerController.removeListener(_videoListener);
    
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
    setState(() {
      if (_isPlaying) {
        widget.videoPlayerController.pause();
      } else {
        widget.videoPlayerController.play();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
    });
    _startHideTimer();
  }

  void _exitFullscreen() {
    Navigator.of(context).pop();
  }

  Widget _buildFullscreenControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
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
                  const Text(
                    'تمام صفحه',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Center play/pause button
            Expanded(
              child: Center(
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
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
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.3),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      value: widget.videoPlayerController.value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: widget.videoPlayerController.value.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        final position = Duration(milliseconds: value.toInt());
                        widget.videoPlayerController.seekTo(position);
                      },
                    ),
                  ),
                  
                  // Time display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(widget.videoPlayerController.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDuration(widget.videoPlayerController.value.duration),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          if (_showControls) {
            _startHideTimer();
          }
        },
        child: Stack(
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: widget.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(widget.videoPlayerController),
              ),
            ),
            
            // Controls overlay
            _buildFullscreenControls(),
          ],
        ),
      ),
    );
  }
}
