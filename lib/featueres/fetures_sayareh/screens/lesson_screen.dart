import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/video_downloader_util.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/lesson_card_widget.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/video_container_widget.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/video_progress_bar_widget.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';

class LessonScreen extends StatefulWidget {
  static const routeName = "/lesson_screen";
  final int index;
  final String lessonId;
  final String title;
  final bool purchased;

  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
    required this.lessonId,
    required this.purchased,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String? videoUrl;
  String? localVideoPath;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  bool isDecrypting = false;
  double decryptionProgress = 0.0;
  bool isCheckingFiles = false;
  final StorageService _storageService = locator<StorageService>();
  Lesson? _currentLesson;
  final GlobalKey<CustomVideoPlayerState> _videoPlayerKey =
      GlobalKey<CustomVideoPlayerState>();
  bool _isDisposed = false;

  bool get hasAccess {
    final accessBloc = locator<IknowAccessBloc>();
    return accessBloc.hasCourseAccess(widget.lessonId);
  }

  Future<void> _checkAndDownloadVideo(String videoToCheck) async {
    if (videoToCheck.isEmpty) return;

    setState(() => isCheckingFiles = true);

    // Check for existing files
    final existingPath = await VideoDownloaderUtil.checkExistingFiles(
      name: videoToCheck,
      storageService: _storageService,
      hasAccess: hasAccess,
      onDecrypting: (decrypting) {
        if (!_isDisposed && mounted) {
          setState(() => isDecrypting = decrypting);
        }
      },
      onDecryptionProgress: (progress) {
        if (!_isDisposed && mounted) {
          setState(() => decryptionProgress = progress);
        }
      },
    );

    if (existingPath != null) {
      if (!_isDisposed && mounted) {
        setState(() {
          localVideoPath = existingPath;
          isCheckingFiles = false;
        });
      }
      return;
    }

    if (!_isDisposed && mounted) {
      setState(() => isCheckingFiles = false);
    }

    // Determine which video to download based on login and purchase status
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = prefsOperator.isLoggedIn();
    String? videoToDownload;
    bool usePublicUrl = false;

    if (isLoggedIn &&
        hasAccess &&
        _currentLesson?.video != null &&
        _currentLesson!.video!.isNotEmpty) {
      videoToDownload = _currentLesson!.video;
      usePublicUrl = false;
      print("Using purchased video: $videoToDownload with authenticated URL");
    } else if (_currentLesson?.trailerVideo.isNotEmpty == true) {
      videoToDownload = _currentLesson!.trailerVideo;
      usePublicUrl = true;
      print("Using trailer video: $videoToDownload with public URL");
    }

    if (videoToDownload == null || videoToDownload.isEmpty) return;

    // Start download
    if (!_isDisposed && mounted) {
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0; // Reset progress to 0 when starting download
      });
    }

    await VideoDownloaderUtil.downloadAndStoreVideo(
      storageService: _storageService,
      key: videoToDownload,
      name: videoToDownload,
      fileId: videoToDownload,
      lessonId: widget.lessonId,
      isEncrypted: !usePublicUrl,
      usePublicUrl: usePublicUrl,
      onDownloading: (downloading) {
        if (!_isDisposed && mounted) {
          setState(() => isDownloading = downloading);
        }
      },
      onDownloadProgress: (progress) {
        if (!_isDisposed && mounted) {
          setState(() => downloadProgress = progress);
        }
      },
      onDecrypting: (decrypting) {
        if (!_isDisposed && mounted) {
          setState(() => isDecrypting = decrypting);
        }
      },
      onDecryptionProgress: (progress) {
        if (!_isDisposed && mounted) {
          setState(() => decryptionProgress = progress);
        }
      },
      onSuccess: (path) {
        if (!_isDisposed && mounted) {
          setState(() {
            localVideoPath = path;
            videoUrl = null;
            isDownloading = false;
            isDecrypting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(usePublicUrl ? 'تریلر دانلود شد' : 'فایل دانلود شد'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onError: (error) {
        if (!_isDisposed && mounted) {
          setState(() {
            isDownloading = false;
            isDecrypting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  void _showPurchaseDialog() {
    if (_currentLesson == null) {
      print('No lesson data available for purchase dialog');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => DialogCart(item: _currentLesson!),
    );
  }

  @override
  void initState() {
    super.initState();
    isCheckingFiles = true;
    context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _videoPlayerKey.currentState?.stopVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LessonBloc, LessonState>(
      listener: (context, state) {
        print("LessonBloc state changed: $state");
        if (state is LessonSuccess) {
          if (!_isDisposed && mounted) {
            setState(() => _currentLesson = state.lesson);
          }

          // Determine which video to use
          final prefsOperator = locator<PrefsOperator>();
          final isLoggedIn = prefsOperator.isLoggedIn();
          String? videoToCheck;

          if (isLoggedIn &&
              hasAccess &&
              state.lesson.video != null &&
              state.lesson.video!.isNotEmpty) {
            videoToCheck = state.lesson.video;
            print("Checking for purchased video: $videoToCheck");
          } else {
            videoToCheck = state.lesson.trailerVideo;
            print("Checking for trailer video: $videoToCheck");
          }

          if (videoToCheck != null && videoToCheck.isNotEmpty) {
            _checkAndDownloadVideo(videoToCheck);
          }
        } else if (state is LessonError) {
          print("LessonError: ${state.message}");
          if (mounted) {
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FE),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(57),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
              height: 57,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(33.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<LessonBloc, LessonState>(
                    builder: (context, state) {
                      return Text(
                        state is LessonSuccess
                            ? state.lesson.name
                            : widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D495C),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3D495C),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 28),
          _buildVideoSection(),
          const SizedBox(height: 18),
          _buildConversationCard(),
          const SizedBox(height: 12),
          _buildVocabularyCard(),
          const SizedBox(height: 12),
          _buildQuizCard(),
          const SizedBox(height: 50),
          _buildDictionaryButton(),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Center(
      child: Column(
        children: [
          VideoContainerWidget(
            videoPath: localVideoPath,
            videoUrl: videoUrl,
            isCheckingFiles: isCheckingFiles,
            isDownloading: isDownloading,
            isDecrypting: isDecrypting,
            videoPlayerKey: _videoPlayerKey,
            hasAccess: hasAccess,
            onVideoEnded: () {},
            onShowPurchaseDialog: _showPurchaseDialog,
          ),
          VideoProgressBarWidget(
            isVisible: isDownloading,
            progress: downloadProgress,
            label: 'در حال دانلود...',
          ),
          DecryptionProgressBarWidget(
            isVisible: isDecrypting,
            progress: decryptionProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard() {
    return LessonCardWidget(
      iconPath: "assets/images/chat_icon.png",
      englishLabel: "conversation",
      persianLabel: "مکالمه",
      onTap: () {
        if (!hasAccess) {
          _showPurchaseDialog();
          return;
        }
        Navigator.pushNamed(context, ConversationScreen.routeName,
            arguments: {"conversationId": widget.lessonId});
      },
    );
  }

  Widget _buildVocabularyCard() {
    return LessonCardWidget(
      iconPath: "assets/images/words_icon.png",
      englishLabel: "vocabulary",
      persianLabel: "واژگان",
      badge: Container(
        width: 40,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Word",
            style: TextStyle(
              fontFamily: 'IranSans',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF95D6A4),
            ),
          ),
        ),
      ),
      onTap: () {
        if (!hasAccess) {
          _showPurchaseDialog();
          return;
        }
        Navigator.pushNamed(context, VocabularyScreen.routeName,
            arguments: {"id": widget.lessonId});
      },
    );
  }

  Widget _buildQuizCard() {
    return LessonCardWidget(
      iconPath: "assets/images/quiz_icon.png",
      englishLabel: "Quiz",
      persianLabel: "آزمون",
      onTap: () {
        if (!hasAccess) {
          _showPurchaseDialog();
          return;
        }
        final prefsOperator = locator<PrefsOperator>();
        if (!prefsOperator.isLoggedIn()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لطفا ابتدا وارد حساب کاربری خود شوید'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        Navigator.pushNamed(context, QuizzesScreen.routeName,
            arguments: {"courseId": widget.lessonId});
      },
    );
  }

  Widget _buildDictionaryButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Container(
          width: 63,
          height: 63,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 0),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              // Add your action here
            },
            icon: Image.asset(
              "assets/images/iknow/dictionary_icon.png",
              width: 36,
              height: 36,
            ),
          ),
        ),
      ),
    );
  }
}
