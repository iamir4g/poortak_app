import 'package:poortak/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/video_download_service.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/course_progress_model.dart';
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
import 'package:poortak/featueres/fetures_sayareh/widgets/dictionary_bottom_sheet.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

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

class _LessonScreenState extends State<LessonScreen> with RouteAware {
  String? videoUrl;
  String? localVideoPath;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  bool isDecrypting = false;
  double decryptionProgress = 0.0;
  bool isCheckingFiles = false;
  final VideoDownloadService _downloadService = locator<VideoDownloadService>();
  final VideoDownloadCubit _downloadCubit = locator<VideoDownloadCubit>();
  Lesson? _currentLesson;
  CourseProgressData? _progress;
  String? _currentVideoName;
  final GlobalKey<CustomVideoPlayerState> _videoPlayerKey =
      GlobalKey<CustomVideoPlayerState>();
  bool _isDisposed = false;
  String? _thumbnailUrl;
  bool _isCompletionPopupShown = false;

  bool get hasAccess {
    final prefsOperator = locator<PrefsOperator>();
    if (!prefsOperator.isLoggedIn()) return false;
    if (widget.purchased == true) return true;
    final accessBloc = locator<IknowAccessBloc>();
    return accessBloc.hasCourseAccess(widget.lessonId);
  }

  Future<void> _checkAndDownloadVideo(String _, {bool autoStart = true}) async {
    final lesson = _currentLesson;
    if (lesson == null) return;

    final hasPaidAccess = hasAccess;
    String? videoId;
    bool usePublicUrl = false;
    bool isEncrypted = true;

    if (hasPaidAccess && lesson.video != null && lesson.video!.isNotEmpty) {
      videoId = lesson.video;
      usePublicUrl = false;
      isEncrypted = true;
    } else if (lesson.isDemo && lesson.trailerVideo.isNotEmpty) {
      videoId = lesson.trailerVideo;
      usePublicUrl = true;
      isEncrypted = false;
    } else if (lesson.trailerVideo.isNotEmpty) {
      videoId = lesson.trailerVideo;
      usePublicUrl = true;
      isEncrypted = false;
    } else if (lesson.video != null && lesson.video!.isNotEmpty) {
      videoId = lesson.video;
      usePublicUrl = false;
      isEncrypted = true;
    }

    if (videoId == null || videoId.isEmpty) return;

    if (_currentVideoName != videoId) {
      _videoPlayerKey.currentState?.stopVideo();
      if (!_isDisposed && mounted) {
        setState(() {
          localVideoPath = null;
          videoUrl = null;
          isCheckingFiles = true;
          isDownloading = false;
          isDecrypting = false;
          downloadProgress = 0.0;
          decryptionProgress = 0.0;
        });
      }
      _currentVideoName = videoId;
    }

    await _downloadService.checkAndDownloadVideo(
      videoName: videoId,
      lessonId: widget.lessonId,
      hasAccess: hasPaidAccess,
      isEncrypted: isEncrypted,
      usePublicUrl: usePublicUrl,
      videoKey: videoId,
      autoStart: autoStart,
    );
  }

  void _updateLocalStateFromCubit(VideoDownloadInfo? downloadInfo) {
    if (downloadInfo == null || _isDisposed || !mounted) return;

    setState(() {
      isCheckingFiles = downloadInfo.isCheckingFiles;
      isDownloading = downloadInfo.isDownloading;
      downloadProgress = downloadInfo.downloadProgress;
      isDecrypting = downloadInfo.isDecrypting;
      decryptionProgress = downloadInfo.decryptionProgress;
      if (downloadInfo.localPath != null) {
        localVideoPath = downloadInfo.localPath;
        videoUrl = null;
      }
    });

    // Show success/error messages only once
    if (downloadInfo.status == DownloadStatus.completed &&
        downloadInfo.localPath != null) {
      final prefsOperator = locator<PrefsOperator>();
      final isLoggedIn = prefsOperator.isLoggedIn();
      final usePublicUrl = !(isLoggedIn &&
          hasAccess &&
          _currentLesson?.video != null &&
          _currentLesson!.video!.isNotEmpty);

      // Only show snackbar if we just completed (check previous state)
      final previousInfo =
          _downloadCubit.getDownloadInfo(_currentVideoName ?? '');
      if (previousInfo?.status != DownloadStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(usePublicUrl ? 'تریلر دانلود شد' : 'فایل دانلود شد'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (downloadInfo.status == DownloadStatus.error &&
        downloadInfo.error != null) {
      // Only show error toast for real errors, not connectivity issues (which are paused)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(downloadInfo.error!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // Note: paused status doesn't show toast - download will resume automatically when internet reconnects
  }

  void _showPurchaseDialog() {
    if (_currentLesson == null) {
      debugPrint('No lesson data available for purchase dialog');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => DialogCart(item: _currentLesson!),
    );
  }

  void _handleVideoEnded() {
    if (_isDisposed || !mounted) return;
    if (hasAccess) return;
    final lesson = _currentLesson;
    final currentVideoName = _currentVideoName;
    if (lesson == null || currentVideoName == null) return;
    if (!lesson.isDemo) return;
    final isTrailer = lesson.trailerVideo.isNotEmpty &&
        currentVideoName == lesson.trailerVideo;
    if (!isTrailer) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showPurchaseDialog();
    });
  }

  @override
  void initState() {
    super.initState();
    isCheckingFiles = true;
    context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final prefsOperator = locator<PrefsOperator>();
      if (prefsOperator.isLoggedIn()) {
        locator<IknowAccessBloc>()
            .add(FetchIknowAccessEvent(forceRefresh: true));
      }
    });

    // Check if there's an existing download for this lesson
    // This will be updated when we know the video name
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen for route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Unregister from route observer
    routeObserver.unsubscribe(this);
    _videoPlayerKey.currentState?.stopVideo();
    super.dispose();
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and the current route is no longer visible.
    // Pause video playback
    debugPrint("Pausing video because a new screen was pushed");
    _videoPlayerKey.currentState?.stopVideo();
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<IknowAccessBloc, IknowAccessState>(
          bloc: locator<IknowAccessBloc>(),
          listener: (context, state) {
            if (!mounted || _isDisposed) return;
            if (state is IknowAccessCompleted) {
              setState(() {});
              _checkAndDownloadVideo('', autoStart: false);
            }
          },
        ),
        BlocListener<LessonBloc, LessonState>(
          listener: (context, state) {
            debugPrint("LessonBloc state changed: $state");
            if (state is LessonSuccess) {
              if (!_isDisposed && mounted) {
                setState(() {
                  _currentLesson = state.lesson;
                  _progress = state.progress;
                });
              }

              if (state.progress != null) {
                final p = state.progress!;
                final isCompleted = p.vocabulary == 100 &&
                    p.conversation == 100 &&
                    p.quiz == 100;

                if (isCompleted && !_isCompletionPopupShown) {
                  _isCompletionPopupShown = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ReusableModal.showSuccess(
                        context: context,
                        title: 'تبریک!',
                        message: 'شما این درس را با موفقیت به پایان رساندید.',
                        customLottiePath: 'assets/lottie/Happy_Star.json',
                        buttonText: 'متوجه شدم',
                      );
                    }
                  });
                }
              }

              () async {
                final key = state.lesson.thumbnail;
                if (key.isNotEmpty) {
                  final imageUrl = await GetImageUrlService().getImageUrl(key);
                  if (mounted) {
                    setState(() {
                      _thumbnailUrl = imageUrl.isNotEmpty ? imageUrl : null;
                    });
                  }
                }
              }();

              _checkAndDownloadVideo('', autoStart: false);
            } else if (state is LessonError) {
              debugPrint("LessonError: ${state.message}");
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
        ),
        BlocListener<VideoDownloadCubit, VideoDownloadState>(
          bloc: _downloadCubit,
          listener: (context, state) {
            if (_currentVideoName != null && state is VideoDownloadLoaded) {
              final downloadInfo = state.downloads[_currentVideoName];
              _updateLocalStateFromCubit(downloadInfo);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? MyColors.profileBackgroundDark
            : MyColors.background3,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(Dimens.nh(57)),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
              height: Dimens.nh(57),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? MyColors.darkBackgroundSecondary
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimens.nr(33.5)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: Dimens.nr(1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<LessonBloc, LessonState>(
                    builder: (context, state) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        state is LessonSuccess
                            ? state.lesson.name
                            : widget.title,
                        textAlign: TextAlign.center,
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          fontSize: Dimens.nsp(16),
                          color: isDark
                              ? MyColors.profileTextPrimaryDark
                              : MyColors.text2,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: Dimens.nw(40),
                    height: Dimens.nh(40),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? MyColors.profileTextPrimaryDark
                            : MyColors.text2,
                        size: Dimens.nsp(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(child: _buildContent(context)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
      child: Column(
        children: [
          SizedBox(height: Dimens.nh(15)), // Reduced from 28
          _buildVideoSection(),
          SizedBox(height: Dimens.nh(15)), // Reduced from 18
          _buildConversationCard(),
          SizedBox(height: Dimens.nh(10)), // Reduced from 12
          _buildVocabularyCard(),
          SizedBox(height: Dimens.nh(10)), // Reduced from 12
          _buildQuizCard(),
          SizedBox(height: Dimens.nh(60)), // Reduced from 88
          _buildDictionaryButton(),
        ],
      ),
    );
  }

  Widget _buildCompletionHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimens.nw(16)),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(Dimens.nr(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: Dimens.nr(10),
            offset: Offset(0, Dimens.nh(4)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'خوانده شده',
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        fontSize: Dimens.nsp(14),
                        color: isDark
                            ? MyColors.profileTextPrimaryDark
                            : MyColors.text2,
                      ),
                    ),
                    SizedBox(width: Dimens.nw(8)),
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: Dimens.nsp(24),
                    ),
                  ],
                ),
                SizedBox(height: Dimens.nh(16)),
                SizedBox(
                  height: Dimens.nh(48),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<LessonBloc>()
                          .add(ResetLessonProgressEvent(id: widget.lessonId));
                      setState(() {
                        _isCompletionPopupShown = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F29),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(25)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'مرور دوباره درس',
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        fontSize: Dimens.nsp(16),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimens.nw(16)),
          Image.asset(
            'assets/images/iknow/medal.png',
            width: Dimens.nw(90),
            height: Dimens.nh(90),
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    // Check if completed
    if (_progress != null &&
        _progress!.vocabulary == 100 &&
        _progress!.conversation == 100 &&
        _progress!.quiz == 100) {
      return _buildCompletionHeader();
    }

    // Listen to download cubit for real-time updates
    return BlocBuilder<VideoDownloadCubit, VideoDownloadState>(
      bloc: _downloadCubit,
      builder: (context, state) {
        // Get current download info from cubit
        VideoDownloadInfo? downloadInfo;
        if (_currentVideoName != null && state is VideoDownloadLoaded) {
          downloadInfo = state.downloads[_currentVideoName];
        }

        // Use cubit state if available, otherwise use local state
        final currentIsCheckingFiles =
            downloadInfo?.isCheckingFiles ?? isCheckingFiles;
        final currentIsDownloading =
            downloadInfo?.isDownloading ?? isDownloading;
        final currentDownloadProgress =
            downloadInfo?.downloadProgress ?? downloadProgress;
        final currentIsDecrypting = downloadInfo?.isDecrypting ?? isDecrypting;
        final currentDecryptionProgress =
            downloadInfo?.decryptionProgress ?? decryptionProgress;
        final currentLocalPath = downloadInfo?.localPath ?? localVideoPath;

        return Center(
          child: Column(
            children: [
              VideoContainerWidget(
                videoPath: currentLocalPath,
                videoUrl: videoUrl,
                thumbnailUrl: _thumbnailUrl,
                isCheckingFiles: currentIsCheckingFiles,
                isDownloading: currentIsDownloading,
                isDecrypting: currentIsDecrypting,
                videoPlayerKey: _videoPlayerKey,
                hasAccess: hasAccess,
                onVideoEnded: _handleVideoEnded,
                onShowPurchaseDialog: _showPurchaseDialog,
                onDownload: () {
                  _checkAndDownloadVideo('', autoStart: true);
                },
              ),
              VideoProgressBarWidget(
                isVisible: currentIsDownloading,
                progress: currentDownloadProgress,
                label: 'در حال دانلود...',
              ),
              DecryptionProgressBarWidget(
                isVisible: currentIsDecrypting,
                progress: currentDecryptionProgress,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConversationCard() {
    return LessonCardWidget(
      iconPath: "assets/images/chat_icon.png",
      englishLabel: "conversation",
      persianLabel: "مکالمه",
      progress: _progress?.conversation,
      onTap: () async {
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
        await Navigator.pushNamed(context, ConversationScreen.routeName,
            arguments: {"conversationId": widget.lessonId});
        if (mounted) {
          context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
        }
      },
    );
  }

  Widget _buildVocabularyCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LessonCardWidget(
      iconPath: "assets/images/points/words_icon.png",
      englishLabel: "vocabulary",
      persianLabel: "واژگان",
      progress: _progress?.vocabulary,
      badge: Container(
        width: Dimens.nw(40),
        height: Dimens.nh(15),
        decoration: BoxDecoration(
          color: isDark ? MyColors.profileHeaderDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(8)),
        ),
        child: Center(
          child: Text(
            "Word",
            style: TextStyle(
              fontFamily: 'IranSans',
              fontSize: Dimens.nsp(10),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF95D6A4),
            ),
          ),
        ),
      ),
      onTap: () async {
        if (!hasAccess) {
          _showPurchaseDialog();
          return;
        }
        await Navigator.pushNamed(context, VocabularyScreen.routeName,
            arguments: {"id": widget.lessonId});
        if (mounted) {
          context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
        }
      },
    );
  }

  Widget _buildQuizCard() {
    return LessonCardWidget(
      iconPath: "assets/images/points/quiz_icon.png",
      englishLabel: "Quiz",
      persianLabel: "آزمون",
      progress: _progress?.quiz,
      onTap: () async {
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
        await Navigator.pushNamed(context, QuizzesScreen.routeName,
            arguments: {"courseId": widget.lessonId});
        if (mounted) {
          context.read<LessonBloc>().add(GetLessonEvenet(id: widget.lessonId));
        }
      },
    );
  }

  Widget _buildDictionaryButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: Dimens.nw(20)),
        child: Container(
          width: Dimens.nw(63),
          height: Dimens.nh(63),
          decoration: BoxDecoration(
            color: isDark ? MyColors.profileHeaderDark : Colors.white,
            borderRadius: BorderRadius.circular(Dimens.nr(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 0),
                blurRadius: Dimens.nr(4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const DictionaryBottomSheet(),
              );
            },
            icon: buildImageFromAssetOrEmbeddedSvg(
              "assets/images/iknow/dictionary_icon.svg",
              width: Dimens.nw(36),
              height: Dimens.nh(36),
            ),
          ),
        ),
      ),
    );
  }
}
