import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/quizes_cubit/cubit/quizes_cubit.dart';
import 'package:poortak/featueres/feature_sayareh/screens/first_quiz_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/main.dart';

class QuizzesScreen extends StatefulWidget {
  static const routeName = "/quizzes";
  final String courseId;
  const QuizzesScreen({super.key, required this.courseId});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> with RouteAware {
  late QuizesCubit _quizesCubit;

  @override
  void initState() {
    super.initState();
    _quizesCubit = QuizesCubit();
    _checkAuthAndFetchQuizzes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Fires when returning from FirstQuiz/Quiz (even after pushReplacement).
    if (!mounted) return;
    _quizesCubit.fetchQuizzes(widget.courseId);
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

  Future<void> _openQuiz({
    required String quizId,
    required String title,
  }) async {
    await Navigator.pushNamed(
      context,
      FirstQuizScreen.routeName,
      arguments: {
        "quizId": quizId,
        "courseId": widget.courseId,
        "title": title,
      },
    );
    // Refresh is handled by didPopNext so progress updates after the last
    // question / result modal — not when FirstQuiz is replaced mid-quiz.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background1;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const PoortakAppBar(title: 'آزمون ها'),
      body: SafeArea(
        child: BlocBuilder<QuizesCubit, QuizesState>(
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
                    SizedBox(height: 40.h),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: Dimens.small.h);
                      },
                      itemBuilder: (context, index) {
                        final quiz = state.quizzes.data[index];
                        return QuizItem(
                          title: quiz.title,
                          image: quiz.thumbnail,
                          description: quiz.difficulty,
                          id: quiz.id,
                          progress: quiz.userScore,
                          onTap: () => _openQuiz(
                            quizId: quiz.id,
                            title: quiz.title,
                          ),
                        );
                      },
                      itemCount: state.quizzes.data.length,
                    ),
                    SizedBox(height: 40.h),
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
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _quizesCubit.close();
    super.dispose();
  }
}

class QuizItem extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final String id;
  final int? progress;
  final VoidCallback onTap;

  const QuizItem({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.id,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDark ? MyColors.sayarehItemCardBackgroundDark : MyColors.background;
    final descriptionColor =
        isDark ? MyColors.darkTextSecondary : MyColors.text4;
    final titleColor = isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final width = 350.w;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: 104.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40.r)),
          color: cardBackgroundColor,
        ),
        child: Stack(
          children: [
            if (progress != null && progress! > 0 && progress! < 100)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: width * (progress! / 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.r),
                    color: isDark
                        ? MyColors.lessonCardProgressDark
                        : MyColors.lessonCardProgressLight,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 28.w),
              child: Row(
                children: [
                  buildImageFromAssetOrEmbeddedSvg(
                    "assets/images/points/quiz_icon.png",
                    width: 48.0.r,
                    height: 48.0.r,
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: CustomTextStyle.titleLesonText.copyWith(
                            color: descriptionColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          title,
                          style: CustomTextStyle.subTitleLeasonText.copyWith(
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (progress != null && progress! > 0) ...[
                    SizedBox(width: 8.w),
                    if (progress == 100)
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      )
                    else
                      Text(
                        "%${toPersianDigits('$progress')}",
                        style: TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? MyColors.profileTextPrimaryDark
                              : const Color(0xFF53668E),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
