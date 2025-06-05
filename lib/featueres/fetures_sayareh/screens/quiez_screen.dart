import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quiez_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiz_result_modal.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/common/resources/data_state.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize with the provided question
    context.read<QuizStartBloc>().emit(QuizStartLoaded(widget.initialQuestion));
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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<QuizAnswerBloc, QuizAnswerState>(
            listener: (context, answerState) {
              if (answerState is QuizAnswerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(answerState.message),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (answerState is QuizAnswerLoaded) {
                // Reset selected answer when a new question is loaded
                setState(() {
                  selectedAnswerId = null;
                });
                // If there's a next question, update the start bloc with it
                if (answerState.nextQuestion != null) {
                  context
                      .read<QuizStartBloc>()
                      .emit(QuizStartLoaded(answerState.nextQuestion!));
                }
              } else if (answerState is QuizAnswerComplete) {
                // Quiz is complete, fetch and show results
                log("Quiz is complete, fetching results...");
                context.read<QuizResultBloc>().add(FetchQuizResultEvent(
                      courseId: widget.courseId,
                      quizId: widget.quizId,
                    ));
              }
            },
          ),
          BlocListener<QuizResultBloc, QuizResultState>(
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
                  ),
                );
              }
            },
          ),
        ],
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
              return BlocBuilder<QuizAnswerBloc, QuizAnswerState>(
                builder: (context, answerState) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(state.question.data.title),
                                if (answerState is QuizAnswerLoaded)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      answerState.isCorrect
                                          ? 'درست است'
                                          : 'نادرست',
                                      style:
                                          MyTextStyle.textHeader16Bold.copyWith(
                                        color: answerState.isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                if (answerState is QuizAnswerLoaded &&
                                    answerState.explanation != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      answerState.explanation!,
                                      style: MyTextStyle.textHeader16Bold,
                                    ),
                                  ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 12);
                                  },
                                  itemCount: state.question.data.answers.length,
                                  itemBuilder: (context, index) {
                                    final answer =
                                        state.question.data.answers[index];
                                    final isSelected =
                                        selectedAnswerId == answer.id;

                                    return InkWell(
                                      onTap: answerState is QuizAnswerLoading
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (selectedAnswerId != null &&
                          answerState is! QuizAnswerLoaded)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: answerState is QuizAnswerLoading
                                ? null
                                : () {
                                    context.read<QuizAnswerBloc>().add(
                                          SubmitAnswerEvent(
                                            courseId: widget.courseId,
                                            quizId: widget.quizId,
                                            questionId: state.question.data.id,
                                            answerId: selectedAnswerId!,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.primary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "بررسی پاسخ",
                              style: MyTextStyle.textHeader16Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (answerState is QuizAnswerLoaded)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: answerState.nextQuestion != null
                                ? () {
                                    context.read<QuizStartBloc>().emit(
                                        QuizStartLoaded(
                                            answerState.nextQuestion!));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.primary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              answerState.nextQuestion != null
                                  ? "بعدی"
                                  : "پایان",
                              style: MyTextStyle.textHeader16Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class QuizAnswerItem extends StatelessWidget {
  final String title;
  final String id;
  final bool isSelected;

  const QuizAnswerItem({
    super.key,
    required this.title,
    required this.id,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 68,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? MyColors.primary : Colors.transparent,
          width: 2,
        ),
        color: MyColors.cardBackground1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(title, style: MyTextStyle.textHeader16Bold),
      ),
    );
  }
}
