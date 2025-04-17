import 'package:flutter/material.dart';
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

  const CustomVideoPlayer({
    Key? key,
    required this.videoPath,
    this.isNetworkVideo = false,
    this.width = 350,
    this.height = 240,
    this.borderRadius = 37,
    this.autoPlay = true,
    this.showControls = true,
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
