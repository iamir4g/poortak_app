import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/services/answer_feedback_sound_service.dart';
import 'package:poortak/common/services/haptic_service.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/quiz_question_model.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/quiz_result_modal.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/quiz_question_layout.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/item_question.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/feature_sayareh/screens/quizzes_screen.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = "/quiz";
  final String quizId;
  final String courseId;
  final String title;
  final QuizesQuestion initialQuestion;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.courseId,
    required this.title,
    required this.initialQuestion,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? selectedAnswerId;
  bool isSelected = false;
  bool isCorrectAnswer = false;
  bool isWrongSelected = false;
  late QuizesQuestion currentQuestion;
  bool _isExitDialogOpen = false;
  bool _canPop = false;
  bool _isResultModalOpen = false;
  bool _hasRequestedResult = false;

  void _fetchQuizResult() {
    setState(() => _hasRequestedResult = true);
    context.read<QuizResultBloc>().add(FetchQuizResultEvent(
          courseId: widget.courseId,
          quizId: widget.quizId,
        ));
  }

  void _showQuizResultModal(QuizResultLoaded state) {
    if (_isResultModalOpen || !mounted) return;
    _isResultModalOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => QuizResultModal(
        totalQuestions: state.totalQuestions,
        correctAnswers: state.correctAnswers,
        score: state.score,
        courseId: widget.courseId,
        quizId: widget.quizId,
      ),
    ).whenComplete(() {
      _isResultModalOpen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with the provided question
    currentQuestion = widget.initialQuestion;
  }

  Future<void> _leaveQuiz() async {
    try {
      await locator<SayarehRepository>()
          .deleteQuizResult(widget.courseId, widget.quizId);
    } catch (_) {
      // Still leave the quiz even if delete fails.
    }

    if (!mounted) return;
    _navigateBackToQuizList();
  }

  void _navigateBackToQuizList() {
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == QuizzesScreen.routeName || route.isFirst,
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
          'با ترک آزمون، پاسخ های فعلی شما حذف می شود و باید دفعه ی بعد دوباره به آنها پاسخ دهید',
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
        _leaveQuiz();
      },
    ).whenComplete(() {
      _isExitDialogOpen = false;
    });
  }

  Widget? _buildQuizBottomButton({
    required BuildContext context,
    required QuizAnswerState answerState,
    required QuizResultState resultState,
    required String questionId,
  }) {
    if (selectedAnswerId != null && answerState is! QuizAnswerLoaded) {
      return _buildQuizActionButton(
        context: context,
        label: 'بررسی پاسخ',
        onPressed: answerState is QuizAnswerLoading
            ? null
            : () {
                context.read<QuizAnswerBloc>().add(
                      SubmitAnswerEvent(
                        courseId: widget.courseId,
                        quizId: widget.quizId,
                        questionId: questionId,
                        answerId: selectedAnswerId!,
                      ),
                    );
              },
      );
    }

    if (answerState is QuizAnswerLoaded && !answerState.isLastQuestion) {
      return _buildQuizActionButton(
        context: context,
        label: 'بعدی',
        onPressed: () {
          setState(() {
            currentQuestion = answerState.nextQuestion!;
            selectedAnswerId = null;
            isSelected = false;
            isCorrectAnswer = false;
            isWrongSelected = false;
          });
          context.read<QuizAnswerBloc>().add(const ResetQuizAnswerEvent());
        },
      );
    }

    if (answerState is QuizAnswerLoaded && answerState.isLastQuestion) {
      return _buildQuizActionButton(
        context: context,
        label: 'مشاهده نتیجه',
        onPressed: resultState is QuizResultLoading ? null : _fetchQuizResult,
      );
    }

    return null;
  }

  Widget _buildQuizActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 176,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18,
            ),
          ],
        ),
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
          child: BlocListener<QuizAnswerBloc, QuizAnswerState>(
            listener: (context, answerState) {
              if (answerState is QuizAnswerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(answerState.message),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (answerState is QuizAnswerLoaded) {
                if (answerState.isLastQuestion) {
                  context
                      .read<QuizResultBloc>()
                      .add(const ResetQuizResultEvent());
                }
                setState(() {});
                unawaited(
                  AnswerFeedbackSoundService.play(answerState.isCorrect),
                );
                if (!answerState.isCorrect) {
                  unawaited(HapticService.wrongAnswerFeedback());
                }
              }
            },
            child: BlocListener<QuizResultBloc, QuizResultState>(
              listenWhen: (previous, current) =>
                  current is QuizResultLoaded || current is QuizResultError,
              listener: (context, state) {
                if (state is QuizResultError) {
                  setState(() => _hasRequestedResult = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      duration: const Duration(seconds: 2),
                      backgroundColor: MyColors.error,
                    ),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else if (state is QuizResultLoaded && _hasRequestedResult) {
                  _showQuizResultModal(state);
                }
              },
              child: BlocBuilder<QuizResultBloc, QuizResultState>(
                builder: (context, resultState) {
                  return BlocBuilder<QuizAnswerBloc, QuizAnswerState>(
                    builder: (context, answerState) {
                      final questionData = currentQuestion.data;
                      return Stack(
                        children: [
                          QuizQuestionLayout(
                            question: BidiText(
                              text: questionData.title,
                              forceEnglishDigits: true,
                              textAlign: TextAlign.center,
                              style: FontSizeHelper.getContentTextStyle(
                                context,
                                baseFontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? MyColors.profileTextPrimaryDark
                                    : MyColors.textMatn1,
                              ),
                            ),
                            options: QuizAnswerOptionsList(
                              answerCount: questionData.answers.length,
                              itemBuilder: (
                                index, {
                                required height,
                                required large,
                              }) {
                                final answer = questionData.answers[index];
                                final feedbackAnswerId =
                                    answerState is QuizAnswerLoaded
                                        ? answerState.selectedAnswerId
                                        : selectedAnswerId;
                                final isAnswerSelected =
                                    feedbackAnswerId == answer.id;
                                var isCorrectAnswer = false;
                                var isWrongSelected = false;
                                if (answerState is QuizAnswerLoaded) {
                                  isCorrectAnswer = answer.id ==
                                      answerState.correctAnswerId;
                                  isWrongSelected = isAnswerSelected &&
                                      !answerState.isCorrect;
                                }
                                return InkWell(
                                  onTap: answerState is QuizAnswerLoading ||
                                          answerState is QuizAnswerLoaded
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
                                    selectedAnswerId: feedbackAnswerId ?? "",
                                    showFeedback:
                                        answerState is QuizAnswerLoaded,
                                    height: height,
                                    large: large,
                                  ),
                                );
                              },
                            ),
                            feedback: answerState is QuizAnswerLoaded
                                ? (!answerState.isCorrect &&
                                        answerState.explanation != null
                                    ? buildQuizWrongFeedback(
                                        isDark: isDark,
                                        explanation: answerState.explanation!,
                                      )
                                    : answerState.isCorrect
                                        ? buildQuizCorrectFeedback(
                                            isDark: isDark,
                                          )
                                        : null)
                                : null,
                            bottomButton: _buildQuizBottomButton(
                              context: context,
                              answerState: answerState,
                              resultState: resultState,
                              questionId: questionData.id,
                            ),
                          ),
                      if (resultState is QuizResultLoading &&
                          _hasRequestedResult)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.25),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  MyColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
