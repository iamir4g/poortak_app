import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
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

  /// تجزیه متن به جملات
  List<String> _splitIntoSentences(String text) {
    final RegExp regExp = RegExp(r'[^.!?]+[.!?]*');
    return regExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    // تعیین اینکه آیا پیام از طرف شخص اول (male voice) است یا نه
    final isFirstPerson = message.voice == 'male';

    // محاسبه عرض صفحه برای محدود کردن عرض حباب پیام
    final screenWidth = MediaQuery.of(context).size.width;

    // تجزیه متن به جملات برای هایلایت کردن جمله فعال
    final sentences = _splitIntoSentences(message.text);

    return Align(
      // تراز حباب به راست برای پیام‌های شخص اول و به چپ برای پیام‌های شخص دوم
      alignment: isFirstPerson ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          // محدود کردن عرض حباب به 75% عرض صفحه
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.75,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            decoration: BoxDecoration(
              // رنگ نارنجی برای پیام‌های شخص اول و خاکستری برای شخص دوم
              color: isFirstPerson ? MyColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(20.r),
              // نمایش border سبز اگر پیام در حال پخش است
              border: isCurrentPlaying
                  ? Border.all(color: Colors.green, width: 2.w)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ردیف شامل متن پیام و آیکون صوتی
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    // متن پیام که می‌تواند wrap شود
                    Expanded(
                      child: RichText(
                        textDirection: TextDirection.ltr,
                        text: TextSpan(
                          children: List.generate(sentences.length, (index) {
                            final isSentenceActive = isCurrentPlaying &&
                                index == currentSentenceIndex;
                            return TextSpan(
                              text: sentences[index],
                              style: FontSizeHelper.getContentTextStyle(
                                context,
                                baseFontSize: 16.0.sp,
                                color: isSentenceActive
                                    ? (isFirstPerson
                                        ? Colors.white
                                        : Colors.black)
                                    : (isFirstPerson
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.4)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                // نمایش ترجمه در صورت فعال بودن
                if (showTranslations) ...[
                  SizedBox(height: 4.h),
                  Text(
                    message.translation,
                    style: FontSizeHelper.getContentTextStyle(
                      context,
                      baseFontSize: 12.0.sp,
                      color: isFirstPerson ? Colors.white70 : Colors.black54,
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
    );
  }
}
