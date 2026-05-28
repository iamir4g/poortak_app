import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class VocabularyBottomControls extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onReadWord;
  final VoidCallback onAddToLitner;
  final bool isAddLoading;
  final Color iconColor;
  final bool showLitnerToast;
  final String litnerToastText;
  final bool showLitnerToastCheckIcon;

  const VocabularyBottomControls({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onReadWord,
    required this.onAddToLitner,
    required this.isAddLoading,
    required this.iconColor,
    required this.showLitnerToast,
    required this.litnerToastText,
    required this.showLitnerToastCheckIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleBg = isDark
        ? MyColors.darkBackgroundSecondary
        : MyColors.modalHeaderBackground;
    final circleBgPressed = isDark ? MyColors.darkBorder : MyColors.text2;
    final litnerIconPath = isDark
        ? 'assets/images/litner/icon_add_litner_touched.png'
        : 'assets/images/litner/icon_add_litner.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          key: const Key('vocabulary_forward_button'),
          onPressed: onNext,
          icon: Icon(Icons.arrow_back, color: iconColor),
          iconSize: 32.r,
        ),
        _PressableCircle(
          enabled: true,
          backgroundColor: circleBg,
          pressedBackgroundColor: circleBgPressed,
          onTap: onReadWord,
          childBuilder: (foreground) => SvgPicture.asset(
            'assets/images/icons/cuida--volume-2-outline.svg',
            width: Dimens.nr(28),
            height: Dimens.nr(28),
            colorFilter: ColorFilter.mode(
              foreground,
              BlendMode.srcIn,
            ),
          ),
        ),
        _LitnerButtonWithToast(
          showToast: showLitnerToast,
          toastText: litnerToastText,
          showCheckIcon: showLitnerToastCheckIcon,
          enabled: !isAddLoading,
          circleBg: circleBg,
          circleBgPressed: circleBgPressed,
          onTap: onAddToLitner,
          child: isAddLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(MyColors.primary),
                  ),
                )
              : Image.asset(
                  litnerIconPath,
                  width: Dimens.nr(26),
                  height: Dimens.nr(26),
                  fit: BoxFit.contain,
                ),
        ),
        IconButton(
          onPressed: onPrevious,
          icon: Icon(Icons.arrow_forward, color: iconColor),
          iconSize: 32.r,
        ),
      ],
    );
  }
}

class _LitnerButtonWithToast extends StatelessWidget {
  final bool showToast;
  final String toastText;
  final bool showCheckIcon;
  final bool enabled;
  final Color circleBg;
  final Color circleBgPressed;
  final VoidCallback onTap;
  final Widget child;

  const _LitnerButtonWithToast({
    required this.showToast,
    required this.toastText,
    required this.showCheckIcon,
    required this.enabled,
    required this.circleBg,
    required this.circleBgPressed,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final toastBg = const Color(0xFFF6F5F5);
    final toastTextColor = MyColors.text1;
    final circleSize = Dimens.nr(60);
    final toastWidth = Dimens.nw(129);
    final toastHeight = Dimens.nh(40);
    final toastGap = Dimens.nh(8);
    final toastLeft = (circleSize - toastWidth) / 2;

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: toastLeft,
            top: -(toastHeight + toastGap),
            child: AnimatedOpacity(
              opacity: showToast ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 160),
              child: IgnorePointer(
                ignoring: !showToast,
                child: SizedBox(
                  width: toastWidth,
                  height: toastHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: toastBg,
                      borderRadius: BorderRadius.circular(Dimens.nr(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        if (showCheckIcon) ...[
                          Image.asset(
                            'assets/images/litner/check 20 1.png',
                            width: Dimens.nr(20),
                            height: Dimens.nr(20),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: Dimens.nw(6)),
                        ],
                        Flexible(
                          child: Text(
                            toastText,
                            style: MyTextStyle.textMatn10W300.copyWith(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                              color: toastTextColor,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: _PressableCircle(
              enabled: enabled,
              backgroundColor: circleBg,
              pressedBackgroundColor: circleBgPressed,
              onTap: onTap,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableCircle extends StatefulWidget {
  final bool enabled;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final VoidCallback onTap;
  final Widget? child;
  final Widget Function(Color foreground)? childBuilder;

  const _PressableCircle({
    required this.enabled,
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.onTap,
    this.child,
    this.childBuilder,
  }) : assert(child != null || childBuilder != null);

  @override
  State<_PressableCircle> createState() => _PressableCircleState();
}

class _PressableCircleState extends State<_PressableCircle> {
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
