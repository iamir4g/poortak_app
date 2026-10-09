import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

/// Keeps question + options vertically centered while feedback/buttons use
/// fixed slots so layout does not jump when answer feedback appears.
class QuizQuestionLayout extends StatelessWidget {
  final Widget question;
  final Widget options;
  final Widget? progress;
  final Widget? feedback;
  final Widget? bottomButton;
  final double horizontalPadding;

  const QuizQuestionLayout({
    super.key,
    required this.question,
    required this.options,
    this.progress,
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
        if (progress != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: horizontal,
              end: horizontal,
              top: Dimens.nh(16),
            ),
            child: Center(child: progress),
          ),
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

Widget buildQuizStepProgress({
  required BuildContext context,
  required int currentQuestion,
  required int totalSteps,
  String? description,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final steps = totalSteps <= 0 ? 1 : totalSteps;
  // `currentQuestion` is 1-based from API `answered`.
  final displayIndex = currentQuestion.clamp(1, steps);
  final currentIndex = displayIndex - 1;
  final hasDescription = description != null && description.trim().isNotEmpty;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      StepProgress(
        currentIndex: currentIndex,
        totalSteps: steps,
      ),
      SizedBox(height: Dimens.nh(8)),
      Text(
        '${toPersianDigits('$displayIndex')} از ${toPersianDigits('$steps')}',
        textAlign: TextAlign.center,
        style: MyTextStyle.textMatn12W500.copyWith(
          color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
        ),
      ),
      SizedBox(height: Dimens.nh(8)),
      if (hasDescription) ...[
        SizedBox(height: Dimens.nh(8)),
        Container(
          width: Dimens.nw(267),
          height: Dimens.nh(45),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark
                ? MyColors.quizDescriptionBackgroundDark
                : MyColors.quizDescriptionBackground,
            borderRadius: BorderRadius.circular(Dimens.nr(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: Dimens.nw(12)),
          child: Text(
            description.trim(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MyTextStyle.textMatn12W500.copyWith(
              color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
            ),
          ),
        ),
      ],
    ],
  );
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
      Builder(
        builder: (context) => Text(
          'آفرین درست گفتی!🥳',
          style: MyTextStyle.textMatn12W300.copyWith(
            fontSize: FontSizeHelper.getScaledFontSize(
              context,
              MyTextStyle.textMatn12W300.fontSize ?? 12.sp,
            ),
            color:
                isDark ? MyColors.quizAnswerCorrectTextDark : MyColors.text2,
          ),
          textAlign: TextAlign.center,
        ),
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
    child: Builder(
      builder: (context) => BidiText(
        text: explanation,
        style: MyTextStyle.textMatn12W500.copyWith(
          color: isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1,
          fontSize: FontSizeHelper.getScaledFontSize(context, Dimens.nsp(13)),
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
