import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_question.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

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
        _isExitDialogOpen = false;
        Navigator.of(context, rootNavigator: true).pop();
      },
      onSecondButtonPressed: () {
        _isExitDialogOpen = false;
        Navigator.of(context, rootNavigator: true).pop();
        _leaveQuiz();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackgroundColor =
        isDark ? MyColors.profileBackgroundDark : Colors.white;
    final headerBackgroundColor =
        isDark ? MyColors.darkBackgroundSecondary : Colors.white;
    final primaryTextColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.text2;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitModal();
      },
      child: Scaffold(
      backgroundColor: pageBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: headerBackgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(33.5.r),
                      bottomRight: Radius.circular(33.5.r),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w),
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: _showExitModal,
                          child: Container(
                            width: 34.w,
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: headerBackgroundColor,
                              borderRadius: BorderRadius.circular(17.r),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: primaryTextColor,
                            ),
                          ),
                        ),

                        // Text(
                        //   widget.title,
                        //   style: MyTextStyle.textHeader16Bold,
                        // ),
                        // const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
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
                          // setState(() {
                          //   selectedAnswerId = null;
                          // });
                        }
                      },
                      builder: (context, answerState) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 32.h),
                              // Question Text
                              Text(
                                state.question.data.title,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: MyTextStyle.textHeader16Bold.copyWith(
                                  color: isDark
                                      ? MyColors.profileTextPrimaryDark
                                      : MyColors.textMatn1,
                                ),
                              ),

                              SizedBox(height: 32.h),
                              // Feedback after answer submission
                              // if (answerState is QuizAnswerLoaded)
                              //   Padding(
                              //     padding: const EdgeInsets.only(bottom: 24.0),
                              //     child: Column(
                              //       children: [
                              //         if (answerState.isCorrect)
                              //           Column(
                              //             children: [
                              //               Container(
                              //                 width: 54,
                              //                 height: 54,
                              //                 decoration: BoxDecoration(
                              //                   color: const Color(0xFFEDFAEB),
                              //                   borderRadius:
                              //                       BorderRadius.circular(50),
                              //                 ),
                              //                 child: const Icon(
                              //                     Icons.check_circle,
                              //                     color: Color(0xFF6FC845),
                              //                     size: 40),
                              //               ),
                              //               const SizedBox(height: 12),
                              //               Text(
                              //                 'آفرین درست گفتی!🥳',
                              //                 style: TextStyle(
                              //                   fontFamily: 'IRANSans',
                              //                   fontWeight: FontWeight.w300,
                              //                   fontSize: 12,
                              //                   color: Color(0xFF3D495C),
                              //                 ),
                              //                 textAlign: TextAlign.center,
                              //               ),
                              //             ],
                              //           )
                              //         else
                              //           Column(
                              //             children: [
                              //               Container(
                              //                 width: 54,
                              //                 height: 54,
                              //                 decoration: BoxDecoration(
                              //                   color: const Color(0xFFFDEFE8),
                              //                   borderRadius:
                              //                       BorderRadius.circular(50),
                              //                 ),
                              //                 child: const Icon(Icons.cancel,
                              //                     color: Color(0xFFE96217),
                              //                     size: 40),
                              //               ),
                              //               const SizedBox(height: 12),
                              //               Text(
                              //                 'پاسخ اشتباه بود!',
                              //                 style: TextStyle(
                              //                   fontFamily: 'IRANSans',
                              //                   fontWeight: FontWeight.w300,
                              //                   fontSize: 12,
                              //                   color: Color(0xFFE96217),
                              //                 ),
                              //                 textAlign: TextAlign.center,
                              //               ),
                              //             ],
                              //           ),
                              //       ],
                              //     ),
                              //   ),
                              const SizedBox(height: 32),

                              // Answer Options
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 16.h),
                                itemCount: state.question.data.answers.length,
                                itemBuilder: (context, index) {
                                  final answer =
                                      state.question.data.answers[index];
                                  final isSelected =
                                      selectedAnswerId == answer.id;
                                  // Determine if the answer is correct based on the correctAnswerId
                                  bool isCorrectAnswer = false;
                                  bool isWrongSelected = false;
                                  if (answerState is QuizAnswerLoaded) {
                                    isCorrectAnswer = answer.id ==
                                        answerState.correctAnswerId;
                                    log("selectedAnswerId: $selectedAnswerId");
                                    // Use isCorrect from the response to determine if the selected answer is wrong
                                    isWrongSelected =
                                        isSelected && !answerState.isCorrect;
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
                                      title: answer.title,
                                      id: answer.id,
                                      isSelected: isSelected,
                                      isCorrect: isCorrectAnswer,
                                      isWrongSelected: isWrongSelected,
                                      selectedAnswerId: selectedAnswerId ?? "",
                                      showFeedback:
                                          answerState is QuizAnswerLoaded,
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              // Explanation just above the button
                              if (answerState is QuizAnswerLoaded &&
                                  !answerState.isCorrect &&
                                  answerState.explanation != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.0.h),
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
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      answerState.explanation!,
                                      style:
                                          MyTextStyle.textMatn12W500.copyWith(
                                        color: isDark
                                            ? MyColors.profileTextPrimaryDark
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
                                    padding: EdgeInsets.only(bottom: 16.0.h),
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
                                                BorderRadius.circular(50.r),
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
                                  padding: EdgeInsets.only(bottom: 24.0.h),
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
                                                    .read<QuizAnswerBloc>()
                                                    .add(
                                                      SubmitAnswerEvent(
                                                        courseId:
                                                            widget.courseId,
                                                        quizId: widget.quizId,
                                                        questionId: state
                                                            .question.data.id,
                                                        answerId:
                                                            selectedAnswerId!,
                                                      ),
                                                    );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.r),
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
                                              style: MyTextStyle.textMatnBtn
                                                  .copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Icon(Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 18.r),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (answerState is QuizAnswerLoaded)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 24.0.h),
                                  child: Center(
                                    child: SizedBox(
                                      width: 176.w,
                                      height: 54.h,
                                      child: ElevatedButton(
                                        onPressed: answerState.nextQuestion !=
                                                null
                                            ? () {
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
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.r),
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
                                              style: MyTextStyle.textMatnBtn
                                                  .copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Icon(Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 18.r),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
          ],
        ),
      ),
    ),
    );
  }
}
