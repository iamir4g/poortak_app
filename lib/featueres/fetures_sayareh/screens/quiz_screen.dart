import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/utils/font_size_helper.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quiz_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/first_quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/quiz_result_modal.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_question.dart';
import 'package:poortak/locator.dart';
import 'dart:developer';

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

  @override
  void initState() {
    super.initState();
    // Initialize with the provided question
    currentQuestion = widget.initialQuestion;
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
            // Custom Header (copied from FirstQuizScreen)
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
              child: BlocListener<QuizAnswerBloc, QuizAnswerState>(
                listener: (context, answerState) {
                  if (answerState is QuizAnswerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(answerState.message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (answerState is QuizAnswerComplete) {
                    // Optionally show a loading indicator or a message
                    context.read<QuizResultBloc>().add(FetchQuizResultEvent(
                          courseId: widget.courseId,
                          quizId: widget.quizId,
                        ));
                  } else if (answerState is QuizAnswerLoaded) {
                    // If nextQuestion is null, quiz is finished
                    if (answerState.nextQuestion == null) {
                      context.read<QuizResultBloc>().add(FetchQuizResultEvent(
                            courseId: widget.courseId,
                            quizId: widget.quizId,
                          ));
                    } else {
                      setState(() {
                        currentQuestion = answerState.nextQuestion!;
                        selectedAnswerId = null;
                        isSelected = false;
                        isCorrectAnswer = false;
                        isWrongSelected = false;
                      });
                      context.read<QuizAnswerBloc>().emit(QuizAnswerInitial());
                    }
                  }
                },
                child: BlocListener<QuizResultBloc, QuizResultState>(
                  listener: (context, state) {
                    if (state is QuizResultError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Navigate back to quiz list on error
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (state is QuizResultLoaded) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => QuizResultModal(
                          totalQuestions: state.totalQuestions,
                          correctAnswers: state.correctAnswers,
                          score: state.score,
                          courseId: widget.courseId,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<QuizAnswerBloc, QuizAnswerState>(
                    builder: (context, answerState) {
                      if (answerState is QuizAnswerComplete) {
                        // Optionally show a loading indicator or a message
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Use currentQuestion for rendering
                      final questionData = currentQuestion.data;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            // Question Text
                            Text(
                              questionData.title,
                              textAlign: TextAlign.center,
                              style: FontSizeHelper.getContentTextStyle(
                                context,
                                baseFontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            const SizedBox(height: 32),
                            // Answer Options
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemCount: questionData.answers.length,
                              itemBuilder: (context, index) {
                                final answer = questionData.answers[index];
                                isSelected = selectedAnswerId == answer.id;
                                if (answerState is QuizAnswerLoaded &&
                                    answerState.selectedAnswerId == answer.id) {
                                  isCorrectAnswer = answer.id ==
                                          answerState.correctAnswerId &&
                                      answerState.isCorrect;
                                  isWrongSelected = answer.id ==
                                          answerState.selectedAnswerId &&
                                      !answerState.isCorrect;
                                } else {
                                  isCorrectAnswer = false;
                                  isWrongSelected = false;
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 0),
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
                                    style: MyTextStyle.textMatn12W500.copyWith(
                                      color: MyColors.textMatn1,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else if (answerState is QuizAnswerLoaded &&
                                answerState.isCorrect)
                              (Column(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDFAEB),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(Icons.check_circle,
                                        color: Color(0xFF6FC845), size: 40),
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
                              )),
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
                                                      courseId: widget.courseId,
                                                      quizId: widget.quizId,
                                                      questionId:
                                                          questionData.id,
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
                          ],
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
    );
  }
}
