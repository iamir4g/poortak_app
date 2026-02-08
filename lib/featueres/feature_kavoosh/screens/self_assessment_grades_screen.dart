import 'package:flutter/material.dart';
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
        preferredSize: const Size.fromHeight(57),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(33.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
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
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF29303D),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return SelfAssessmentGradeCard(
            title: grades[index],
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
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
