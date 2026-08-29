import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_subject_card.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_grades_screen.dart';

class SelfAssessmentScreen extends StatelessWidget {
  static const String routeName = '/self-assessment';

  const SelfAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> subjects = [
      {
        'title': 'ریاضی',
        'icon': 'assets/images/kavoosh/khodsanji/reiazi_logo.png',
        'color': MyColors.background,
      },
      {
        'title': 'علوم تجربی',
        'icon': 'assets/images/kavoosh/khodsanji/olom_logo.png',
        'color': MyColors.background,
      },
      {
        'title': 'فارسی',
        'icon': 'assets/images/kavoosh/khodsanji/farsi_logo.png',
        'color': MyColors.background,
      },
      {
        'title': 'نگارش',
        'icon': 'assets/images/kavoosh/khodsanji/negaresh_logo.png',
        'color': MyColors.background,
      },
      {
        'title': 'انگلیسی',
        'icon': 'assets/images/kavoosh/khodsanji/english_logo.png',
        'color': MyColors.background,
      },
      {
        'title': 'عربی',
        'icon': 'assets/images/kavoosh/khodsanji/arabi_logo.png',
        'color': MyColors.background,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background3,
      appBar: PoortakAppBar(
        title: 'خودسنجی',
        titleStyle: MyTextStyle.textMatn16Bold,
        foregroundColor:
            isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.0.r),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.1,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return SelfAssessmentSubjectCard(
                title: subject['title'],
                iconPath: subject['icon'],
                backgroundColor: subject['color'],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    SelfAssessmentGradesScreen.routeName,
                    arguments: {'subjectTitle': subject['title']},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
