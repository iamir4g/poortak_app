import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/practice_vocabulary_result_modal.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';

class PracticeVocabularyScreen extends StatefulWidget {
  static const routeName = "/practice_vocabulary_screen";
  final String courseId;

  const PracticeVocabularyScreen({super.key, required this.courseId});

  @override
  State<PracticeVocabularyScreen> createState() =>
      _PracticeVocabularyScreenState();
}

class _PracticeVocabularyScreenState extends State<PracticeVocabularyScreen> {
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  bool showAnswer = false;
  bool isCorrect = false;
  String? selectedWord;
  List<String> randomizedOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await ttsService.setMaleVoice();
  }

  void _generateRandomOptions(String correct, String wrong) {
    if (randomizedOptions.isEmpty ||
        (!randomizedOptions.contains(correct) ||
            !randomizedOptions.contains(wrong))) {
      final options = [correct, wrong];
      options.shuffle();
      randomizedOptions = options;
    }
  }

  void _checkAnswer(String word) {
    final currentState = context.read<PracticeVocabularyBloc>().state
        as PracticeVocabularySuccess;
    final correctWord = currentState.practiceVocabulary.data.correctWord;
    final wrongWord = currentState.practiceVocabulary.data.wrongWord;

    setState(() {
      selectedWord = word;
      showAnswer = true;
      isCorrect = word == correctWord.word;
    });

    // Save the answer (correct or wrong)
    context.read<PracticeVocabularyBloc>().add(
          PracticeVocabularySaveAnswerEvent(
            word: correctWord,
            isCorrect: isCorrect,
          ),
        );

    // Determine answer ID
    final answerId = word == correctWord.word ? correctWord.id : wrongWord.id;

    // Submit the answer to the API
    context.read<PracticeVocabularyBloc>().add(
          PracticeVocabularySubmitEvent(
            courseId: widget.courseId,
            vocabularyId: correctWord.id,
            answer: answerId,
            previousVocabularyIds: currentState.correctWords,
          ),
        );

    // If correct, also save the word ID for fetching next question
    if (isCorrect) {
      context.read<PracticeVocabularyBloc>().add(
            PracticeVocabularySaveCorrectEvent(
              wordId: correctWord.id,
            ),
          );
    }
  }

  void _nextQuestion() {
    setState(() {
      showAnswer = false;
      selectedWord = null;
      randomizedOptions = []; // Clear for next randomization
    });
    if (context.read<PracticeVocabularyBloc>().state
        is PracticeVocabularySuccess) {
      final currentState = context.read<PracticeVocabularyBloc>().state
          as PracticeVocabularySuccess;
      context.read<PracticeVocabularyBloc>().add(
            PracticeVocabularyFetchEvent(
              courseId: widget.courseId,
              previousVocabularyIds: currentState.correctWords,
            ),
          );
    } else {
      context.read<PracticeVocabularyBloc>().add(
            PracticeVocabularyFetchEvent(
              courseId: widget.courseId,
              previousVocabularyIds: [],
            ),
          );
    }
  }

  void _readWord(String word) async {
    await ttsService.speak(word, voice: 'male');
  }

  void _addToLitner(String word, String translation) async {
    final isLoggedIn = await prefsOperator.getLoggedIn();

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفا وارد شوید"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.read<LitnerBloc>().add(CreateWordEvent(
          word: word,
          translation: translation,
        ));
  }

  void _navigateToLessonScreen() {
    Navigator.pushReplacementNamed(
      context,
      LessonScreen.routeName,
      arguments: {
        'index': 0,
        'title': 'درس',
        'lessonId': widget.courseId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LitnerBloc, LitnerState>(
      listener: (context, state) {
        if (state is CreateWordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لغت به لایتنر اضافه شد'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is LitnerError) {
          // Check if it's the "word already exists" error
          final isWordExistsError = state.message == "این کلمه قبلا اضافه شده";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: isWordExistsError ? Colors.orange : Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<PracticeVocabularyBloc, PracticeVocabularyState>(
        builder: (context, state) {
          if (state is PracticeVocabularyInitial) {
            context.read<PracticeVocabularyBloc>().add(
                  PracticeVocabularyFetchEvent(courseId: widget.courseId),
                );
          }
          final bool canPopScreen = state is! PracticeVocabularyCompleted;

          return PopScope(
            canPop: canPopScreen,
            onPopInvoked: (didPop) {
              if (!didPop) {
                _navigateToLessonScreen();
              }
            },
            child: Scaffold(
              backgroundColor: MyColors.secondaryTint4,
              appBar: AppBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                  ),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    iconSize: 24.r,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _navigateToLessonScreen();
                    },
                  ),
                ],
                centerTitle: true,
                title: Text(
                  'تمرین واژگان',
                  style: MyTextStyle.textHeader16Bold,
                ),
              ),
              body: SafeArea(
                child: Builder(
                  builder: (innerContext) {
                    if (state is PracticeVocabularyLoading) {
                      return Center(
                          child: CircularProgressIndicator(strokeWidth: 4.w));
                    }
                    if (state is PracticeVocabularyCompleted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: innerContext,
                          barrierDismissible: false,
                          builder: (context) => PracticeVocabularyResultModal(
                            totalQuestions: state.totalQuestions,
                            correctAnswers: state.correctAnswersCount,
                            wrongAnswers: state.wrongAnswersCount,
                            reviewedVocabularies: state.reviewedVocabularies,
                            courseId: widget.courseId,
                          ),
                        );
                      });
                      return Center(
                          child: CircularProgressIndicator(strokeWidth: 4.w));
                    }
                    if (state is PracticeVocabularySuccess) {
                      final correctWord =
                          state.practiceVocabulary.data.correctWord;
                      final wrongWord = state.practiceVocabulary.data.wrongWord;

                      _generateRandomOptions(correctWord.word, wrongWord.word);

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (!showAnswer) ...[
                                      SizedBox(
                                        height: 18.h,
                                      ),
                                      Container(
                                        width: 268.w,
                                        height: 45.h,
                                        decoration: BoxDecoration(
                                          color: MyColors.infoBg,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "گزینه ی درست را انتخاب کنید.",
                                              style: MyTextStyle.textMatn14Bold,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24.h,
                                      ),
                                    ] else
                                      SizedBox(height: 10.h),
                                    FutureBuilder<String>(
                                      future: storageService
                                          .callGetDownloadPublicUrl(
                                              correctWord.thumbnail),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator(
                                              strokeWidth: 4.w);
                                        }
                                        if (snapshot.hasError) {
                                          return Icon(Icons.error, size: 24.r);
                                        }
                                        if (snapshot.hasData) {
                                          // Responsive height for image
                                          double imageHeight = 264.h;
                                          final screenHeight =
                                              MediaQuery.of(context)
                                                  .size
                                                  .height;
                                          if (screenHeight < 600) {
                                            imageHeight = 180.h;
                                          }

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.r),
                                            child: Image.network(
                                              snapshot.data!,
                                              height: imageHeight,
                                              width: imageHeight,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                    SizedBox(height: showAnswer ? 20.h : 30.h),
                                    if (!showAnswer)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: randomizedOptions
                                            .map((word) =>
                                                _buildWordButton(word))
                                            .toList(),
                                      ),
                                    SizedBox(height: showAnswer ? 10.h : 30.h),
                                    if (showAnswer) ...[
                                      if (!isCorrect) ...[
                                        Text(
                                          selectedWord!,
                                          style: MyTextStyle.text14Wrong,
                                        ),
                                        SizedBox(height: 5.h),
                                      ],
                                      Text(
                                        correctWord.word,
                                        style: MyTextStyle.text24Correct,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        correctWord.translation,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _readWord(correctWord.word),
                                            icon: IconifyIcon(
                                              icon: "cuida:volume-2-outline",
                                              size: 32.r,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          BlocBuilder<LitnerBloc, LitnerState>(
                                            builder: (context, litnerState) {
                                              return IconButton(
                                                onPressed:
                                                    litnerState is LitnerLoading
                                                        ? null
                                                        : () => _addToLitner(
                                                              correctWord.word,
                                                              correctWord
                                                                  .translation,
                                                            ),
                                                icon: litnerState
                                                        is LitnerLoading
                                                    ? SizedBox(
                                                        width: 20.w,
                                                        height: 20.h,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.w,
                                                        ),
                                                      )
                                                    : const Icon(Icons
                                                        .add_circle_outline),
                                                iconSize: 32.r,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      ElevatedButton(
                                        onPressed: _nextQuestion,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.primary,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32.w, vertical: 16.h),
                                        ),
                                        child: Text(
                                          'سوال بعدی',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontFamily: "IranSans",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is PracticeVocabularyError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordButton(String word) {
    return ElevatedButton(
      onPressed: () => _checkAnswer(word),
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontFamily: "IranSans",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
