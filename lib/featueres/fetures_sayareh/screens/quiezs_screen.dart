import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quizes_cubit/cubit/quizes_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/first_quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiez_screen.dart';
import 'package:poortak/locator.dart';

class QuizzesScreen extends StatefulWidget {
  static const routeName = "/quizzes";
  final String courseId;
  const QuizzesScreen({super.key, required this.courseId});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  late QuizesCubit _quizesCubit;

  @override
  void initState() {
    super.initState();
    _quizesCubit = QuizesCubit();
    _checkAuthAndFetchQuizzes();
  }

  void _checkAuthAndFetchQuizzes() {
    final prefsOperator = locator<PrefsOperator>();
    if (!prefsOperator.isLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
      return;
    }
    _quizesCubit.fetchQuizzes(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background1,
      appBar: AppBar(
        title: Text(
          "آزمون ها",
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      body: BlocBuilder<QuizesCubit, QuizesState>(
        bloc: _quizesCubit,
        builder: (context, state) {
          if (state is QuizesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizesLoaded) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (context, index) {
                      final quiz = state.quizzes.data[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            FirstQuizScreen.routeName,
                            arguments: {
                              "quizId": quiz.id,
                              "courseId": widget.courseId,
                              "title": quiz.title,
                            },
                          );
                        },
                        child: QuizItem(
                          title: quiz.title,
                          image: quiz.thumbnail,
                          description: quiz.difficulty,
                          id: quiz.id,
                        ),
                      );
                    },
                    itemCount: state.quizzes.data.length,
                  ),
                ],
              ),
            );
          } else if (state is QuizesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    _quizesCubit.close();
    super.dispose();
  }
}

class QuizItem extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final String id;

  const QuizItem({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 104,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          color: MyColors.background),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
        child: Row(
          children: [
            Image.asset(
              "assets/images/quiz_icon.png",
              width: 48.0,
              height: 48.0,
            ),
            SizedBox(
              width: 18,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: CustomTextStyle.titleLesonText),
                Text(title, style: CustomTextStyle.subTitleLeasonText)
              ],
            )
          ],
        ),
      ),
    );
  }
}
