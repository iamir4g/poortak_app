import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_grade_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/question_count_modal.dart';

class SelfAssessmentGradesScreen extends StatelessWidget {
  static const String routeName = '/self-assessment-grades';
  final String subjectTitle;

  const SelfAssessmentGradesScreen({
    super.key,
    required this.subjectTitle,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> grades = [
      'پایه اول',
      'پایه دوم',
      'پایه سوم',
      'پایه چهارم',
      'پایه پنجم',
      'پایه ششم',
      'پایه هقتم',
      'پایه هشتم',
      'پایه نهم',
      'پایه دهم',
      'پایه یازدهم',
    ];

    return Scaffold(
      backgroundColor: MyColors.background3,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(57.h),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
            height: 57.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(33.5.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: Offset(0, 1.h),
                  blurRadius: 1.r,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آزمون $subjectTitle',
                  style: MyTextStyle.textHeader16Bold,
                ),
                SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: const Color(0xFF29303D),
                      size: 28.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return SelfAssessmentGradeCard(
            title: grades[index],
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: QuestionCountModal(
                    title: 'آزمون $subjectTitle ${grades[index]}',
                    onStart: () {
                      Navigator.pop(context); // Close modal
                      // Navigate to questions screen
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
