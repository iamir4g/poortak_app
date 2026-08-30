import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

/// Compact three-dot loading indicator.
class DotLoadingWidget extends StatefulWidget {
  final double? size;
  final Color? color;
  final Duration speed;

  const DotLoadingWidget({
    super.key,
    this.size,
    this.color,
    this.speed = const Duration(milliseconds: 900),
  });

  @override
  State<DotLoadingWidget> createState() => _DotLoadingWidgetState();
}

class _DotLoadingWidgetState extends State<DotLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const int _dotCount = 3;
  static const List<double> _phaseOffsets = [0.0, 0.33, 0.66];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.speed)
      ..repeat();
  }

  @override
  void didUpdateWidget(DotLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = widget.speed;
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotScale(double progress) {
    final wave = math.sin(progress * math.pi * 2);
    return 0.55 + (wave + 1) * 0.225;
  }

  double _dotOpacity(double progress) {
    final wave = math.sin(progress * math.pi * 2);
    return 0.35 + (wave + 1) * 0.325;
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size ?? 6;
    final spacing = dotSize * 0.55;
    final color = widget.color ?? MyColors.secondary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotCount, (index) {
                final progress =
                    (_controller.value + _phaseOffsets[index]) % 1.0;
                final scale = _dotScale(progress);
                final opacity = _dotOpacity(progress);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
