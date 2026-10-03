import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/answer_feedback_sound_service.dart';
import 'package:poortak/common/services/haptic_service.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/quiz_session_bloc/quiz_session_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_quizzes_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/self_assessment_quiz_result_modal.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/item_question.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/quiz_question_layout.dart';

class SelfAssessmentQuizScreen extends StatefulWidget {
  static const String routeName = '/self-assessment-quiz';

  final String quizId;
  final String title;
  final int questionCount;

  const SelfAssessmentQuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    required this.questionCount,
  });

  @override
  State<SelfAssessmentQuizScreen> createState() =>
      _SelfAssessmentQuizScreenState();
}

class _SelfAssessmentQuizScreenState extends State<SelfAssessmentQuizScreen> {
  String? selectedAnswerId;
  bool _isExitDialogOpen = false;
  bool _canPop = false;
  bool _isResultModalOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<QuizSessionBloc>().add(
          StartQuizSessionEvent(
            quizId: widget.quizId,
            questionCount: widget.questionCount,
          ),
        );
  }

  bool _isAuthErrorMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('please login') ||
        lower.contains('session expired') ||
        lower.contains('unauthorized') ||
        message.contains('وارد') ||
        message.contains('احراز');
  }

  void _handleAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void _navigateBackToQuizList() {
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == SelfAssessmentQuizzesScreen.routeName ||
            route.isFirst,
      );
    });
  }

  void _showExitModal() {
    if (_isExitDialogOpen) return;
    _isExitDialogOpen = true;

    ReusableModal.show(
      context: context,
      title: 'ترک آزمون',
      message:
          'با ترک آزمون می‌توانید بعداً از همان‌جا ادامه دهید. آیا مطمئن هستید؟',
      type: ModalType.info,
      buttonText: 'ماندن',
      secondButtonText: 'ترک آزمون',
      showSecondButton: true,
      barrierDismissible: false,
      onButtonPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      onSecondButtonPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _navigateBackToQuizList();
      },
    ).whenComplete(() {
      _isExitDialogOpen = false;
    });
  }

  void _showResultModal(QuizAttemptResult result) {
    if (_isResultModalOpen || !mounted) return;
    _isResultModalOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => SelfAssessmentQuizResultModal(
        totalQuestions: result.questionCount,
        correctAnswers: result.correct,
        wrongAnswers: result.wrong,
        score: result.score,
      ),
    ).whenComplete(() {
      _isResultModalOpen = false;
    });
  }

  Widget? _buildProgress(QuizStats stats, {required bool afterSubmit}) {
    if (stats.total <= 0) return null;
    // After submit, `answered` already includes the current question.
    final current = afterSubmit
        ? stats.answered.clamp(1, stats.total)
        : (stats.answered + 1).clamp(1, stats.total);
    return buildQuizStepProgress(
      context: context,
      currentQuestion: current,
      totalSteps: stats.total,
    );
  }

  Widget? _buildBottomButton({
    required QuizSessionState state,
    required String questionId,
    required String attemptId,
  }) {
    if (state is QuizAnswerFeedback) {
      final label = state.isLastQuestion ? 'مشاهده نتیجه' : 'بعدی';
      return _buildActionButton(
        label: label,
        onPressed: () {
          setState(() => selectedAnswerId = null);
          context.read<QuizSessionBloc>().add(
                LoadNextQuestionEvent(attemptId: state.attemptId),
              );
        },
      );
    }

    if (selectedAnswerId != null && state is! QuizSessionSubmitting) {
      return _buildActionButton(
        label: 'بررسی پاسخ',
        onPressed: state is QuizSessionSubmitting
            ? null
            : () {
                context.read<QuizSessionBloc>().add(
                      SubmitQuizAnswerEvent(
                        attemptId: attemptId,
                        questionId: questionId,
                        answerId: selectedAnswerId!,
                      ),
                    );
              },
      );
    }

    return null;
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 176.w,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: MyTextStyle.textMatnBtnFor(context).copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBody({
    required bool isDark,
    required QuizQuestion question,
    required String attemptId,
    required QuizStats stats,
    required QuizSessionState state,
    required bool showFeedback,
    required bool isCorrect,
    required String correctAnswerId,
    required String feedbackSelectedId,
  }) {
    return QuizQuestionLayout(
      progress: _buildProgress(stats, afterSubmit: showFeedback),
      question: BidiText(
        text: question.title,
        forceEnglishDigits: true,
        textAlign: TextAlign.center,
        style: MyTextStyle.textHeader16Bold.copyWith(
          color: isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1,
        ),
      ),
      options: QuizAnswerOptionsList(
        answerCount: question.answers.length,
        itemBuilder: (index, {required height, required large}) {
          final answer = question.answers[index];
          final isAnswerSelected = feedbackSelectedId == answer.id;
          final isCorrectAnswer = showFeedback && answer.id == correctAnswerId;
          final isWrongSelected =
              showFeedback && isAnswerSelected && !isCorrect;

          return InkWell(
            onTap: showFeedback || state is QuizSessionSubmitting
                ? null
                : () {
                    setState(() {
                      selectedAnswerId = answer.id;
                    });
                  },
            child: QuizAnswerItem(
              key: ValueKey(answer.id),
              title: answer.title,
              id: answer.id,
              isSelected: isAnswerSelected,
              isCorrect: isCorrectAnswer,
              isWrongSelected: isWrongSelected,
              selectedAnswerId: feedbackSelectedId,
              showFeedback: showFeedback,
              height: height,
              large: large,
            ),
          );
        },
      ),
      feedback: showFeedback
          ? (isCorrect
              ? buildQuizCorrectFeedback(isDark: isDark)
              : (question.description != null &&
                      question.description!.isNotEmpty
                  ? buildQuizWrongFeedback(
                      isDark: isDark,
                      explanation: question.description!,
                    )
                  : null))
          : null,
      bottomButton: _buildBottomButton(
        state: state,
        questionId: question.id,
        attemptId: attemptId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackgroundColor =
        isDark ? MyColors.profileBackgroundDark : Colors.white;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isExitDialogOpen) {
          Navigator.of(context, rootNavigator: true).maybePop();
          return;
        }
        _showExitModal();
      },
      child: Scaffold(
        backgroundColor: pageBackgroundColor,
        appBar: PoortakAppBar(
          title: widget.title,
          onBackPressed: _showExitModal,
        ),
        body: SafeArea(
          child: BlocConsumer<QuizSessionBloc, QuizSessionState>(
            listener: (context, state) {
              if (state is QuizSessionError) {
                if (_isAuthErrorMessage(state.message)) {
                  _handleAuthError();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 2),
                    backgroundColor: MyColors.error,
                  ),
                );
              } else if (state is QuizAnswerFeedback) {
                unawaited(
                  AnswerFeedbackSoundService.play(state.answerResult.correct),
                );
                if (!state.answerResult.correct) {
                  unawaited(HapticService.wrongAnswerFeedback());
                }
              } else if (state is QuizSessionFinished) {
                _showResultModal(state.result);
              } else if (state is QuizSessionLoaded) {
                setState(() => selectedAnswerId = null);
              }
            },
            builder: (context, state) {
              if (state is QuizSessionLoading || state is QuizSessionInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is QuizSessionLoaded) {
                final question = state.session.question;
                if (question == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildQuestionBody(
                  isDark: isDark,
                  question: question,
                  attemptId: state.session.attempt.id,
                  stats: state.session.stats,
                  state: state,
                  showFeedback: false,
                  isCorrect: false,
                  correctAnswerId: '',
                  feedbackSelectedId: selectedAnswerId ?? '',
                );
              }

              if (state is QuizSessionSubmitting) {
                return _buildQuestionBody(
                  isDark: isDark,
                  question: state.question,
                  attemptId: state.attemptId,
                  stats: state.stats,
                  state: state,
                  showFeedback: false,
                  isCorrect: false,
                  correctAnswerId: '',
                  feedbackSelectedId: state.selectedAnswerId,
                );
              }

              if (state is QuizAnswerFeedback) {
                return _buildQuestionBody(
                  isDark: isDark,
                  question: state.question,
                  attemptId: state.attemptId,
                  stats: state.stats,
                  state: state,
                  showFeedback: true,
                  isCorrect: state.answerResult.correct,
                  correctAnswerId: state.answerResult.correctAnswerId,
                  feedbackSelectedId: state.selectedAnswerId,
                );
              }

              if (state is QuizSessionError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: isDark
                                ? MyColors.profileTextPrimaryDark
                                : const Color(0xFF3D495C),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QuizSessionBloc>().add(
                                  StartQuizSessionEvent(
                                    quizId: widget.quizId,
                                    questionCount: widget.questionCount,
                                  ),
                                );
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

              if (state is QuizSessionFinished) {
                return const Center(child: CircularProgressIndicator());
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
