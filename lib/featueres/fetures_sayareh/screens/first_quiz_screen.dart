import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_question.dart';
import 'package:poortak/locator.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(33.5),
                      bottomRight: Radius.circular(33.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 24, left: 16, right: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Color(0xFF3D495C)),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.title,
                          style: MyTextStyle.textHeader16Bold,
                        ),
                        const Spacer(flex: 2),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 32),
                              // Question Text
                              Text(
                                state.question.data.title,
                                textAlign: TextAlign.center,
                                style: MyTextStyle.textHeader16Bold,
                              ),

                              const SizedBox(height: 32),
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
                                    const SizedBox(height: 16),
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
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    decoration: BoxDecoration(
                                      color: MyColors.cardBackground1,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      answerState.explanation!,
                                      style:
                                          MyTextStyle.textMatn12W500.copyWith(
                                        color: MyColors.textMatn1,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (answerState is QuizAnswerLoaded &&
                                  answerState.isCorrect)
                                (Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDFAEB),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(Icons.check_circle,
                                              color: Color(0xFF6FC845),
                                              size: 40),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'آفرین درست گفتی!🥳',
                                          style: TextStyle(
                                            fontFamily: 'IRANSans',
                                            fontWeight: FontWeight.w300,
                                            fontSize: 12,
                                            color: Color(0xFF3D495C),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ))),
                              // Button logic
                              if (selectedAnswerId != null &&
                                  answerState is! QuizAnswerLoaded)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 176,
                                      height: 54,
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
                                                BorderRadius.circular(30),
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_ios,
                                                color: Colors.white, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (answerState is QuizAnswerLoaded)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 176,
                                      height: 54,
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
                                                BorderRadius.circular(30),
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_ios,
                                                color: Colors.white, size: 18),
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
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
