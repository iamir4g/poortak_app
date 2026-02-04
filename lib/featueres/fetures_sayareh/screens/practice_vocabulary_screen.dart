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

  @override
  void initState() {
    super.initState();
    context.read<PracticeVocabularyBloc>().add(
          PracticeVocabularyFetchEvent(courseId: widget.courseId),
        );
  }

  void _checkAnswer(String word) {
    final currentState = context.read<PracticeVocabularyBloc>().state
        as PracticeVocabularySuccess;
    final correctWord = currentState.practiceVocabulary.data.correctWord;

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

    // Submit the answer to the API
    context.read<PracticeVocabularyBloc>().add(
          PracticeVocabularySubmitEvent(
            courseId: widget.courseId,
            vocabularyId: correctWord.id,
            answer: word,
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
    await ttsService.speak(word);
  }

  void _addToLitner(String word, String translation) async {
    final isLoggedIn = await prefsOperator.getLoggedIn();

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفا وارد شوید"),
          backgroundColor: Colors.red,
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
            ),
          );
        } else if (state is LitnerError) {
          // Check if it's the "word already exists" error
          final isWordExistsError = state.message == "این کلمه قبلا اضافه شده";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: isWordExistsError ? Colors.orange : Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<PracticeVocabularyBloc, PracticeVocabularyState>(
        builder: (context, state) {
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                title: const Text(
                  'تمرین واژگان',
                  style: MyTextStyle.textHeader16Bold,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _navigateToLessonScreen();
                  },
                ),
              ),
              body: Builder(
                builder: (innerContext) {
                  if (state is PracticeVocabularyLoading) {
                    return const Center(child: CircularProgressIndicator());
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PracticeVocabularySuccess) {
                    final correctWord =
                        state.practiceVocabulary.data.correctWord;
                    final wrongWord = state.practiceVocabulary.data.wrongWord;

                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 18,
                                ),
                                Container(
                                  width: 268,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: MyColors.infoBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "گزینه ی درست را انتخاب کنید.",
                                        style: MyTextStyle.textMatn14Bold,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                ),
                                FutureBuilder<String>(
                                  future:
                                      storageService.callGetDownloadPublicUrl(
                                          correctWord.thumbnail),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return const Icon(Icons.error);
                                    }
                                    if (snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          snapshot.data!,
                                          height: 264,
                                          width: 264,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                const SizedBox(height: 60),
                                if (!showAnswer)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildWordButton(correctWord.word),
                                      _buildWordButton(wrongWord.word),
                                    ],
                                  ),
                                const SizedBox(height: 60),
                                if (showAnswer) ...[
                                  if (!isCorrect) ...[
                                    Text(
                                      selectedWord!,
                                      style: MyTextStyle.text14Wrong,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  Text(
                                    correctWord.word,
                                    style: MyTextStyle.text24Correct,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    correctWord.translation,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _readWord(correctWord.word),
                                        icon: const IconifyIcon(
                                          icon: "cuida:volume-2-outline",
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      BlocBuilder<LitnerBloc, LitnerState>(
                                        builder: (context, litnerState) {
                                          return IconButton(
                                            onPressed: litnerState
                                                    is LitnerLoading
                                                ? null
                                                : () => _addToLitner(
                                                      correctWord.word,
                                                      correctWord.translation,
                                                    ),
                                            icon: litnerState is LitnerLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.add_circle_outline),
                                            iconSize: 32,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _nextQuestion,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 16),
                                    ),
                                    child: const Text(
                                      'سوال بعدی',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Text(
        word,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: "IranSans",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
