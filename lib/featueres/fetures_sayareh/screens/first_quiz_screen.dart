import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiez_screen.dart';
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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      body: BlocConsumer<QuizStartBloc, QuizStartState>(
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
                  if (answerState.nextQuestion != null) {
                    // Navigate to QuizScreen with the next question
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
                  }
                }
              },
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                  ],
                );
              },
            );
          }
          return const SizedBox();
        },
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
