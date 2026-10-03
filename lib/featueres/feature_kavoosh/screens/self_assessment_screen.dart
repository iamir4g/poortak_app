import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/quiz_categories_bloc/quiz_categories_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_quizzes_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_subject_card.dart';
import 'package:poortak/locator.dart';

class SelfAssessmentScreen extends StatelessWidget {
  static const String routeName = '/self-assessment';

  const SelfAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) =>
          locator<QuizCategoriesBloc>()..add(FetchQuizCategoriesEvent()),
      child: Scaffold(
        backgroundColor:
            isDark ? MyColors.darkBackground : MyColors.background3,
        appBar: PoortakAppBar(
          title: 'خودسنجی',
          titleStyle: MyTextStyle.textMatn16Bold,
          foregroundColor:
              isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<QuizCategoriesBloc, QuizCategoriesState>(
            builder: (context, state) {
              if (state is QuizCategoriesLoading ||
                  state is QuizCategoriesInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is QuizCategoriesError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.text3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<QuizCategoriesBloc>()
                                .add(FetchQuizCategoriesEvent());
                          },
                          child: Text(
                            'تلاش مجدد',
                            style: MyTextStyle.textMatn14Bold
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is QuizCategoriesLoaded) {
                if (state.categories.isEmpty) {
                  return Center(
                    child: Text(
                      'دسته‌بندی‌ای یافت نشد',
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color:
                            isDark ? MyColors.darkTextPrimary : MyColors.text3,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return SelfAssessmentSubjectCard(
                        title: category.title,
                        thumbnailId: category.thumbnailId,
                        backgroundColor: MyColors.background,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            SelfAssessmentQuizzesScreen.routeName,
                            arguments: {
                              'categoryId': category.id,
                              'categoryTitle': category.title,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
