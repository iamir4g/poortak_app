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
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  @override
  void initState() {
    super.initState();
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
    await ttsService.speak(word);
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

  void _nextWord(int totalWords) {
    setState(() {
      if (currentIndex < totalWords - 1) {
        currentIndex++;
      }
    });
  }

  void _previousWord(int totalWords) {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
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
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is LitnerError) {
            // Check if it's the "word already exists" error
            final isWordExistsError = state.message == "این لغت قبلا اضافه شده";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isWordExistsError ? Colors.orange : Colors.red,
              ),
            );
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
              'واژگان',
              style: MyTextStyle.textHeader16Bold,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _showExitModal,
            ),
          ),
          body: BlocBuilder<VocabularyBloc, VocabularyState>(
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
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            //step progress bar
                            StepProgress(
                                currentIndex: currentIndex,
                                totalSteps: totalWords),

                            SizedBox(
                              height: 85,
                            ),
                            FutureBuilder<String>(
                              future: storageService.callGetDownloadPublicUrl(
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
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        snapshot.data!,
                                        height: 264,
                                        width: 264,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              currentWord.word,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentWord.translation,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _nextWord(state.vocabulary.data.length),
                            icon: const Icon(Icons.arrow_back),
                            iconSize: 32,
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
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_circle_outline),
                                iconSize: 32,
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () => _readWord(currentWord.word),
                            icon: IconifyIcon(
                              icon: "cuida:volume-2-outline",
                              size: 32,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _previousWord(state.vocabulary.data.length),
                            icon: const Icon(Icons.arrow_forward),
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ),
                    if (currentIndex == totalWords - 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
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
    );
  }
}
