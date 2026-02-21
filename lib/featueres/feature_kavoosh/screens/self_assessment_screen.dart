import 'package:flutter/material.dart';
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
                const Text(
                  'خودسنجی',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29303D),
                  ),
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
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
