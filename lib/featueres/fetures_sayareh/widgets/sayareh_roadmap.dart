import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SayarehRoadmap extends StatelessWidget {
  const SayarehRoadmap({super.key});

  static const _steps = <_RoadmapStep>[
    _RoadmapStep(label: 'زمین', icon: Icons.public_rounded, active: true),
    _RoadmapStep(label: 'جنگل', icon: Icons.park_rounded, active: true),
    _RoadmapStep(label: 'شهر', icon: Icons.location_city_rounded, active: false),
    _RoadmapStep(label: 'مدرسه', icon: Icons.school_rounded, active: false),
    _RoadmapStep(label: 'آی نو', icon: Icons.rocket_launch_rounded, active: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 52.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              MyColors.sayarehHomeRoadmapActive,
                              MyColors.sayarehHomeRoadmapActive
                                  .withValues(alpha: 0.55),
                              MyColors.sayarehHomeRoadmapInactive
                                  .withValues(alpha: 0.5),
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _steps
                      .map(
                        (step) => _RoadmapNode(
                          step: step,
                          isDark: isDark,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _steps
                .map(
                  (step) => SizedBox(
                    width: 56.w,
                    child: Text(
                      step.label,
                      textAlign: TextAlign.center,
                      style: MyTextStyle.textMatn10W300.copyWith(
                        fontWeight: FontWeight.w600,
                        color: step.active
                            ? (isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.text1)
                            : (isDark
                                ? MyColors.darkTextSecondary
                                : MyColors.text5),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStep {
  final String label;
  final IconData icon;
  final bool active;

  const _RoadmapStep({
    required this.label,
    required this.icon,
    required this.active,
  });
}

class _RoadmapNode extends StatelessWidget {
  final _RoadmapStep step;
  final bool isDark;

  const _RoadmapNode({
    required this.step,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = step.active
        ? MyColors.sayarehHomeRoadmapActive
        : (isDark
            ? MyColors.darkBackgroundSecondary
            : MyColors.sayarehHomeRoadmapInactive.withValues(alpha: 0.35));
    final iconColor = step.active
        ? Colors.white
        : (isDark ? MyColors.darkTextSecondary : MyColors.text5);

    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: step.active
            ? [
                BoxShadow(
                  color: MyColors.sayarehHomeRoadmapActive.withValues(alpha: 0.35),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ]
            : null,
      ),
      child: Icon(step.icon, size: 20.r, color: iconColor),
    );
  }
}
