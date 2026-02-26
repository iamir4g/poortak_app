import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
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
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';

class VocabularyScreen extends StatefulWidget {
  static const routeName = "/vocabulary_screen";
  final String id;
  const VocabularyScreen({super.key, required this.id});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int currentIndex = 0;
  int totalWords = 0;
  String? lastPlayedWord;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "لطفا وارد شوید",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    log(word);
    log(translation);
    context.read<LitnerBloc>().add(CreateWordEvent(
          word: word,
          translation: translation,
        ));
  }

  void _readWord(String word) async {
    await ttsService.speak(word, voice: 'male');
  }

  void _showExitModal() {
    ReusableModal.show(
      context: context,
      title: 'ترک تمرین ها',
      message:
          'با ترک تمرین های این بخش، پاسخ های فعلی شما حذف می شود و باید دفعه ی بعد دوباره به آنها پاسخ دهید',
      type: ModalType.info,
      buttonText: 'ماندن',
      secondButtonText: 'ترک تمرین ها',
      showSecondButton: true,
      onButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
        Navigator.of(context).pop(); // Exit vocabulary screen
      },
    );
  }

  void _nextWord(int totalWords, String word) {
    setState(() {
      if (currentIndex < totalWords - 1) {
        currentIndex++;
        lastPlayedWord = null; // Reset to trigger auto-play in build
      }
    });
  }

  void _previousWord(int totalWords, String word) {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        lastPlayedWord = null; // Reset to trigger auto-play in build
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _showExitModal,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
            centerTitle: true,
            title: Text(
              'واژگان',
              style: MyTextStyle.textHeader16Bold,
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is VocabularySuccess) {
                  if (state.vocabulary.data.isEmpty) {
                    return const Center(child: Text('واژگانی یافت نشد'));
                  }

                  final currentWord = state.vocabulary.data[currentIndex];
                  totalWords = state.vocabulary.data.length;

                  // Auto-play word when it changes
                  if (lastPlayedWord != currentWord.word) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _readWord(currentWord.word);
                      if (mounted) {
                        setState(() {
                          lastPlayedWord = currentWord.word;
                        });
                      }
                    });
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final velocity = details.primaryVelocity;
                            if (velocity == null) return;

                            final currentWordObj =
                                state.vocabulary.data[currentIndex];
                            // Swipe right (to previous) - positive velocity
                            if (velocity > 0) {
                              if (currentIndex > 0) {
                                final previousWord = state
                                    .vocabulary.data[currentIndex - 1].word;
                                _previousWord(totalWords, previousWord);
                              }
                            }
                            // Swipe left (to next) - negative velocity
                            else if (velocity < 0) {
                              if (currentIndex < totalWords - 1) {
                                final nextWord = state
                                    .vocabulary.data[currentIndex + 1].word;
                                _nextWord(totalWords, nextWord);
                              }
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
                                  FutureBuilder<String>(
                                    future:
                                        storageService.callGetDownloadPublicUrl(
                                            currentWord.thumbnail),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        return const Icon(Icons.error);
                                      }
                                      if (snapshot.hasData) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                            child: Image.network(
                                              snapshot.data!,
                                              height: 200.h,
                                              width: 200.w,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    currentWord.word,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    currentWord.translation,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.grey,
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
                              onPressed: () {
                                if (currentIndex <
                                    state.vocabulary.data.length - 1) {
                                  final nextWord = state
                                      .vocabulary.data[currentIndex + 1].word;
                                  _nextWord(
                                      state.vocabulary.data.length, nextWord);
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
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
                                          ),
                                        )
                                      : const Icon(Icons.add_circle_outline),
                                  iconSize: 32.r,
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () => _readWord(currentWord.word),
                              icon: IconifyIcon(
                                icon: "cuida:volume-2-outline",
                                size: 32.r,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (currentIndex > 0) {
                                  final previousWord = state
                                      .vocabulary.data[currentIndex - 1].word;
                                  _previousWord(state.vocabulary.data.length,
                                      previousWord);
                                }
                              },
                              icon: const Icon(Icons.arrow_forward),
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
                  return Center(child: Text(state.message));
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
