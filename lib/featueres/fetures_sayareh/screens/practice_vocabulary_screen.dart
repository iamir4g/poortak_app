import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/image_skeleton.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:poortak/common/services/answer_feedback_sound_service.dart';
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

    setState(() {
      selectedWord = word;
      showAnswer = true;
      isCorrect = word == correctWord.word;
    });

    unawaited(AnswerFeedbackSoundService.play(isCorrect));
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

    // Submit the selected answer text to the API
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

  double _vocabularyImageSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight < 600 ? 180.h : 264.h;
  }

  Widget _buildVocabularyImage(String thumbnail) {
    final imageSize = _vocabularyImageSize(context);

    return SizedBox(
      key: ValueKey(thumbnail),
      width: imageSize,
      height: imageSize,
      child: FutureBuilder<String>(
        future: storageService.callGetDownloadPublicUrl(thumbnail),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Icon(Icons.error, size: 24.r));
          }

          if (!snapshot.hasData) {
            return ImageSkeleton(
              width: imageSize,
              height: imageSize,
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: CachedNetworkImage(
              imageUrl: snapshot.data!,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) => ImageSkeleton(
                width: imageSize,
                height: imageSize,
              ),
              errorWidget: (_, __, ___) =>
                  Center(child: Icon(Icons.error, size: 24.r)),
            ),
          );
        },
      ),
    );
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
    LessonScreen.popBackToLesson(context);
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
        Navigator.of(context, rootNavigator: true).pop();
      },
      onSecondButtonPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _navigateToLessonScreen();
      },
    ).whenComplete(() {
      _isExitDialogOpen = false;
    });
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final pageBackgroundColor =
                isDark ? MyColors.profileBackgroundDark : MyColors.background;
            final headerBackgroundColor =
                isDark ? MyColors.profileBackgroundDark : MyColors.background;
            final primaryTextColor =
                isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;
            final secondaryTextColor =
                isDark ? MyColors.darkTextSecondary : Colors.grey;
            final infoBoxBackgroundColor =
                isDark ? MyColors.termsBackgroundDark : MyColors.infoBg;
            final buttonTextColor =
                isDark ? MyColors.loginButtonText : Colors.white;
            final circleBg = isDark
                ? MyColors.paymentHistoryCardHeaderDark
                : MyColors.modalHeaderBackground;
            final circleBgPressed =
                isDark ? MyColors.darkCardBackground : MyColors.text2;
            final volumeIconPath = isDark
                ? 'assets/images/icons/volume_dark.png'
                : 'assets/images/icons/volume.png';

            if (state is PracticeVocabularyInitial) {
              context.read<PracticeVocabularyBloc>().add(
                    PracticeVocabularyFetchEvent(courseId: widget.courseId),
                  );
            }
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (_isExitDialogOpen) {
                  Navigator.of(context, rootNavigator: true).maybePop();
                  return;
                }
                _handleExitAttempt(state);
              },
              child: Scaffold(
                backgroundColor: pageBackgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: MyColors.headerDecoration(
                      backgroundColor: headerBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: primaryTextColor,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      iconSize: 24.r,
                      icon: Icon(Icons.arrow_forward, color: primaryTextColor),
                      onPressed: () => _handleExitAttempt(state),
                    ),
                  ],
                  title: Text(
                    'تمرین واژگان',
                    style: MyTextStyle.textHeader16Bold.copyWith(
                      color: primaryTextColor,
                    ),
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
                        final wrongWord =
                            state.practiceVocabulary.data.wrongWord;
                        final stats = state.practiceVocabulary.data.stats;
                        final totalSteps =
                            stats.total > 0 ? stats.total : stats.test;
                        final currentIndex = stats.currentIndex;

                        _generateRandomOptions(
                            correctWord.word, wrongWord.word);

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
                                        height: Dimens.nh(24),
                                      ),
                                      if (totalSteps > 0)
                                        StepProgress(
                                          currentIndex: currentIndex,
                                          totalSteps: totalSteps,
                                        ),
                                      SizedBox(
                                        height: Dimens.nh(24),
                                      ),
                                      Container(
                                        width: 268.w,
                                        height: 45.h,
                                        decoration: BoxDecoration(
                                          color: infoBoxBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "گزینه ی درست را انتخاب کنید.",
                                              style: MyTextStyle.textMatn14Bold
                                                  .copyWith(
                                                color: primaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24.h,
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildVocabularyImage(correctWord.thumbnail),
                                      SizedBox(
                                          height: showAnswer ? 20.h : 30.h),
                                      SizedBox(
                                          height: showAnswer ? 10.h : 30.h),
                                      if (showAnswer) ...[
                                        if (!isCorrect) ...[
                                          Text(
                                            selectedWord!,
                                            style: MyTextStyle.text14Wrong
                                                .copyWith(
                                              color: isDark
                                                  ? MyColors
                                                      .quizAnswerWrongTextDark
                                                  : MyColors.error,
                                            ),
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
                                              style: MyTextStyle.text24Correct
                                                  .copyWith(
                                                color: isDark
                                                    ? MyColors
                                                        .quizAnswerCorrectTextDark
                                                    : MyColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          correctWord.translation,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: secondaryTextColor,
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
                                          PressableCircle(
                                            enabled: true,
                                            backgroundColor: circleBg,
                                            pressedBackgroundColor:
                                                circleBgPressed,
                                            onTap: () =>
                                                _readWord(correctWord.word),
                                            child: Image.asset(
                                              volumeIconPath,
                                              width: Dimens.nr(28),
                                              height: Dimens.nr(28),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          BlocBuilder<LitnerBloc, LitnerState>(
                                            builder: (context, litnerState) {
                                              final isLoading =
                                                  litnerState is LitnerLoading;
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
                                      ),
                                      SizedBox(height: 15.h),
                                      ElevatedButton(
                                        onPressed: _nextQuestion,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.primary,
                                          foregroundColor: buttonTextColor,
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
                                              Icon(
                                                Icons.chevron_left,
                                                color: buttonTextColor,
                                              ),
                                              SizedBox(width: 4.r),
                                              Text(
                                                'بعدی',
                                                style: TextStyle(
                                                  color: buttonTextColor,
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
}
