import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/pressable_circle.dart';
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
          child: Image.asset(
            'assets/images/icons/volume.png',
            width: Dimens.nr(28),
            height: Dimens.nr(28),
            fit: BoxFit.contain,
          ),
        ),
        LitnerAddButton(
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

class LitnerAddButton extends StatelessWidget {
  final LitnerResultToastController? toastController;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? pressedBackgroundColor;
  final double iconSize;

  const LitnerAddButton({
    super.key,
    this.toastController,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
    this.backgroundColor,
    this.pressedBackgroundColor,
    this.iconSize = 26,
  });

  bool get _useCircleStyle =>
      backgroundColor != null && pressedBackgroundColor != null;

  @override
  Widget build(BuildContext context) {
    final content = LitnerAddButtonContent(
      isLoading: isLoading,
      iconSize: iconSize,
    );

    return LitnerToastAnchor(
      controller: toastController,
      size: _useCircleStyle ? 60 : 48,
      child: _useCircleStyle
          ? PressableCircle(
              enabled: enabled,
              backgroundColor: backgroundColor!,
              pressedBackgroundColor: pressedBackgroundColor!,
              onTap: onTap,
              child: content,
            )
          : Center(
              child: IconButton(
                onPressed: enabled ? onTap : null,
                icon: content,
                iconSize: iconSize.r,
              ),
            ),
    );
  }
}
