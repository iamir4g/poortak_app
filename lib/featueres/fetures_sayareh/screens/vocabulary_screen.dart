import 'dart:developer';

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
    final iconColor =
        isDark ? MyColors.profileTextPrimaryDark : (Theme.of(context).iconTheme.color ?? Colors.black);
    return BlocProvider(
      create: (context) => VocabularyBloc(sayarehRepository: locator())
        ..add(VocabularyFetchEvent(id: widget.id)),
      child: BlocListener<LitnerBloc, LitnerState>(
        listener: (context, state) {
          if (state is CreateWordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لغت به لایتنر اضافه شد'),
                backgroundColor: MyColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is LitnerError) {
            // Check if it's the "word already exists" error
            final isWordExistsError =
                state.message == "این کلمه قبلا اضافه شده";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor:
                    isWordExistsError ? MyColors.warning : MyColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
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
            centerTitle: true,
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
                      valueColor: AlwaysStoppedAnimation<Color>(MyColors.primary),
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
                                    height: 20.h,
                                  ),
                                  //step progress bar
                                  StepProgress(
                                      currentIndex: currentIndex,
                                      totalSteps: totalWords),

                                  SizedBox(
                                    height: 30.h,
                                  ),
                                  Builder(
                                    builder: (context) {
                                      double imageHeight = 200.h;
                                      final screenHeight =
                                          MediaQuery.of(context).size.height;
                                      if (screenHeight < 600) {
                                        imageHeight = 150.h;
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          child: SizedBox(
                                            width: imageHeight,
                                            height: imageHeight,
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
                                  SizedBox(height: 20.h),
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
                        padding: EdgeInsets.all(16.0.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              key: const Key('vocabulary_forward_button'),
                              onPressed: () =>
                                  _goToNextWord(state.vocabulary.data),
                              icon: Icon(Icons.arrow_back, color: iconColor),
                              iconSize: 32.r,
                            ),
                            BlocBuilder<LitnerBloc, LitnerState>(
                              builder: (context, litnerState) {
                                return IconButton(
                                  onPressed: litnerState is LitnerLoading
                                      ? null
                                      : () => _addToLitner(
                                            currentWord.word,
                                            currentWord.translation,
                                          ),
                                  icon: litnerState is LitnerLoading
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.w,
                                            valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                                    MyColors.primary),
                                          ),
                                        )
                                      : Icon(Icons.add_circle_outline,
                                          color: iconColor),
                                  iconSize: 32.r,
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () => _readWord(currentWord.word),
                              icon: SvgPicture.asset(
                                'assets/images/icons/cuida--volume-2-outline.svg',
                                width: 32.r,
                                height: 32.r,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _goToPreviousWord(state.vocabulary.data),
                              icon: Icon(Icons.arrow_forward, color: iconColor),
                              iconSize: 32.r,
                            ),
                          ],
                        ),
                      ),
                      if (currentIndex == totalWords - 1)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.0.h),
                          child: ElevatedButton(
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
}
