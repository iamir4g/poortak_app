import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/haptic_service.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/dimens.dart';
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
import 'package:poortak/common/widgets/pressable_circle.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/vocabulary_bottom_controls.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/item_question.dart';

class PracticeVocabularyScreen extends StatefulWidget {
  static const routeName = "/practice_vocabulary_screen";
  final String courseId;

  const PracticeVocabularyScreen({super.key, required this.courseId});

  @override
  State<PracticeVocabularyScreen> createState() =>
      _PracticeVocabularyScreenState();
}

class _PracticeVocabularyScreenState extends State<PracticeVocabularyScreen> {
  final AudioPlayer _feedbackPlayer = AudioPlayer();
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final LitnerResultToastController _litnerToastController =
      LitnerResultToastController();
  bool showAnswer = false;
  bool isCorrect = false;
  String? selectedWord;
  List<String> randomizedOptions = [];
  bool _isExitDialogOpen = false;
  bool _hasShownResultModal = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await ttsService.setMaleVoice();
  }

  @override
  void dispose() {
    unawaited(_feedbackPlayer.dispose());
    _litnerToastController.dispose();
    super.dispose();
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

    unawaited(_playAnswerFeedbackSound(isCorrect));
    if (!isCorrect) {
      unawaited(HapticService.wrongAnswerFeedback());
    }

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

  Future<void> _playAnswerFeedbackSound(bool isAnswerCorrect) async {
    final assetPath = isAnswerCorrect
        ? 'sounds/dragon-studio-correct.mp3'
        : 'sounds/freesound_community-wrong.mp3';

    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Failed to play answer feedback sound: $e');
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفا وارد شوید"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!mounted) return;
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

  void _showExitModal() {
    if (_isExitDialogOpen) return;
    _isExitDialogOpen = true;

    ReusableModal.show(
      context: context,
      title: 'ترک تمرین ها',
      message:
          'با ترک تمرین های این بخش، پاسخ های فعلی شما حذف می شود و باید دفعه ی بعد دوباره به آنها پاسخ دهید',
      type: ModalType.info,
      buttonText: 'ماندن',
      secondButtonText: 'ترک تمرین ها',
      showSecondButton: true,
      barrierDismissible: false,
      onButtonPressed: () {
        _isExitDialogOpen = false;
        Navigator.of(context).pop();
      },
      onSecondButtonPressed: () {
        _isExitDialogOpen = false;
        Navigator.of(context).pop();
        _navigateToLessonScreen();
      },
    );
  }

  void _handleExitAttempt(PracticeVocabularyState state) {
    if (state is PracticeVocabularyCompleted) {
      _navigateToLessonScreen();
      return;
    }

    _showExitModal();
  }

  void _showResultModal(PracticeVocabularyCompleted state) {
    if (_hasShownResultModal || !mounted) return;
    _hasShownResultModal = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PracticeVocabularyResultModal(
        totalQuestions: state.totalQuestions,
        correctAnswers: state.correctAnswersCount,
        wrongAnswers: state.wrongAnswersCount,
        reviewedVocabularies: state.reviewedVocabularies,
        courseId: widget.courseId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LitnerBloc, LitnerState>(
      listener: (context, state) {
        if (state is CreateWordSuccess) {
          _litnerToastController.show(
            text: 'به لایتنر اضافه شد!',
            showCheckIcon: true,
          );
        } else if (state is LitnerError) {
          // Check if it's the "word already exists" error
          final isWordExistsError = state.message == "این کلمه قبلا اضافه شده";
          if (isWordExistsError) {
            _litnerToastController.show(
              text: 'این کلمه از قبل بوده',
              showCheckIcon: false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: BlocListener<PracticeVocabularyBloc, PracticeVocabularyState>(
        listenWhen: (previous, current) =>
            current is PracticeVocabularyCompleted,
        listener: (context, state) {
          if (state is PracticeVocabularyCompleted) {
            _showResultModal(state);
          }
        },
        child: BlocBuilder<PracticeVocabularyBloc, PracticeVocabularyState>(
        builder: (context, state) {
          if (state is PracticeVocabularyInitial) {
            context.read<PracticeVocabularyBloc>().add(
                  PracticeVocabularyFetchEvent(courseId: widget.courseId),
                );
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _handleExitAttempt(state);
              }
            },
            child: Scaffold(
              backgroundColor: MyColors.background,
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
                    onPressed: () => _handleExitAttempt(state),
                  ),
                ],
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
                      return Center(
                          child: CircularProgressIndicator(strokeWidth: 4.w));
                    }
                    if (state is PracticeVocabularySuccess) {
                      final correctWord =
                          state.practiceVocabulary.data.correctWord;
                      final wrongWord = state.practiceVocabulary.data.wrongWord;

                      _generateRandomOptions(correctWord.word, wrongWord.word);

                      final optionButtons = randomizedOptions
                          .map(
                            (word) => Expanded(
                              child: PressableAnswerOptionButton(
                                text: word,
                                onTap: () => _checkAnswer(word),
                              ),
                            ),
                          )
                          .toList();

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: !showAnswer ? 120.h : 170.h,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                    SizedBox(height: showAnswer ? 10.h : 30.h),
                                    if (showAnswer) ...[
                                      if (!isCorrect) ...[
                                        Text(
                                          selectedWord!,
                                          style: MyTextStyle.text14Wrong,
                                        ),
                                        SizedBox(height: 5.h),
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/check_icon2.png',
                                            width: 22.r,
                                            height: 22.r,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            correctWord.word,
                                            style: MyTextStyle.text24Correct,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        correctWord.translation,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!showAnswer)
                            SafeArea(
                              top: false,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 64.h,
                                ),
                                child: Row(
                                  children: optionButtons.length == 2
                                      ? [
                                          optionButtons[0],
                                          SizedBox(width: 12.w),
                                          optionButtons[1],
                                        ]
                                      : optionButtons,
                                ),
                              ),
                            ),
                          if (showAnswer)
                            SafeArea(
                              top: false,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                  top: 8.h,
                                  bottom: 64.h,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final isDark =
                                                Theme.of(context).brightness ==
                                                    Brightness.dark;
                                            final circleBg = isDark
                                                ? MyColors
                                                    .darkBackgroundSecondary
                                                : MyColors
                                                    .modalHeaderBackground;
                                            final circleBgPressed = isDark
                                                ? MyColors.darkBorder
                                                : MyColors.text2;

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                PressableCircle(
                                                  enabled: true,
                                                  backgroundColor: circleBg,
                                                  pressedBackgroundColor:
                                                      circleBgPressed,
                                                  onTap: () => _readWord(
                                                      correctWord.word),
                                                  child: Image.asset(
                                                    'assets/images/icons/volume.png',
                                                    width: Dimens.nr(28),
                                                    height: Dimens.nr(28),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                BlocBuilder<LitnerBloc,
                                                    LitnerState>(
                                                  builder:
                                                      (context, litnerState) {
                                                    final isLoading =
                                                        litnerState
                                                            is LitnerLoading;
                                                    return LitnerAddButton(
                                                      toastController:
                                                          _litnerToastController,
                                                      enabled: !isLoading,
                                                      isLoading: isLoading,
                                                      backgroundColor: circleBg,
                                                      pressedBackgroundColor:
                                                          circleBgPressed,
                                                      onTap: () => _addToLitner(
                                                        correctWord.word,
                                                        correctWord.translation,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
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
                                          horizontal: 32.w,
                                          vertical: 16.h,
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: Dimens.buttonSmallWidth,
                                        height: Dimens.buttonSmallHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.chevron_left),
                                            SizedBox(width: 4.r),
                                            Text(
                                              'بعدی',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontFamily: "IranSans",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildWordButton(String word) {
    return PressableAnswerOptionButton(
      text: word,
      onTap: () => _checkAnswer(word),
    );
  }
}
