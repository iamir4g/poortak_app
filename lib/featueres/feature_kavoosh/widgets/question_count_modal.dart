import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class QuestionCountModal extends StatefulWidget {
  final String title;
  final VoidCallback onStart;

  const QuestionCountModal({
    super.key,
    required this.title,
    required this.onStart,
  });

  @override
  State<QuestionCountModal> createState() => _QuestionCountModalState();
}

class _QuestionCountModalState extends State<QuestionCountModal> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: MyColors.text3, size: 24.r),
              ),
              SizedBox(width: 40.w), // Spacer for centering if needed
            ],
          ),
          // Icon Placeholder
          Container(
            width: 80.r,
            height: 80.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF4081), // Pinkish red background from design
            ),
            child: Center(
              child: Image.asset(
                'assets/images/kavoosh/khodsanji/reiazi_logo.png', // Placeholder, should be dynamic
                width: 50.r,
                height: 50.r,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              widget.title,
              style: MyTextStyle.textHeader16Bold,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 32.h),

          // Slider Section
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: MyColors.primary,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    thumbColor: MyColors.primary,
                    overlayColor: MyColors.primary.withValues(alpha: 0.2),
                    trackHeight: 4.0.h,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 10.0.r),
                    overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 20.0.r),
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 40,
                    divisions: 40,
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
                      Text('۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
                      Text('۲۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
                      Text('۴۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
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
              onPressed: widget.onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F445A), // Dark button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'بزن بریم!',
                style: MyTextStyle.textHeader16Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
