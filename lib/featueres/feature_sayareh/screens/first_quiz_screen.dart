import 'dart:async';
import 'dart:developer';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackgroundColor =
        isDark ? MyColors.profileBackgroundDark : Colors.white;
    final primaryTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

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
                              Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 32.h),
                                          BidiText(
                                            text: state.question.data.title,
                                            forceEnglishDigits: true,
                                            textAlign: TextAlign.center,
                                            style: MyTextStyle.textHeader16Bold
                                                .copyWith(
                                              color: isDark
                                                  ? MyColors
                                                      .profileTextPrimaryDark
                                                  : MyColors.textMatn1,
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: SingleChildScrollView(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 32.h,
                                                ),
                                                child: QuizAnswerOptionsList(
                                                  answerCount: state.question
                                                      .data.answers.length,
                                                  itemBuilder: (
                                                    index, {
                                                    required height,
                                                    required large,
                                                  }) {
                                                    final answer = state
                                                        .question
                                                        .data
                                                        .answers[index];
                                                    final feedbackAnswerId =
                                                        answerState
                                                                is QuizAnswerLoaded
                                                            ? answerState
                                                                .selectedAnswerId
                                                            : selectedAnswerId;
                                                    final isAnswerSelected =
                                                        feedbackAnswerId ==
                                                            answer.id;
                                                    var isCorrectAnswer = false;
                                                    var isWrongSelected = false;
                                                    if (answerState
                                                        is QuizAnswerLoaded) {
                                                      isCorrectAnswer =
                                                          answer.id ==
                                                              answerState
                                                                  .correctAnswerId;
                                                      isWrongSelected =
                                                          isAnswerSelected &&
                                                              !answerState
                                                                  .isCorrect;
                                                    }
                                                    return InkWell(
                                                      onTap: answerState
                                                                  is QuizAnswerLoading ||
                                                              answerState
                                                                  is QuizAnswerLoaded
                                                          ? null
                                                          : () {
                                                              setState(() {
                                                                selectedAnswerId =
                                                                    answer.id;
                                                              });
                                                            },
                                                      child: QuizAnswerItem(
                                                        key: ValueKey(
                                                            answer.id),
                                                        title: answer.title,
                                                        id: answer.id,
                                                        isSelected:
                                                            isAnswerSelected,
                                                        isCorrect:
                                                            isCorrectAnswer,
                                                        isWrongSelected:
                                                            isWrongSelected,
                                                        selectedAnswerId:
                                                            feedbackAnswerId ??
                                                                "",
                                                        showFeedback:
                                                            answerState
                                                                is QuizAnswerLoaded,
                                                        height: height,
                                                        large: large,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                    ),
                                    child: Column(
                                      children: [
                                    if (answerState is QuizAnswerLoaded &&
                                        !answerState.isCorrect &&
                                        answerState.explanation != null)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 16.0.h),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.h, horizontal: 16.w),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? MyColors.termsBackgroundDark
                                                : MyColors.cardBackground1,
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: BidiText(
                                            text: answerState.explanation!,
                                            style: MyTextStyle.textMatn12W500
                                                .copyWith(
                                              color: isDark
                                                  ? MyColors
                                                      .profileTextPrimaryDark
                                                  : MyColors.textMatn1,
                                              fontSize: 13.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    else if (answerState is QuizAnswerLoaded &&
                                        answerState.isCorrect)
                                      (Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 16.0.h),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 54.w,
                                                height: 54.h,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? MyColors
                                                          .quizAnswerCorrectBackgroundDark
                                                      : MyColors
                                                          .quizAnswerCorrectBackgroundLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r),
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: isDark
                                                      ? MyColors
                                                          .quizAnswerCorrectTextDark
                                                      : MyColors
                                                          .quizAnswerCorrectBorderLight,
                                                  size: 40.r,
                                                ),
                                              ),
                                              SizedBox(height: 12.h),
                                              Text(
                                                'آفرین درست گفتی!🥳',
                                                style: TextStyle(
                                                  fontFamily: 'IRANSans',
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 12.sp,
                                                  color: isDark
                                                      ? MyColors
                                                          .quizAnswerCorrectTextDark
                                                      : MyColors.text2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ))),
                                    // Button logic
                                    if (selectedAnswerId != null &&
                                        answerState is! QuizAnswerLoaded)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 24.0.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 176.w,
                                            height: 54.h,
                                            child: ElevatedButton(
                                              onPressed: answerState
                                                      is QuizAnswerLoading
                                                  ? null
                                                  : () {
                                                      context
                                                          .read<
                                                              QuizAnswerBloc>()
                                                          .add(
                                                            SubmitAnswerEvent(
                                                              courseId: widget
                                                                  .courseId,
                                                              quizId:
                                                                  widget.quizId,
                                                              questionId: state
                                                                  .question
                                                                  .data
                                                                  .id,
                                                              answerId:
                                                                  selectedAnswerId!,
                                                            ),
                                                          );
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.primary,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                disabledForegroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(alpha: 0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.r),
                                                ),
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "بررسی پاسخ",
                                                    style: MyTextStyle
                                                            .textMatnBtnFor(
                                                                context)
                                                        .copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.arrow_forward_ios,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      size: 18.r),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (answerState is QuizAnswerLoaded &&
                                        !answerState.isLastQuestion)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 24.0.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 176.w,
                                            height: 54.h,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  QuizScreen.routeName,
                                                  arguments: {
                                                    'quizId': widget.quizId,
                                                    'courseId': widget.courseId,
                                                    'title': widget.title,
                                                    'initialQuestion':
                                                        answerState
                                                            .nextQuestion,
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MyColors.primary,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.r),
                                                ),
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "بعدی",
                                                    style: MyTextStyle
                                                            .textMatnBtnFor(
                                                                context)
                                                        .copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.arrow_forward_ios,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      size: 18.r),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (answerState is QuizAnswerLoaded &&
                                        answerState.isLastQuestion)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 24.0.h),
                                        child: Center(
                                          child: SizedBox(
                                            width: 176.w,
                                            height: 54.h,
                                            child: ElevatedButton(
                                              onPressed: resultState
                                                      is QuizResultLoading
                                                  ? null
                                                  : _fetchQuizResult,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFFF9F29),
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.r),
                                                ),
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "مشاهده نتیجه",
                                                    style: MyTextStyle
                                                            .textMatnBtnFor(
                                                                context)
                                                        .copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.arrow_forward_ios,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      size: 18.r),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                        SizedBox(height: 24.h),
                                      ],
                                    ),
                                  ),
                                ],
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
