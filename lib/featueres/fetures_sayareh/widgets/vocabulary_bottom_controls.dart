import 'dart:async';

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
  final LitnerResultToastController? litnerToastController;

  const VocabularyBottomControls({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onReadWord,
    required this.onAddToLitner,
    required this.isAddLoading,
    required this.iconColor,
    this.litnerToastController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleBg = isDark
        ? MyColors.darkBackgroundSecondary
        : MyColors.modalHeaderBackground;
    final circleBgPressed = isDark ? MyColors.darkBorder : MyColors.text2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          key: const Key('vocabulary_forward_button'),
          onPressed: onNext,
          icon: Icon(Icons.arrow_back, color: iconColor),
          iconSize: 32.r,
        ),
        PressableCircle(
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
        LitnerAddCircleButton(
          toastController: litnerToastController,
          enabled: !isAddLoading,
          backgroundColor: circleBg,
          pressedBackgroundColor: circleBgPressed,
          onTap: onAddToLitner,
          isLoading: isAddLoading,
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

class LitnerResultToastController extends ChangeNotifier {
  bool _visible = false;
  String _text = '';
  bool _showCheckIcon = false;
  Timer? _timer;

  bool get visible => _visible;
  String get text => _text;
  bool get showCheckIcon => _showCheckIcon;

  void show({
    required String text,
    required bool showCheckIcon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _timer?.cancel();
    _visible = true;
    _text = text;
    _showCheckIcon = showCheckIcon;
    notifyListeners();
    _timer = Timer(duration, () {
      _visible = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class LitnerResultToast extends StatelessWidget {
  final String text;
  final bool showCheckIcon;

  const LitnerResultToast({
    super.key,
    required this.text,
    required this.showCheckIcon,
  });

  @override
  Widget build(BuildContext context) {
    final toastBg = const Color(0xFFF6F5F5);
    final toastTextColor = MyColors.text1;

    return DecoratedBox(
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
              text,
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
    );
  }
}

class LitnerToastAnchor extends StatelessWidget {
  final LitnerResultToastController? controller;
  final Widget child;
  final double size;

  const LitnerToastAnchor({
    super.key,
    required this.child,
    this.controller,
    double? size,
  }) : size = size ?? 60;

  @override
  Widget build(BuildContext context) {
    final circleSize = Dimens.nr(size);
    final toastWidth = Dimens.nw(129);
    final toastHeight = Dimens.nh(40);
    final toastGap = Dimens.nh(8);
    final toastLeft = (circleSize - toastWidth) / 2;

    final controller = this.controller;
    if (controller == null) {
      return SizedBox(
        width: circleSize,
        height: circleSize,
        child: child,
      );
    }

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final visible = controller.visible;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: toastLeft,
                top: -(toastHeight + toastGap),
                child: AnimatedOpacity(
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 160),
                  child: IgnorePointer(
                    ignoring: !visible,
                    child: SizedBox(
                      width: toastWidth,
                      height: toastHeight,
                      child: LitnerResultToast(
                        text: controller.text,
                        showCheckIcon: controller.showCheckIcon,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: child),
            ],
          );
        },
      ),
    );
  }
}

class LitnerAddButtonContent extends StatelessWidget {
  final bool isLoading;
  final double iconSize;

  const LitnerAddButtonContent({
    super.key,
    required this.isLoading,
    double? iconSize,
  }) : iconSize = iconSize ?? 26;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: const AlwaysStoppedAnimation<Color>(MyColors.primary),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final litnerIconPath = isDark
        ? 'assets/images/litner/icon_add_litner_touched.png'
        : 'assets/images/litner/icon_add_litner.png';

    return Image.asset(
      litnerIconPath,
      width: Dimens.nr(iconSize),
      height: Dimens.nr(iconSize),
      fit: BoxFit.contain,
    );
  }
}

class LitnerAddCircleButton extends StatelessWidget {
  final LitnerResultToastController? toastController;
  final bool enabled;
  final bool isLoading;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final VoidCallback onTap;

  const LitnerAddCircleButton({
    super.key,
    this.toastController,
    required this.enabled,
    required this.isLoading,
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LitnerToastAnchor(
      controller: toastController,
      child: PressableCircle(
        enabled: enabled,
        backgroundColor: backgroundColor,
        pressedBackgroundColor: pressedBackgroundColor,
        onTap: onTap,
        child: LitnerAddButtonContent(isLoading: isLoading),
      ),
    );
  }
}

class LitnerAddIconButton extends StatelessWidget {
  final LitnerResultToastController? toastController;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;
  final double iconSize;

  const LitnerAddIconButton({
    super.key,
    this.toastController,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
    double? iconSize,
  }) : iconSize = iconSize ?? 32;

  @override
  Widget build(BuildContext context) {
    return LitnerToastAnchor(
      controller: toastController,
      child: Center(
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: LitnerAddButtonContent(
            isLoading: isLoading,
            iconSize: iconSize,
          ),
          iconSize: iconSize.r,
        ),
      ),
    );
  }
}

class PressableCircle extends StatefulWidget {
  final bool enabled;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final VoidCallback onTap;
  final Widget? child;
  final Widget Function(Color foreground)? childBuilder;

  const PressableCircle({
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
