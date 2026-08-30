import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/answer_feedback_sound_service.dart';
import 'package:poortak/common/services/haptic_service.dart';
import 'package:poortak/common/utils/bidi_text_helper.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/quiz_result_modal.dart';
import 'package:poortak/featueres/feature_sayareh/screens/quiz_screen.dart';
import 'package:poortak/featueres/feature_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/quiz_question_layout.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/item_question.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';

class FirstQuizScreen extends StatefulWidget {
  static const routeName = "/first-quiz";
  final String quizId;
  final String courseId;
  final String title;
  const FirstQuizScreen({
    super.key,
    required this.quizId,
    required this.courseId,
    required this.title,
  });

  @override
  State<FirstQuizScreen> createState() => _FirstQuizScreenState();
}

class _FirstQuizScreenState extends State<FirstQuizScreen> {
  String? selectedAnswerId;
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
    context.read<QuizStartBloc>().add(
          StartQuizEvent(
            courseId: widget.courseId,
            quizId: widget.quizId,
          ),
        );
  }

  void _handleAuthError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Future<void> _leaveQuiz() async {
    try {
      await locator<SayarehRepository>()
          .deleteQuizResult(widget.courseId, widget.quizId);
    } catch (_) {
      // Still leave the quiz even if delete fails (e.g. 404 when no result exists).
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

  Widget? _buildFirstQuizBottomButton({
    required BuildContext context,
    required QuizAnswerState answerState,
    required QuizResultState resultState,
    required bool isDark,
    required String questionId,
  }) {
    if (selectedAnswerId != null && answerState is! QuizAnswerLoaded) {
      return _buildQuizActionButton(
        context: context,
        label: 'بررسی پاسخ',
        backgroundColor: MyColors.primary,
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
        backgroundColor: MyColors.primary,
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            QuizScreen.routeName,
            arguments: {
              'quizId': widget.quizId,
              'courseId': widget.courseId,
              'title': widget.title,
              'initialQuestion': answerState.nextQuestion,
            },
          );
        },
      );
    }

    if (answerState is QuizAnswerLoaded && answerState.isLastQuestion) {
      return _buildQuizActionButton(
        context: context,
        label: 'مشاهده نتیجه',
        backgroundColor: MyColors.primary,
        onPressed: resultState is QuizResultLoading ? null : _fetchQuizResult,
      );
    }

    return null;
  }

  Widget _buildQuizActionButton({
    required BuildContext context,
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 176.w,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
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
            child: BlocConsumer<QuizStartBloc, QuizStartState>(
              listener: (context, state) {
                if (state is QuizStartError) {
                  if (state.message.contains('Please login') ||
                      state.message.contains('Session expired')) {
                    _handleAuthError(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                if (state is QuizStartLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is QuizStartLoaded) {
                  return BlocConsumer<QuizAnswerBloc, QuizAnswerState>(
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
                          AnswerFeedbackSoundService.play(
                            answerState.isCorrect,
                          ),
                        );
                        if (!answerState.isCorrect) {
                          unawaited(HapticService.wrongAnswerFeedback());
                        }
                      }
                    },
                    builder: (context, answerState) {
                      return BlocBuilder<QuizResultBloc, QuizResultState>(
                        builder: (context, resultState) {
                          return Stack(
                            children: [
                              QuizQuestionLayout(
                                question: BidiText(
                                  text: state.question.data.title,
                                  forceEnglishDigits: true,
                                  textAlign: TextAlign.center,
                                  style: MyTextStyle.textHeader16Bold.copyWith(
                                    color: isDark
                                        ? MyColors.profileTextPrimaryDark
                                        : MyColors.textMatn1,
                                  ),
                                ),
                                options: QuizAnswerOptionsList(
                                  answerCount:
                                      state.question.data.answers.length,
                                  itemBuilder: (
                                    index, {
                                    required height,
                                    required large,
                                  }) {
                                    final answer =
                                        state.question.data.answers[index];
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
                                        selectedAnswerId:
                                            feedbackAnswerId ?? "",
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
                                            explanation:
                                                answerState.explanation!,
                                          )
                                        : answerState.isCorrect
                                            ? buildQuizCorrectFeedback(
                                                isDark: isDark,
                                              )
                                            : null)
                                    : null,
                                bottomButton: _buildFirstQuizBottomButton(
                                  context: context,
                                  answerState: answerState,
                                  resultState: resultState,
                                  isDark: isDark,
                                  questionId: state.question.data.id,
                                ),
                              ),
                              if (resultState is QuizResultLoading &&
                                  _hasRequestedResult)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                  );
                } else if (state is QuizStartError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: MyTextStyle.textMatn15.copyWith(
                          color: isDark
                              ? MyColors.profileTextPrimaryDark
                              : const Color(0xFF3D495C),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}
