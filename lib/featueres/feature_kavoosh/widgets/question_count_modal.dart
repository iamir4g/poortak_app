import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class QuestionCountModal extends StatefulWidget {
  final String title;
  final int maxQuestions;
  final int initialCount;
  final String? thumbnailAsset;
  final ValueChanged<int> onStart;

  const QuestionCountModal({
    super.key,
    required this.title,
    required this.onStart,
    required this.maxQuestions,
    this.initialCount = 20,
    this.thumbnailAsset,
  });

  @override
  State<QuestionCountModal> createState() => _QuestionCountModalState();
}

class _QuestionCountModalState extends State<QuestionCountModal> {
  late double _currentSliderValue;

  int get _max => widget.maxQuestions < 1 ? 1 : widget.maxQuestions;

  @override
  void initState() {
    super.initState();
    final preferred = widget.initialCount.clamp(1, _max);
    _currentSliderValue = preferred.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final midLabel = (_max / 2).round();

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: isDark ? Border.all(color: MyColors.darkBorder) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 40.w),
            ],
          ),
          Container(
            width: 80.r,
            height: 80.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF4081),
            ),
            child: Center(
              child: Image.asset(
                widget.thumbnailAsset ??
                    'assets/images/kavoosh/khodsanji/reiazi_logo.png',
                width: 50.r,
                height: 50.r,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.quiz_outlined,
                  size: 36.r,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              widget.title,
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: isDark ? MyColors.darkTextPrimary : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تعداد سوال: ${toPersianDigits(_currentSliderValue.round().toString())}',
            style: MyTextStyle.textMatn14Bold.copyWith(
              color: isDark ? MyColors.darkTextSecondary : MyColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: MyColors.primary,
                    inactiveTrackColor: isDark
                        ? MyColors.darkBorder.withValues(alpha: 0.6)
                        : const Color(0xFFE0E0E0),
                    thumbColor: MyColors.primary,
                    overlayColor: MyColors.primary.withValues(alpha: 0.2),
                    trackHeight: 4.0.h,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 10.0.r),
                    overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 20.0.r),
                  ),
                  child: Slider(
                    value: _currentSliderValue.clamp(1, _max.toDouble()),
                    min: 1,
                    max: _max.toDouble(),
                    divisions: _max > 1 ? _max - 1 : 1,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        toPersianDigits('1'),
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.textSecondary,
                        ),
                      ),
                      Text(
                        toPersianDigits(midLabel.toString()),
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.textSecondary,
                        ),
                      ),
                      Text(
                        toPersianDigits(_max.toString()),
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onStart(_currentSliderValue.round().clamp(1, _max));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? MyColors.primary : const Color(0xFF3F445A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'بزن بریم!',
                style:
                    MyTextStyle.textHeader16Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
