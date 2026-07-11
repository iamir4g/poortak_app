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

  /// مشخص می‌کند که آیا پخش خودکار فعال است
  final bool isPlaybackActive;

  /// ایندکس جمله فعلی که در حال پخش است (برای Shadowing)
  final int currentSentenceIndex;

  /// کلیدهای هر جمله برای اسکرول دقیق به جمله در حال پخش
  final Map<int, GlobalKey>? sentenceKeys;

  /// مشخص می‌کند که آیا ترجمه باید نمایش داده شود
  final bool showTranslations;

  /// تابع callback که هنگام لمس پیام فراخوانی می‌شود
  final VoidCallback onTap;

  const ConversationMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentPlaying,
    this.isPlaybackActive = false,
    this.currentSentenceIndex = 0,
    this.sentenceKeys,
    required this.showTranslations,
    required this.onTap,
  });

  Widget _sideAvatar({
    required String assetPath,
    required Color backgroundColor,
  }) {

    return SizedBox(
      width: Dimens.nw(50),
      height: Dimens.nh(50),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: ClipOval(
            child: Lottie.asset(
              assetPath,
              fit: BoxFit.cover,
            ),
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

  double _sentenceOpacity(int index) {
    if (!isPlaybackActive) return 1.0;
    if (isCurrentPlaying && index == currentSentenceIndex) return 1.0;
    return 0.18;
  }

  Widget _buildMessageText({
    required BuildContext context,
    required List<String> sentences,
    required Color baseTextColor,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        textDirection: TextDirection.ltr,
        TextSpan(
          children: [
            for (var index = 0; index < sentences.length; index++) ...[
              if (sentenceKeys?[index] != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(
                    key: sentenceKeys![index],
                    width: 0,
                    height: 0,
                  ),
                ),
              TextSpan(
                text: sentences[index],
                style: FontSizeHelper.getContentTextStyle(
                  context,
                  baseFontSize: 16.0.sp,
                  color: baseTextColor.withValues(
                    alpha: _sentenceOpacity(index),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirstPerson = message.isMaleSpeaker;
    final avatarPath = message.conversationAvatarPath;
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
                      assetPath: avatarPath,
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
                              _buildMessageText(
                                context: context,
                                sentences: sentences,
                                baseTextColor: baseTextColor,
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
                              _buildMessageText(
                                context: context,
                                sentences: sentences,
                                baseTextColor: baseTextColor,
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
                      assetPath: avatarPath,
                      backgroundColor: sideCircleColor,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
