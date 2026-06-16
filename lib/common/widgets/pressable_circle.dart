import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';

class PressableCircle extends StatefulWidget {
  final bool enabled;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final VoidCallback onTap;
  final Widget? child;
  final Widget Function(Color foreground)? childBuilder;

  const PressableCircle({
    super.key,
    required this.enabled,
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.onTap,
    this.child,
    this.childBuilder,
  }) : assert(child != null || childBuilder != null);

  @override
  State<PressableCircle> createState() => _PressableCircleState();
}

class _PressableCircleState extends State<PressableCircle> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg =
        _pressed ? widget.pressedBackgroundColor : widget.backgroundColor;
    final fg = _pressed
        ? Colors.white
        : (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : MyColors.text2);
    final child = widget.childBuilder?.call(fg) ?? widget.child!;

    return SizedBox(
      width: Dimens.nr(60),
      height: Dimens.nr(60),
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.enabled ? widget.onTap : null,
          onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
          onTapCancel: widget.enabled ? () => _setPressed(false) : null,
          onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
          child: Center(
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.6,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
