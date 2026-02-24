import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_subject_card.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_grades_screen.dart';

class SelfAssessmentScreen extends StatelessWidget {
  static const String routeName = '/self-assessment';

  const SelfAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'خودسنجی',
                  style: MyTextStyle.textMatn16Bold.copyWith(
                    color: const Color(0xFF29303D),
                  ),
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
