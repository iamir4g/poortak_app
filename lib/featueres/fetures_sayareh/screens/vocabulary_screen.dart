import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/vocabulary_bloc/vocabulary_bloc.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/models/download_url_response.dart';

class VocabularyScreen extends StatefulWidget {
  static const routeName = "/vocabulary_screen";
  final String id;
  const VocabularyScreen({super.key, required this.id});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int currentIndex = 0;
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();

  @override
  void initState() {
    super.initState();
  }

  void _addToListener() {
    debugPrint('Added to listener');
  }

  void _readWord(String word) async {
    await ttsService.speak(word);
  }

  void _nextWord(int totalWords) {
    setState(() {
      if (currentIndex < totalWords - 1) {
        currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VocabularyBloc(sayarehRepository: locator())
        ..add(VocabularyFetchEvent(id: widget.id)),
      child: Scaffold(
        backgroundColor: MyColors.secondaryTint4,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
            ),
          ),
          title: const Text('واژگان'),
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

              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<GetDownloadUrl>(
                            future: storageService
                                .callGetDownloadUrl(currentWord.thumbnail),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              }
                              if (snapshot.hasData) {
                                return Image.network(
                                  snapshot.data!.data,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
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
                          onPressed: _addToListener,
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                        ),
                        IconButton(
                          onPressed: () => _readWord(currentWord.word),
                          icon: const Icon(Icons.volume_up),
                          iconSize: 32,
                        ),
                        IconButton(
                          onPressed: () =>
                              _nextWord(state.vocabulary.data.length),
                          icon: const Icon(Icons.arrow_forward),
                          iconSize: 32,
                        ),
                      ],
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
    );
  }
}
