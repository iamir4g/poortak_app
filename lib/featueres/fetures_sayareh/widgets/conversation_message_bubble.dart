import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';

/// Widget برای نمایش یک حباب پیام در صفحه مکالمه
/// این widget شامل متن پیام، آیکون صوتی و ترجمه (در صورت فعال بودن) می‌باشد
class ConversationMessageBubble extends StatelessWidget {
  /// داده پیام که باید نمایش داده شود
  final Datum message;

  /// مشخص می‌کند که آیا این پیام در حال پخش است
  final bool isCurrentPlaying;

  /// ایندکس جمله فعلی که در حال پخش است (برای Shadowing)
  final int currentSentenceIndex;

  /// مشخص می‌کند که آیا ترجمه باید نمایش داده شود
  final bool showTranslations;

  /// تابع callback که هنگام لمس پیام فراخوانی می‌شود
  final VoidCallback onTap;

  const ConversationMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentPlaying,
    this.currentSentenceIndex = 0,
    required this.showTranslations,
    required this.onTap,
  });

  Widget _sideAvatar({
    required bool isFirstPerson,
    required Color backgroundColor,
  }) {
    final assetPath = isFirstPerson
        ? 'assets/lottie/Talking_maya avatar.json'
        : 'assets/lottie/talking-robot.json';

    return SizedBox(
      width: Dimens.nw(41),
      height: Dimens.nh(41),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Lottie.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// تجزیه متن به جملات
  List<String> _splitIntoSentences(String text) {
    final RegExp regExp = RegExp(r'[^.!?]+[.!?]*');
    return regExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirstPerson = message.voice == 'male';
    final sentences = _splitIntoSentences(message.text);

    final bubbleColor = isDark
        ? (isFirstPerson
            ? MyColors.conversationFirstPersonBubbleDark
            : MyColors.conversationSecondPersonBubbleDark)
        : (isFirstPerson
            ? MyColors.conversationBubbleRightLight
            : MyColors.conversationBubbleLeftLight);

    final sideCircleColor = isDark
        ? (isFirstPerson
            ? MyColors.conversationSecondPersonBubbleDark
            : MyColors.conversationFirstPersonBubbleDark)
        : (isFirstPerson
            ? MyColors.conversationSideCircleRightLight
            : MyColors.conversationSideCircleLeftLight);

    final baseTextColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.text2;
    final translationColor =
        isDark ? MyColors.loginTextSecondaryDark : MyColors.text3;

    final bubbleRadiusRightPerson = BorderRadius.only(
      topLeft: Radius.circular(Dimens.nr(5)),
      topRight: Radius.circular(Dimens.nr(25)),
      bottomRight: Radius.circular(Dimens.nr(25)),
      bottomLeft: Radius.circular(Dimens.nr(25)),
    );

    final bubbleRadiusLeftPerson = BorderRadius.only(
      topLeft: Radius.circular(Dimens.nr(25)),
      topRight: Radius.circular(Dimens.nr(5)),
      bottomRight: Radius.circular(Dimens.nr(25)),
      bottomLeft: Radius.circular(Dimens.nr(25)),
    );
    return Align(
      alignment: isFirstPerson ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: isFirstPerson
                ? [
                    _sideAvatar(
                      isFirstPerson: isFirstPerson,
                      backgroundColor: sideCircleColor,
                    ),
                    SizedBox(width: Dimens.nw(8)),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Dimens.nw(207),
                        minHeight: Dimens.nh(49),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: bubbleRadiusLeftPerson,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.nw(14),
                            vertical: Dimens.nh(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                textDirection: TextDirection.ltr,
                                text: TextSpan(
                                  children:
                                      List.generate(sentences.length, (index) {
                                    final isSentenceActive = isCurrentPlaying &&
                                        index == currentSentenceIndex;
                                    final sentenceColor = isSentenceActive
                                        ? baseTextColor
                                        : baseTextColor.withValues(alpha: 0.6);
                                    return TextSpan(
                                      text: sentences[index],
                                      style: FontSizeHelper.getContentTextStyle(
                                        context,
                                        baseFontSize: 16.0.sp,
                                        color: sentenceColor,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              if (showTranslations) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  message.translation,
                                  style: FontSizeHelper.getContentTextStyle(
                                    context,
                                    baseFontSize: 12.0.sp,
                                    color: translationColor,
                                  ),
                                  softWrap: true,
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                : [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Dimens.nw(207),
                        minHeight: Dimens.nh(49),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: bubbleRadiusRightPerson,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.nw(14),
                            vertical: Dimens.nh(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                textDirection: TextDirection.ltr,
                                text: TextSpan(
                                  children:
                                      List.generate(sentences.length, (index) {
                                    final isSentenceActive = isCurrentPlaying &&
                                        index == currentSentenceIndex;
                                    final sentenceColor = isSentenceActive
                                        ? baseTextColor
                                        : baseTextColor.withValues(alpha: 0.6);
                                    return TextSpan(
                                      text: sentences[index],
                                      style: FontSizeHelper.getContentTextStyle(
                                        context,
                                        baseFontSize: 16.0.sp,
                                        color: sentenceColor,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              if (showTranslations) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  message.translation,
                                  style: FontSizeHelper.getContentTextStyle(
                                    context,
                                    baseFontSize: 12.0.sp,
                                    color: translationColor,
                                  ),
                                  softWrap: true,
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimens.nw(8)),
                    _sideAvatar(
                      isFirstPerson: isFirstPerson,
                      backgroundColor: sideCircleColor,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
