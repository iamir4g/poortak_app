import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/quiz_list_bloc/quiz_list_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_quiz_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/question_count_modal.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_grade_card.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';

class SelfAssessmentQuizzesScreen extends StatefulWidget {
  static const String routeName = '/self-assessment-quizzes';

  final String categoryId;
  final String categoryTitle;

  const SelfAssessmentQuizzesScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<SelfAssessmentQuizzesScreen> createState() =>
      _SelfAssessmentQuizzesScreenState();
}

class _SelfAssessmentQuizzesScreenState
    extends State<SelfAssessmentQuizzesScreen> {
  late final QuizListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = locator<QuizListBloc>()
      ..add(FetchQuizListEvent(categoryId: widget.categoryId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _refresh() {
    _bloc.add(FetchQuizListEvent(categoryId: widget.categoryId));
  }

  Future<bool> _ensureLoggedIn() async {
    final isLoggedIn = locator<PrefsOperator>().isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
          duration: Duration(seconds: 2),
        ),
      );
      await Navigator.pushNamed(context, LoginScreen.routeName);
      if (!mounted) return false;
      return locator<PrefsOperator>().isLoggedIn();
    }
    return true;
  }

  void _openQuiz(QuizSummary quiz, {required int questionCount}) {
    Navigator.pushNamed(
      context,
      SelfAssessmentQuizScreen.routeName,
      arguments: {
        'quizId': quiz.id,
        'title': quiz.title,
        'questionCount': questionCount,
      },
    ).then((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _onQuizTap(QuizSummary quiz) async {
    final loggedIn = await _ensureLoggedIn();
    if (!loggedIn || !mounted) return;

    final lastAttempt = quiz.lastAttempt;
    if (lastAttempt != null && lastAttempt.isInProgress) {
      _openQuiz(
        quiz,
        questionCount: lastAttempt.questionCount > 0
            ? lastAttempt.questionCount
            : quiz.questionCount,
      );
      return;
    }

    final maxQuestions = quiz.questionCount < 1 ? 1 : quiz.questionCount;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: QuestionCountModal(
          title: quiz.title,
          maxQuestions: maxQuestions,
          initialCount: maxQuestions < 20 ? maxQuestions : 20,
          thumbnailId: quiz.thumbnailId,
          onStart: (count) {
            Navigator.pop(dialogContext);
            _openQuiz(quiz, questionCount: count);
          },
        ),
      ),
    );
  }

  String? _subtitleFor(QuizSummary quiz) {
    final count = quiz.questionCount;
    if (count <= 0) return null;
    return '${toPersianDigits(count.toString())} سوال';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor:
            isDark ? MyColors.darkBackground : MyColors.background3,
        appBar: PoortakAppBar(
          title: widget.categoryTitle,
          foregroundColor:
              isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
        ),
        body: BlocBuilder<QuizListBloc, QuizListState>(
          builder: (context, state) {
            if (state is QuizListLoading || state is QuizListInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizListError) {
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
                        onPressed: _refresh,
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

            if (state is QuizListLoaded) {
              if (state.quizzes.isEmpty) {
                return Center(
                  child: Text(
                    'آزمونی یافت نشد',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color:
                          isDark ? MyColors.darkTextPrimary : MyColors.text3,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: state.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = state.quizzes[index];
                  return SelfAssessmentGradeCard(
                    title: quiz.title,
                    subtitle: _subtitleFor(quiz),
                    lastAttempt: quiz.lastAttempt,
                    onTap: () => _onQuizTap(quiz),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
