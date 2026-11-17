import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/services/iknow_voice_cache_service.dart';
import 'package:poortak/common/services/iknow_voice_player.dart';
import 'package:poortak/common/utils/sentence_splitter.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
import 'package:poortak/featueres/feature_sayareh/widgets/conversation_message_bubble.dart';

/// صفحه نمایش مکالمه بین دو شخص
/// این صفحه لیستی از پیام‌های مکالمه را نمایش می‌دهد و امکان پخش صوتی و نمایش ترجمه را فراهم می‌کند
class ConversationScreen extends StatefulWidget {
  static const routeName = "/conversation_screen";
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final IKnowVoiceCacheService _voiceCache = locator<IKnowVoiceCacheService>();
  final IKnowVoicePlayer _voicePlayer = IKnowVoicePlayer();

  late ConverstionBloc _converstionBloc;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<int> currentPlayingIndexNotifier = ValueNotifier(0);
  final ValueNotifier<int> currentSentenceIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _sentenceFocusNotifier = ValueNotifier(false);

  List<Datum>? sortedMessages;

  final ValueNotifier<bool> showTranslationsNotifier = ValueNotifier(true);

  int _playbackSessionId = 0;

  bool _shouldPromptPlaybackMode = false;
  bool _isPlaybackChoiceDialogOpen = false;

  /// False until the first two voice files (when present) are ready.
  bool _voicesReady = false;
  bool _isPreloadingVoices = false;
  String? _preloadedCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _converstionBloc = ConverstionBloc(
      sayarehRepository: locator(),
    )..add(GetConversationEvent(id: widget.conversationId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      isPlayingNotifier.value = false;
      _playbackSessionId++;
      unawaited(_voicePlayer.stop());
    }
  }

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  final Map<int, Map<int, GlobalKey>> _messageSentenceKeys = {};
  int _lastScrolledMessageIndex = -1;
  int _lastScrolledSentenceIndex = -1;
  static const double _estimatedMessageItemHeight = 92;

  Map<int, GlobalKey> _getSentenceKeysForMessage(
    int messageIndex,
    int sentenceCount,
  ) {
    _messageSentenceKeys[messageIndex] ??= {};
    final keys = _messageSentenceKeys[messageIndex]!;
    for (var i = 0; i < sentenceCount; i++) {
      keys[i] ??= GlobalKey();
    }
    return keys;
  }

  void _resetScrollTracking() {
    _lastScrolledMessageIndex = -1;
    _lastScrolledSentenceIndex = -1;
  }

  void _scrollToCurrentSentence(
    int messageIndex,
    int sentenceIndex, {
    bool force = false,
  }) {
    if (!force &&
        messageIndex == _lastScrolledMessageIndex &&
        sentenceIndex == _lastScrolledSentenceIndex) {
      return;
    }

    _lastScrolledMessageIndex = messageIndex;
    _lastScrolledSentenceIndex = sentenceIndex;
    _ensureSentenceVisible(messageIndex, sentenceIndex);
  }

  void _ensureSentenceVisible(
    int messageIndex,
    int sentenceIndex, {
    int attemptsLeft = 10,
    bool animate = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_scrollController.hasClients) {
        if (attemptsLeft > 0) {
          _ensureSentenceVisible(
            messageIndex,
            sentenceIndex,
            attemptsLeft: attemptsLeft - 1,
            animate: animate,
          );
        }
        return;
      }

      final key = _messageSentenceKeys[messageIndex]?[sentenceIndex];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: animate ? const Duration(milliseconds: 600) : Duration.zero,
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
        return;
      }

      if (attemptsLeft <= 0) return;

      final maxOffset = _scrollController.position.maxScrollExtent;
      final targetOffset =
          (messageIndex * _estimatedMessageItemHeight).clamp(0.0, maxOffset);
      if (_scrollController.offset != targetOffset) {
        _scrollController.jumpTo(targetOffset);
      }

      _ensureSentenceVisible(
        messageIndex,
        sentenceIndex,
        attemptsLeft: attemptsLeft - 1,
        animate: animate,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_voicePlayer.dispose());
    _converstionBloc.close();
    isPlayingNotifier.dispose();
    currentPlayingIndexNotifier.dispose();
    currentSentenceIndexNotifier.dispose();
    showTranslationsNotifier.dispose();
    _sentenceFocusNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Datum> _visibleMessages(List<Datum> messages) {
    return messages.where((item) => !item.isDisabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<VoicePrefetchItem> _voiceItemsFromMessages(List<Datum> messages) {
    return messages
        .where((m) => m.voiceFileId != null && m.voiceFileId!.trim().isNotEmpty)
        .map(
          (m) => VoicePrefetchItem(
            fileId: m.voiceFileId!,
            checksum: m.voiceChecksum,
          ),
        )
        .toList();
  }

  Future<void> _preloadInitialVoices(List<Datum> messages) async {
    if (_isPreloadingVoices) return;
    if (_preloadedCourseId == widget.conversationId && _voicesReady) return;

    _isPreloadingVoices = true;
    if (mounted && _voicesReady) {
      setState(() => _voicesReady = false);
    }

    try {
      final withVoice = messages
          .where(
              (m) => m.voiceFileId != null && m.voiceFileId!.trim().isNotEmpty)
          .toList();

      final firstTwo = withVoice.take(2).toList();
      await Future.wait(
        firstTwo.map(
          (m) => _voiceCache.ensureVoice(
            fileId: m.voiceFileId!,
            checksum: m.voiceChecksum,
          ),
        ),
      );

      // Prefetch the rest in background.
      final remaining = withVoice.skip(firstTwo.length).toList();
      if (remaining.isNotEmpty) {
        unawaited(
          _voiceCache.prefetchVoices(_voiceItemsFromMessages(remaining)),
        );
      }
    } finally {
      _isPreloadingVoices = false;
      _preloadedCourseId = widget.conversationId;
      if (mounted) {
        setState(() => _voicesReady = true);
        if (_shouldPromptPlaybackMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_shouldPromptPlaybackMode) return;
            _showPlaybackModeModal(messages);
          });
        }
      } else {
        _voicesReady = true;
      }
    }
  }

  Widget _buildEmptyConversation(Color textColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Text(
          'مکالمه‌ای یافت نشد',
          style: MyTextStyle.textMatn16.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showForbiddenAccessModal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ReusableModal.show(
        context: context,
        title: 'دسترسی محدود',
        message: 'برای مشاهده مکالمه باید این درس را خریده باشید.',
        type: ModalType.info,
        buttonText: 'بازگشت',
        onButtonPressed: () {
          Navigator.of(context).pop();
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      );
    });
  }

  void _savePlayback(String conversationId) {
    debugPrint(
      '🌐 [PLAYBACK] save conversationId=$conversationId courseId=${widget.conversationId}',
    );
    _converstionBloc.add(
      SaveConversationPlaybackEvent(
        courseId: widget.conversationId,
        conversationId: conversationId,
      ),
    );
  }

  void _onPlayButtonPressed(List<Datum> messages) {
    if (!_voicesReady) return;
    if (!isPlayingNotifier.value &&
        _shouldPromptPlaybackMode &&
        currentPlayingIndexNotifier.value > 0) {
      _showPlaybackModeModal(messages);
      return;
    }
    playAllConversations(messages);
  }

  void _showPlaybackModeModal(List<Datum> messages) {
    if (_isPlaybackChoiceDialogOpen) return;
    _isPlaybackChoiceDialogOpen = true;

    ReusableModal.show(
      context: context,
      title: 'نحوه پخش مکالمه',
      message: '',
      type: ModalType.info,
      customImagePath: 'assets/images/iknow/Frame 412.png',
      buttonText: 'ادامه مکالمه',
      secondButtonText: 'پخش از ابتدا',
      showSecondButton: true,
      onButtonPressed: () {
        Navigator.of(context).pop();
        _shouldPromptPlaybackMode = false;
        playAllConversations(messages);
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop();
        _shouldPromptPlaybackMode = false;
        currentPlayingIndexNotifier.value = 0;
        currentSentenceIndexNotifier.value = 0;
        _resetScrollTracking();
        _scrollToCurrentSentence(0, 0, force: true);
        playAllConversations(messages);
      },
    ).whenComplete(() {
      _isPlaybackChoiceDialogOpen = false;
    });
  }

  Future<void> playAllConversations(List<Datum> messages) async {
    if (isPlayingNotifier.value) {
      isPlayingNotifier.value = false;
      await _voicePlayer.stop();
      return;
    }

    _playbackSessionId++;
    final int mySessionId = _playbackSessionId;
    _resetScrollTracking();
    isPlayingNotifier.value = true;

    _scrollToCurrentSentence(
      currentPlayingIndexNotifier.value,
      0,
      force: true,
    );

    if (currentPlayingIndexNotifier.value >= messages.length) {
      currentPlayingIndexNotifier.value = 0;
      currentSentenceIndexNotifier.value = 0;
    }

    try {
      for (var i = currentPlayingIndexNotifier.value;
          i < messages.length;
          i++) {
        if (!mounted) break;
        if (!isPlayingNotifier.value || _playbackSessionId != mySessionId) {
          break;
        }

        final message = messages[i];
        currentPlayingIndexNotifier.value = i;
        currentSentenceIndexNotifier.value = 0;

        if (mounted &&
            isPlayingNotifier.value &&
            _playbackSessionId == mySessionId) {
          _savePlayback(message.id);
        }

        try {
          if (!isPlayingNotifier.value || _playbackSessionId != mySessionId) {
            break;
          }
          await _playMessageVoice(message);
        } catch (e) {
          debugPrint('Error during message playback: $e');
        }

        if (!isPlayingNotifier.value || _playbackSessionId != mySessionId) {
          break;
        }

        // Short pause between messages
        await Future.delayed(const Duration(milliseconds: 400));
        if (!isPlayingNotifier.value || _playbackSessionId != mySessionId) {
          break;
        }
      }
    } finally {
      if (mounted &&
          isPlayingNotifier.value &&
          _playbackSessionId == mySessionId) {
        isPlayingNotifier.value = false;
        currentPlayingIndexNotifier.value = 0;
        currentSentenceIndexNotifier.value = 0;
      }
    }
  }

  Future<void> _playMessageVoice(Datum message) async {
    final fileId = message.voiceFileId?.trim();
    if (fileId == null || fileId.isEmpty) return;

    final path = await _voiceCache.ensureVoice(
      fileId: fileId,
      checksum: message.voiceChecksum,
    );
    if (path == null) return;
    await _voicePlayer.playFile(path);
  }

  Future<void> speakText(Datum message, String conversationId) async {
    if (isPlayingNotifier.value) {
      isPlayingNotifier.value = false;
      await _voicePlayer.stop();
    }

    _savePlayback(conversationId);
    await _playMessageVoice(message);
  }

  Future<void> _playNext() async {
    if (sortedMessages == null || sortedMessages!.isEmpty) return;

    bool wasPlaying = isPlayingNotifier.value;
    if (wasPlaying) {
      await _voicePlayer.stop();
      isPlayingNotifier.value = false;
    }

    if (currentPlayingIndexNotifier.value < sortedMessages!.length - 1) {
      currentPlayingIndexNotifier.value++;
      currentSentenceIndexNotifier.value = 0;
    }

    _scrollToCurrentSentence(
      currentPlayingIndexNotifier.value,
      0,
      force: true,
    );
    _sentenceFocusNotifier.value = true;

    if (wasPlaying) {
      playAllConversations(sortedMessages!);
    }
  }

  Future<void> _playPrevious() async {
    if (sortedMessages == null || sortedMessages!.isEmpty) return;

    bool wasPlaying = isPlayingNotifier.value;
    if (wasPlaying) {
      await _voicePlayer.stop();
      isPlayingNotifier.value = false;
    }

    if (currentPlayingIndexNotifier.value > 0) {
      currentPlayingIndexNotifier.value--;
      currentSentenceIndexNotifier.value = 0;
    }

    _scrollToCurrentSentence(
      currentPlayingIndexNotifier.value,
      0,
      force: true,
    );
    _sentenceFocusNotifier.value = true;

    if (wasPlaying) {
      playAllConversations(sortedMessages!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackgroundColor = isDark
        ? MyColors.profileBackgroundDark
        : MyColors.conversationScreenBackgroundLight;
    final primaryTextColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;
    final iconColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textPrimary;
    return BlocProvider.value(
      value: _converstionBloc,
      child: Scaffold(
        backgroundColor: pageBackgroundColor,
        appBar: PoortakAppBar(
          title: 'مکالمه',
          foregroundColor: primaryTextColor,
        ),
        bottomNavigationBar: BlocBuilder<ConverstionBloc, ConverstionState>(
          builder: (context, state) {
            final hasMessages = state is ConverstionSuccess &&
                _visibleMessages(state.data.data).isNotEmpty;
            if (!hasMessages || !_voicesReady) {
              return const SizedBox.shrink();
            }
            return SafeArea(
              child: SizedBox(
                height: 94.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _playNext();
                          },
                          icon: SvgPicture.asset(
                            'assets/images/icons/ri--skip-right-fill.svg',
                            width: 30.r,
                            height: 30.r,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: Dimens.medium),
                        ValueListenableBuilder<bool>(
                          valueListenable: isPlayingNotifier,
                          builder: (context, isPlaying, _) {
                            final bgColor = isPlaying
                                ? MyColors.primary
                                : (isDark
                                    ? MyColors.conversationPlayPauseDarkPaused
                                    : MyColors.gray);
                            final icon =
                                isPlaying ? Icons.pause : Icons.play_arrow;
                            final iconFg = isPlaying
                                ? Colors.white
                                : (isDark ? Colors.white : MyColors.text2);

                            return SizedBox(
                              width: 60.r,
                              height: 60.r,
                              child: Material(
                                color: bgColor,
                                shape: const CircleBorder(),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (sortedMessages != null) {
                                      _onPlayButtonPressed(sortedMessages!);
                                    }
                                  },
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      size: 34.r,
                                      color: iconFg,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: Dimens.medium),
                        IconButton(
                          onPressed: () {
                            _playPrevious();
                          },
                          icon: SvgPicture.asset(
                            'assets/images/icons/ri--skip-left-fill.svg',
                            width: 30.r,
                            height: 30.r,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PositionedDirectional(
                      start: Dimens.xLarge,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: showTranslationsNotifier,
                        builder: (context, showTranslations, _) {
                          final labelColor = showTranslations
                              ? MyColors.secondary
                              : (isDark
                                  ? MyColors.loginTextSecondaryDark
                                  : MyColors.textSecondary);

                          return Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                showTranslationsNotifier.value =
                                    !showTranslationsNotifier.value;
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.small,
                                  vertical: 4.h,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      size: 22.r,
                                      color: labelColor,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'ترجمه',
                                      style: MyTextStyle.textMatn10W300.copyWith(
                                        color: labelColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        body: SafeArea(
          top: false,
          child: BlocListener<ConverstionBloc, ConverstionState>(
            listener: (context, state) {
              if (state is ConverstionError &&
                  state.errorCode == 'forbidden') {
                _showForbiddenAccessModal();
                return;
              }
              if (state is ConverstionSuccess) {
                final messages = _visibleMessages(state.data.data);
                unawaited(_preloadInitialVoices(messages));

                if (state.lastConversationId != null) {
                  final index = messages
                      .indexWhere((m) => m.id == state.lastConversationId);

                  if (index != -1) {
                    currentPlayingIndexNotifier.value = index;
                    _shouldPromptPlaybackMode = index > 0;
                    _resetScrollTracking();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _scrollToCurrentSentence(
                        index,
                        currentSentenceIndexNotifier.value,
                        force: true,
                      );
                    });
                  }
                }
              }
            },
            child: BlocBuilder<ConverstionBloc, ConverstionState>(
              builder: (context, state) {
                if (state is ConverstionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(MyColors.primary),
                    ),
                  );
                }

                if (state is ConverstionError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        state.message,
                        style: MyTextStyle.textMatn16.copyWith(
                          color: primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (state is ConverstionSuccess) {
                  sortedMessages = _visibleMessages(state.data.data);
                  if (sortedMessages!.isEmpty) {
                    return _buildEmptyConversation(primaryTextColor);
                  }
                  if (!_voicesReady) {
                    return Center(
                      child: DotLoadingWidget(
                        size: 10.r,
                        color: MyColors.primary,
                      ),
                    );
                  }
                  return _buildConversationList(context, state.data);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, ConversationModel data) {
    return ValueListenableBuilder<bool>(
      valueListenable: showTranslationsNotifier,
      builder: (context, showTranslations, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: isPlayingNotifier,
          builder: (context, isPlaybackActive, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _sentenceFocusNotifier,
              builder: (context, sentenceFocus, _) {
                final highlightCurrentSentence =
                    isPlaybackActive || sentenceFocus;
                return ValueListenableBuilder<int>(
                  valueListenable: currentPlayingIndexNotifier,
                  builder: (context, currentPlayingIndex, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: currentSentenceIndexNotifier,
                      builder: (context, currentSentenceIndex, _) {
                        if (highlightCurrentSentence) {
                          _scrollToCurrentSentence(
                            currentPlayingIndex,
                            currentSentenceIndex,
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: sortedMessages?.length ?? 0,
                          itemBuilder: (context, index) {
                            final message = sortedMessages![index];
                            final sentenceCount =
                                splitIntoSentences(message.text, trim: true)
                                    .length;
                            final sentenceKeys = _getSentenceKeysForMessage(
                              index,
                              sentenceCount,
                            );

                            _itemKeys[index] ??= GlobalKey();

                            final isCurrentPlaying = sortedMessages != null &&
                                currentPlayingIndex < sortedMessages!.length &&
                                sortedMessages![currentPlayingIndex].id ==
                                    message.id;

                            return ConversationMessageBubble(
                              key: _itemKeys[index],
                              message: message,
                              isCurrentPlaying: isCurrentPlaying,
                              isPlaybackActive: highlightCurrentSentence,
                              currentSentenceIndex: isCurrentPlaying
                                  ? currentSentenceIndex
                                  : 0,
                              sentenceKeys: sentenceKeys,
                              showTranslations: showTranslations,
                              onTap: () {
                                speakText(
                                  message,
                                  message.id,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
