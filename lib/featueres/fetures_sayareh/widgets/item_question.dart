import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';

class QuizAnswerItem extends StatefulWidget {
  final String title;
  final String id;
  final bool isSelected;
  final bool isCorrect;
  final bool showFeedback;
  final bool isWrongSelected;
  final String selectedAnswerId;

  const QuizAnswerItem({
    super.key,
    required this.title,
    required this.id,
    this.isSelected = false,
    this.isCorrect = false,
    this.showFeedback = false,
    this.isWrongSelected = false,
    this.selectedAnswerId = "",
  });

  @override
  State<QuizAnswerItem> createState() => _QuizAnswerItemState();
}

class _QuizAnswerItemState extends State<QuizAnswerItem> {
  @override
  void initState() {
    super.initState();
    _updateAppearance();
  }

  @override
  void didUpdateWidget(QuizAnswerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFeedback != oldWidget.showFeedback ||
        widget.isSelected != oldWidget.isSelected ||
        widget.isCorrect != oldWidget.isCorrect) {
      _updateAppearance();
    }
  }

  void _updateAppearance() {
    // Update the appearance of the widget based on the values of isSelected, isCorrect, isWrong, and showFeedback
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark
        ? MyColors.quizAnswerDefaultDarkBackground
        : MyColors.quizAnswerDefaultLightBackground;
    Color textColor = isDark ? MyColors.profileTextPrimaryDark : MyColors.paymentHistoryDetailValueLight;
    // log("widget.id: ${widget.id}");
    // log("widget.showFeedback: ${widget.showFeedback}");
    // log("widget.isCorrect: ${widget.isCorrect}");
    // log("widget.isSelected: ${widget.isSelected}");
    if (widget.showFeedback) {
      if (widget.isCorrect) {
        borderColor = isDark
            ? MyColors.quizAnswerCorrectBorderDark
            : MyColors.quizAnswerCorrectBorderLight;
        bgColor = isDark
            ? MyColors.quizAnswerCorrectBackgroundDark
            : MyColors.quizAnswerCorrectBackgroundLight;
        textColor = isDark ? MyColors.quizAnswerCorrectTextDark : textColor;
      } else if (widget.id == widget.selectedAnswerId &&
          widget.isWrongSelected) {
        borderColor = isDark
            ? MyColors.quizAnswerWrongBorderDark
            : MyColors.quizAnswerWrongBorderLight;
        bgColor = isDark
            ? MyColors.quizAnswerWrongBackgroundDark
            : MyColors.quizAnswerWrongBackgroundLight;
        textColor = isDark ? MyColors.quizAnswerWrongTextDark : textColor;
      }
    } else if (widget.isSelected) {
      borderColor = MyColors.quizAnswerSelectedBorder;
    }
    return Container(
      width: double.infinity,
      height: 68.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: borderColor,
          width: 2.w,
        ),
      ),
      child: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PressableAnswerOptionButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool enabled;

  const PressableAnswerOptionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<PressableAnswerOptionButton> createState() =>
      _PressableAnswerOptionButtonState();
}

class _PressableAnswerOptionButtonState extends State<PressableAnswerOptionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final normalBg =
        isDark ? MyColors.darkBackgroundSecondary : const Color(0xFFF3F5F7);
    final pressedBg = isDark ? MyColors.darkBorder : const Color(0xFF3D495C);
    final normalFg =
        isDark ? MyColors.profileTextPrimaryDark : const Color(0xFF3D495C);
    final pressedFg = Colors.white;

    final bg = _pressed ? pressedBg : normalBg;
    final fg = _pressed ? pressedFg : normalFg;

    return SizedBox(
      height: 56.h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: widget.enabled ? widget.onTap : null,
          onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
          onTapCancel: widget.enabled ? () => _setPressed(false) : null,
          onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
          child: Center(
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.6,
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: fg,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
