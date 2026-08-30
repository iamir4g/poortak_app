import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

/// Leap-frog loader adapted from https://uiverse.io/dovatgabriel/pretty-crab-95
class DotLoadingWidget extends StatefulWidget {
  final double? size;
  final Color? color;
  final Duration speed;

  const DotLoadingWidget({
    super.key,
    this.size,
    this.color,
    this.speed = const Duration(milliseconds: 2000),
  });

  @override
  State<DotLoadingWidget> createState() => _DotLoadingWidgetState();
}

class _DotLoadingWidgetState extends State<DotLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const List<double> _baseOffsetFactors = [0.0, 0.4, 0.8];
  static const List<double> _phaseOffsets = [0.0, 2 / 3, 1 / 3];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.speed);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _controller.repeat();
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

  ({double translateX, double rotation}) _leapFrogTransform(
    double progress,
    double uibSize,
  ) {
    if (progress >= 0.99999) {
      return (translateX: 0, rotation: 0);
    }

    const firstSegment = 1 / 3;
    const secondSegment = 2 / 3;

    if (progress < firstSegment) {
      final local = progress / firstSegment;
      return (translateX: 0, rotation: local * math.pi);
    }

    if (progress < secondSegment) {
      final local = (progress - firstSegment) / firstSegment;
      return (translateX: -0.4 * uibSize * local, rotation: math.pi);
    }

    final local = (progress - secondSegment) / (0.99999 - secondSegment);
    return (
      translateX: -0.4 * uibSize - (0.4 * uibSize * local),
      rotation: math.pi,
    );
  }

  Matrix4 _buildDotTransform({
    required double baseOffset,
    required double translateX,
    required double rotation,
    required double uibSize,
  }) {
    final originX = uibSize / 2;
    final originY = uibSize / 2;

    return Matrix4.identity()
      ..translate(baseOffset + translateX, 0)
      ..translate(originX, originY)
      ..rotateZ(rotation)
      ..translate(-originX, -originY);
  }

  @override
  Widget build(BuildContext context) {
    final uibSize = widget.size ?? 40;
    final dotSize = uibSize * 0.22;
    final color = widget.color ?? MyColors.primary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: uibSize,
          height: uibSize,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: List.generate(3, (index) {
                  final progress =
                      (_animation.value + _phaseOffsets[index]) % 1.0;
                  final motion = _leapFrogTransform(progress, uibSize);
                  final baseOffset = _baseOffsetFactors[index] * uibSize;

                  return Transform(
                    transform: _buildDotTransform(
                      baseOffset: baseOffset,
                      translateX: motion.translateX,
                      rotation: motion.rotation,
                      uibSize: uibSize,
                    ),
                    child: SizedBox(
                      width: uibSize,
                      height: uibSize,
                      child: Align(
                        alignment: Alignment.centerLeft,
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
      ),
    );
  }
}
