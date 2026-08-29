import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background3,
      appBar: PoortakAppBar(
        title: 'آزمون $subjectTitle',
        foregroundColor:
            isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
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
