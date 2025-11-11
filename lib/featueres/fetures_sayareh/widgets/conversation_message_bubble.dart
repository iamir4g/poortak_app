import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';

/// Widget برای نمایش یک حباب پیام در صفحه مکالمه
/// این widget شامل متن پیام، آیکون صوتی و ترجمه (در صورت فعال بودن) می‌باشد
class ConversationMessageBubble extends StatelessWidget {
  /// داده پیام که باید نمایش داده شود
  final Datum message;

  /// مشخص می‌کند که آیا این پیام در حال پخش است (برای نمایش border سبز)
  final bool isCurrentPlaying;

  /// مشخص می‌کند که آیا ترجمه باید نمایش داده شود
  final bool showTranslations;

  /// تابع callback که هنگام لمس پیام فراخوانی می‌شود
  final VoidCallback onTap;

  const ConversationMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentPlaying,
    required this.showTranslations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تعیین اینکه آیا پیام از طرف شخص اول (male voice) است یا نه
    final isFirstPerson = message.voice == 'male';

    // محاسبه عرض صفحه برای محدود کردن عرض حباب پیام
    final screenWidth = MediaQuery.of(context).size.width;

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
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              // رنگ نارنجی برای پیام‌های شخص اول و خاکستری برای شخص دوم
              color: isFirstPerson ? MyColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              // نمایش border سبز اگر پیام در حال پخش است
              border: isCurrentPlaying
                  ? Border.all(color: Colors.green, width: 2)
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
                      child: Text(
                        message.text,
                        style: FontSizeHelper.getContentTextStyle(
                          context,
                          baseFontSize: 16.0,
                          color: isFirstPerson ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // // آیکون صوتی برای نشان دادن قابلیت پخش
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 2),
                    //   child: Icon(
                    //     Icons.volume_up,
                    //     size: 16,
                    //     color: isFirstPerson ? Colors.white70 : Colors.black54,
                    //   ),
                    // ),
                  ],
                ),
                // نمایش ترجمه در صورت فعال بودن
                if (showTranslations) ...[
                  const SizedBox(height: 4),
                  Text(
                    message.translation,
                    style: FontSizeHelper.getContentTextStyle(
                      context,
                      baseFontSize: 12.0,
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
