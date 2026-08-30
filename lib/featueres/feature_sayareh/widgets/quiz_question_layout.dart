import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

/// Keeps question + options vertically centered while feedback/buttons use
/// fixed slots so layout does not jump when answer feedback appears.
class QuizQuestionLayout extends StatelessWidget {
  final Widget question;
  final Widget options;
  final Widget? feedback;
  final Widget? bottomButton;
  final double horizontalPadding;

  const QuizQuestionLayout({
    super.key,
    required this.question,
    required this.options,
    this.feedback,
    this.bottomButton,
    this.horizontalPadding = 24,
  });

  static double feedbackSlotHeight() => Dimens.nh(120);

  static double actionSlotHeight() => Dimens.nh(78);

  @override
  Widget build(BuildContext context) {
    final horizontal = horizontalPadding.w;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: Dimens.nh(24)),
                        question,
                        SizedBox(height: Dimens.nh(32)),
                        options,
                        SizedBox(height: Dimens.nh(24)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: feedbackSlotHeight(),
                  child: feedback == null
                      ? const SizedBox.shrink()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Center(child: feedback),
                        ),
                ),
                SizedBox(
                  height: actionSlotHeight(),
                  child: Center(
                    child: bottomButton ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildQuizCorrectFeedback({required bool isDark}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: Dimens.nw(54),
        height: Dimens.nh(54),
        decoration: BoxDecoration(
          color: isDark
              ? MyColors.quizAnswerCorrectBackgroundDark
              : MyColors.quizAnswerCorrectBackgroundLight,
          borderRadius: BorderRadius.circular(Dimens.nr(50)),
        ),
        child: Icon(
          Icons.check_circle,
          color: isDark
              ? MyColors.quizAnswerCorrectTextDark
              : MyColors.quizAnswerCorrectBorderLight,
          size: Dimens.nr(40),
        ),
      ),
      SizedBox(height: Dimens.small),
      Text(
        'آفرین درست گفتی!🥳',
        style: MyTextStyle.textMatn12W300.copyWith(
          color: isDark ? MyColors.quizAnswerCorrectTextDark : MyColors.text2,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget buildQuizWrongFeedback({
  required bool isDark,
  required String explanation,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      vertical: Dimens.medium,
      horizontal: Dimens.medium,
    ),
    decoration: BoxDecoration(
      color: isDark ? MyColors.termsBackgroundDark : MyColors.cardBackground1,
      borderRadius: BorderRadius.circular(Dimens.radiusMedium),
      boxShadow: [
        BoxShadow(
          color: MyColors.textMatn2.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: BidiText(
      text: explanation,
      style: MyTextStyle.textMatn12W500.copyWith(
        color: isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1,
        fontSize: Dimens.nsp(13),
      ),
      textAlign: TextAlign.center,
    ),
  );
}
