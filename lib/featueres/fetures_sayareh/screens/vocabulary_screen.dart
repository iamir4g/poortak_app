import 'dart:developer';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/vocabulary_bloc/vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/practice_vocabulary_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/vocabulary_bottom_controls.dart';

class VocabularyScreen extends StatefulWidget {
  static const routeName = "/vocabulary_screen";
  final String id;
  const VocabularyScreen({super.key, required this.id});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const double _vocabularySpeechRate = 0.3;
  int currentIndex = 0;
  int totalWords = 0;
  String? lastPlayedWord;
  String? currentImageWordKey;
  String? currentImageUrl;
  bool isCurrentImageReady = false;
  final Map<String, String> imageUrlCache = {};
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final LitnerResultToastController _litnerToastController =
      LitnerResultToastController();
  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await ttsService.setMaleVoice();
  }

  void _addToLitner(String word, String translation) async {
    final isLoggedIn = await prefsOperator.getLoggedIn();

    if (!isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفا وارد شوید"),
          backgroundColor: MyColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    log(word);
    log(translation);

    if (!mounted) return;
    context.read<LitnerBloc>().add(CreateWordEvent(
          word: word,
          translation: translation,
        ));
  }

  Future<void> _readWord(String word) async {
    await ttsService.speak(
      word,
      voice: 'male',
      speechRate: _vocabularySpeechRate,
    );
  }

  void _nextWord(int totalWords, String word) {
    setState(() {
      if (currentIndex < totalWords - 1) {
        currentIndex++;
        lastPlayedWord = null;
        currentImageUrl = null;
        isCurrentImageReady = false;
      }
    });
  }

  void _previousWord(int totalWords, String word) {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        lastPlayedWord = null;
        currentImageUrl = null;
        isCurrentImageReady = false;
      }
    });
  }

  void _goToNextWord(List<dynamic> words) {
    if (currentIndex >= words.length - 1) return;
    final nextWord = words[currentIndex + 1].word;
    _nextWord(words.length, nextWord);
  }

  void _goToPreviousWord(List<dynamic> words) {
    if (currentIndex <= 0) return;
    final previousWord = words[currentIndex - 1].word;
    _previousWord(words.length, previousWord);
  }

  void _handleVocabularyAreaTap(
    TapUpDetails details,
    BuildContext context,
    List<dynamic> words,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tappedOnLeftHalf = details.localPosition.dx < screenWidth / 2;

    if (tappedOnLeftHalf) {
      _goToNextWord(words);
      return;
    }

    _goToPreviousWord(words);
  }

  Widget _buildImageLoader() {
    return Center(
      child: SizedBox(
        width: 22.w,
        height: 22.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          color: MyColors.primary,
        ),
      ),
    );
  }

  Future<void> _prepareCurrentWordImage(
    List<dynamic> words,
    int index,
  ) async {
    final currentWord = words[index];
    final imageUrl = imageUrlCache.putIfAbsent(
      currentWord.thumbnail,
      () => storageService.getDownloadPublicUrl(currentWord.thumbnail),
    );

    if (!mounted) return;

    setState(() {
      currentImageUrl = imageUrl;
      isCurrentImageReady = false;
    });

    try {
      await precacheImage(CachedNetworkImageProvider(imageUrl), context);
    } catch (e) {
      log('Vocabulary image precache failed: $e');
      return;
    }

    if (!mounted || currentImageWordKey != currentWord.thumbnail) return;

    setState(() {
      isCurrentImageReady = true;
    });

    if (lastPlayedWord != currentWord.word) {
      await _readWord(currentWord.word);
      if (!mounted || currentImageWordKey != currentWord.thumbnail) return;
      setState(() {
        lastPlayedWord = currentWord.word;
      });
    }

    _prefetchNearbyImages(words, index);
  }

  void _prefetchNearbyImages(List<dynamic> words, int index) {
    for (final nearbyIndex in [index + 1, index - 1]) {
      if (nearbyIndex < 0 || nearbyIndex >= words.length) continue;

      final nearbyWord = words[nearbyIndex];
      final imageUrl = imageUrlCache.putIfAbsent(
        nearbyWord.thumbnail,
        () => storageService.getDownloadPublicUrl(nearbyWord.thumbnail),
      );

      precacheImage(CachedNetworkImageProvider(imageUrl), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackgroundColor =
        isDark ? MyColors.profileBackgroundDark : MyColors.secondaryTint4;
    final headerBackgroundColor =
        isDark ? MyColors.darkBackgroundSecondary : Colors.white;
    final primaryTextColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.loginTextSecondaryDark : MyColors.textSecondary;
    final iconColor = isDark
        ? MyColors.profileTextPrimaryDark
        : (Theme.of(context).iconTheme.color ?? Colors.black);
    return BlocProvider(
      create: (context) => VocabularyBloc(sayarehRepository: locator())
        ..add(VocabularyFetchEvent(id: widget.id)),
      child: BlocListener<LitnerBloc, LitnerState>(
        listener: (context, state) {
          if (state is CreateWordSuccess) {
            _litnerToastController.show(
              text: 'به لایتنر اضافه شد!',
              showCheckIcon: true,
            );
          } else if (state is LitnerError) {
            final isWordExistsError =
                state.message == "این کلمه قبلا اضافه شده";
            if (isWordExistsError) {
              _litnerToastController.show(
                text: 'این کلمه از قبل بوده',
                showCheckIcon: false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: MyColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: pageBackgroundColor,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
              ),
            ),
            backgroundColor: headerBackgroundColor,
            foregroundColor: primaryTextColor,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(), //_showExitModal,
                icon: Icon(Icons.arrow_forward, color: primaryTextColor),
              ),
            ],
            title: Text(
              'واژگان',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: primaryTextColor,
              ),
            ),
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: _showExitModal,
            // ),
          ),
          body: SafeArea(
            child: BlocBuilder<VocabularyBloc, VocabularyState>(
              builder: (context, state) {
                if (state is VocabularyLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(MyColors.primary),
                    ),
                  );
                }
                if (state is VocabularySuccess) {
                  if (state.vocabulary.data.isEmpty) {
                    return Center(
                      child: Text(
                        'واژگانی یافت نشد',
                        style: MyTextStyle.textMatn16.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                    );
                  }

                  final currentWord = state.vocabulary.data[currentIndex];
                  totalWords = state.vocabulary.data.length;

                  if (currentImageWordKey != currentWord.thumbnail) {
                    currentImageWordKey = currentWord.thumbnail;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _prepareCurrentWordImage(
                        state.vocabulary.data,
                        currentIndex,
                      );
                    });
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) => _handleVocabularyAreaTap(
                            details,
                            context,
                            state.vocabulary.data,
                          ),
                          onHorizontalDragEnd: (details) {
                            final velocity = details.primaryVelocity;
                            if (velocity == null) return;

                            // Swipe right (to previous) - positive velocity
                            if (velocity > 0) {
                              _goToPreviousWord(state.vocabulary.data);
                            }
                            // Swipe left (to next) - negative velocity
                            else if (velocity < 0) {
                              _goToNextWord(state.vocabulary.data);
                            }
                          },
                          child: SingleChildScrollView(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: Dimens.nh(24),
                                  ),
                                  //step progress bar
                                  StepProgress(
                                      currentIndex: currentIndex,
                                      totalSteps: totalWords),

                                  SizedBox(
                                    height: Dimens.nh(85),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          child: SizedBox(
                                            width: Dimens.nw(264),
                                            height: Dimens.nh(264),
                                            child: currentImageUrl == null
                                                ? _buildImageLoader()
                                                : CachedNetworkImage(
                                                    imageUrl: currentImageUrl!,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 150),
                                                    placeholder:
                                                        (context, url) =>
                                                            _buildImageLoader(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(
                                                      Icons.error,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: Dimens.nh(20)),
                                  Text(
                                    currentWord.word,
                                    style: MyTextStyle.textMatn18Bold.copyWith(
                                      fontSize: 24.sp,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    currentWord.translation,
                                    style: MyTextStyle.textMatn16.copyWith(
                                      fontSize: 18.sp,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 16.h,
                          bottom: Dimens.nh(90),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<LitnerBloc, LitnerState>(
                              builder: (context, litnerState) {
                                return VocabularyBottomControls(
                                  onNext: () =>
                                      _goToNextWord(state.vocabulary.data),
                                  onPrevious: () =>
                                      _goToPreviousWord(state.vocabulary.data),
                                  onReadWord: () => _readWord(currentWord.word),
                                  onAddToLitner: () => _addToLitner(
                                    currentWord.word,
                                    currentWord.translation,
                                  ),
                                  isAddLoading: litnerState is LitnerLoading,
                                  iconColor: iconColor,
                                  litnerToastController: _litnerToastController,
                                );
                              },
                            ),
                            if (currentIndex == totalWords - 1) ...[
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    PracticeVocabularyScreen.routeName,
                                    arguments: {'courseId': widget.id},
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32.w,
                                    vertical: 16.h,
                                  ),
                                ),
                                child: Text(
                                  'تمرین ها',
                                  style: MyTextStyle.textMatnBtn,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }
                if (state is VocabularyError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: MyTextStyle.textMatn16.copyWith(
                        color: primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _litnerToastController.dispose();
    super.dispose();
  }
}
