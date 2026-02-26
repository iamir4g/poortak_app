import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/conversation_message_bubble.dart';
// import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_event.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_state.dart';

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

class _ConversationScreenState extends State<ConversationScreen> {
  // سرویس TTS برای پخش صوتی متن‌ها
  final TTSService ttsService = locator<TTSService>();

  late ConverstionBloc _converstionBloc;

  // مشخص می‌کند که آیا در حال پخش تمام مکالمه است
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  // ایندکس پیام فعلی که در حال پخش است
  final ValueNotifier<int> currentPlayingIndexNotifier = ValueNotifier(0);

  // لیست پیام‌های مرتب شده بر اساس order
  List<Datum>? sortedMessages;

  // مشخص می‌کند که آیا ترجمه‌ها باید نمایش داده شوند
  final ValueNotifier<bool> showTranslationsNotifier = ValueNotifier(false);

  // شمارنده برای ارسال دوره‌ای وضعیت پخش به سرور
  int _messagesPlayedSinceLastSave = 0;
  static const int _saveInterval = 3;

  // شناسه جلسه پخش برای جلوگیری از تداخل پخش‌ها
  int _playbackSessionId = 0;

  // تایمر برای جلوگیری از ارسال درخواست‌های تکراری و پشت سر هم
  Timer? _savePlaybackDebounceTimer;

  @override
  void initState() {
    super.initState();
    _converstionBloc = ConverstionBloc(
      sayarehRepository: locator(),
    )..add(GetConversationEvent(id: widget.conversationId));
  }

  final ScrollController _scrollController = ScrollController();
  // مپ برای ذخیره GlobalKey هر آیتم جهت اسکرول دقیق
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void dispose() {
    // توقف پخش در صورت خروج از صفحه
    ttsService.stop();
    _converstionBloc.close();
    isPlayingNotifier.dispose();
    currentPlayingIndexNotifier.dispose();
    showTranslationsNotifier.dispose();
    _savePlaybackDebounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// ذخیره وضعیت پخش در سرور
  void _savePlayback(String conversationId) {
    // اگر تایمری فعال است، آن را کنسل کن
    if (_savePlaybackDebounceTimer?.isActive ?? false) {
      _savePlaybackDebounceTimer!.cancel();
    }

    // ایجاد تایمر جدید
    _savePlaybackDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _converstionBloc.add(
          SaveConversationPlaybackEvent(
            courseId: widget.conversationId,
            conversationId: conversationId,
          ),
        );
      }
    });
  }

  /// پخش تمام پیام‌های مکالمه به ترتیب
  /// در صورت فعال بودن پخش، با فراخوانی این متد پخش متوقف می‌شود
  Future<void> playAllConversations(List<Datum> messages) async {
    // اگر در حال پخش است، پخش را متوقف کن
    if (isPlayingNotifier.value) {
      await ttsService.stop();
      isPlayingNotifier.value = false;
      // currentPlayingIndex را صفر نمی‌کنیم تا موقع ادامه از همین‌جا شروع شود
      return;
    }

    // شروع پخش
    _playbackSessionId++;
    final int mySessionId = _playbackSessionId;
    isPlayingNotifier.value = true;
    // اگر مکالمه قبلاً تمام شده بود، از اول شروع کن
    if (currentPlayingIndexNotifier.value >= messages.length) {
      currentPlayingIndexNotifier.value = 0;
    }

    try {
      // پخش هر پیام به ترتیب (شروع از ایندکس فعلی)
      for (var i = currentPlayingIndexNotifier.value;
          i < messages.length;
          i++) {
        // بررسی اینکه آیا ویجت هنوز زنده است
        if (!mounted) break;

        if (!isPlayingNotifier.value || _playbackSessionId != mySessionId)
          break;

        final message = messages[i];
        currentPlayingIndexNotifier.value = i;

        // ذخیره وضعیت پخش در صورت رسیدن به حد نصاب
        _messagesPlayedSinceLastSave++;
        if (_messagesPlayedSinceLastSave >= _saveInterval) {
          _savePlayback(message.id);
          _messagesPlayedSinceLastSave = 0;
        }

        // پخش پیام با صدای مناسب
        if (message.voice == 'male') {
          await ttsService.stop();
          await ttsService.setMaleVoice();
          await Future.delayed(const Duration(milliseconds: 100));
          await ttsService.speak(message.text);
        } else if (message.voice == 'female') {
          await ttsService.stop();
          await ttsService.setFemaleVoice();
          await Future.delayed(const Duration(milliseconds: 100));
          await ttsService.speak(message.text);
        } else {
          await ttsService.speak(message.text, voice: message.voice);
        }
        // اضافه کردن تاخیر کوتاه بین پیام‌ها
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      // فقط اگر پخش به صورت طبیعی تمام شد (توسط کاربر متوقف نشد)، وضعیت را ریست کن
      // همچنین بررسی می‌کنیم که ویجت هنوز زنده باشد (mounted)
      if (mounted &&
          isPlayingNotifier.value &&
          _playbackSessionId == mySessionId) {
        isPlayingNotifier.value = false;
        currentPlayingIndexNotifier.value = 0;
      }
    }
  }

  /// پخش یک متن با صدای مشخص شده
  /// این متد زمانی که کاربر روی یک پیام کلیک می‌کند فراخوانی می‌شود
  Future<void> speakText(
      String text, String voice, String conversationId) async {
    // ذخیره وضعیت پخش به عنوان آخرین متن پخش شده
    _savePlayback(conversationId);

    if (voice == 'male') {
      // استفاده مستقیم از صدای مردانه انتخابی
      await ttsService.stop();
      await ttsService.setMaleVoice();
      await Future.delayed(const Duration(milliseconds: 100));
      await ttsService.speak(text);
    } else if (voice == 'female') {
      // استفاده از صدای زنانه
      await ttsService.stop();
      await ttsService.setFemaleVoice();
      await Future.delayed(const Duration(milliseconds: 100));
      await ttsService.speak(text);
    } else {
      // استفاده از متد عادی
      await ttsService.speak(text, voice: voice);
    }
  }

  /// رفتن به جمله بعدی
  Future<void> _playNext() async {
    if (sortedMessages == null || sortedMessages!.isEmpty) return;

    // اگر به انتهای لیست نرسیدیم
    if (currentPlayingIndexNotifier.value < sortedMessages!.length - 1) {
      bool wasPlaying = isPlayingNotifier.value;

      // اگر در حال پخش است، ابتدا متوقف کن
      if (wasPlaying) {
        await playAllConversations(sortedMessages!);
      }

      currentPlayingIndexNotifier.value++;

      // اگر قبلا در حال پخش بود، دوباره پخش را شروع کن
      if (wasPlaying) {
        playAllConversations(sortedMessages!);
      }
    }
  }

  /// رفتن به جمله قبلی
  Future<void> _playPrevious() async {
    if (sortedMessages == null || sortedMessages!.isEmpty) return;

    // اگر در ابتدای لیست نیستیم
    if (currentPlayingIndexNotifier.value > 0) {
      bool wasPlaying = isPlayingNotifier.value;

      if (wasPlaying) {
        await playAllConversations(sortedMessages!);
      }

      currentPlayingIndexNotifier.value--;

      if (wasPlaying) {
        playAllConversations(sortedMessages!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _converstionBloc,
      child: Scaffold(
        backgroundColor: MyColors.secondaryTint4,
        // نوار بالای صفحه با عنوان "مکالمه"
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
          centerTitle: true,
          title: Text(
            'مکالمه',
            style: MyTextStyle.textHeader16Bold,
          ),
        ),
        // نوار پایین صفحه شامل دکمه‌های پخش و نمایش ترجمه
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: MyColors.background,
          ),
          child: SafeArea(
            child: Container(
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // دکمه نمایش/مخفی کردن ترجمه
                  ValueListenableBuilder<bool>(
                    valueListenable: showTranslationsNotifier,
                    builder: (context, showTranslations, _) {
                      return IconButton(
                        onPressed: () {
                          showTranslationsNotifier.value =
                              !showTranslationsNotifier.value;
                        },
                        icon: Icon(
                          Icons.translate,
                          color: showTranslations
                              ? MyColors.secondary
                              : MyColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        _playNext();
                      },
                      icon: IconifyIcon(
                        icon: "ri:skip-right-fill",
                        size: 30.r,
                        color: MyColors.textPrimary,
                      )),
                  // دکمه پخش/توقف تمام مکالمه
                  ValueListenableBuilder<bool>(
                    valueListenable: isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return IconButton(
                        onPressed: () {
                          if (sortedMessages != null) {
                            playAllConversations(sortedMessages!);
                          }
                        },
                        icon: Icon(
                          isPlaying ? Icons.stop_circle : Icons.play_circle,
                          size: 50.r,
                          color: isPlaying ? MyColors.error : MyColors.success,
                        ),
                      );
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        _playPrevious();
                      },
                      icon: IconifyIcon(
                        icon: "ri:skip-left-fill",
                        size: 30.r,
                        color: MyColors.textPrimary,
                      )),
                ],
              ),
            ),
          ),
        ),
        // بدنه صفحه که بر اساس وضعیت Bloc محتوا را نمایش می‌دهد
        body: SafeArea(
          top: false,
          child: BlocListener<ConverstionBloc, ConverstionState>(
            listener: (context, state) {
              if (state is ConverstionSuccess &&
                  state.lastConversationId != null) {
                // ابتدا پیام‌ها را استخراج و مرتب می‌کنیم تا بتوانیم ایندکس را پیدا کنیم
                final messages = List<Datum>.from(state.data.data)
                  ..sort((a, b) => a.order.compareTo(b.order));

                final index = messages
                    .indexWhere((m) => m.id == state.lastConversationId);

                if (index != -1) {
                  currentPlayingIndexNotifier.value = index;
                }
              }
            },
            child: BlocBuilder<ConverstionBloc, ConverstionState>(
              builder: (context, state) {
                // نمایش Loading در هنگام بارگذاری داده‌ها
                if (state is ConverstionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // نمایش پیام خطا در صورت بروز مشکل
                if (state is ConverstionError) {
                  return Center(child: Text(state.message));
                }

                // نمایش لیست مکالمه در صورت موفقیت‌آمیز بودن درخواست
                if (state is ConverstionSuccess) {
                  // مرتب‌سازی پیام‌ها بر اساس order
                  sortedMessages = state.data.data
                    ..sort((a, b) => a.order.compareTo(b.order));
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

  /// ساخت لیست مکالمه با استفاده از ListView.builder
  /// این متد پیام‌های مرتب شده را به صورت اسکرول‌پذیر نمایش می‌دهد
  Widget _buildConversationList(BuildContext context, ConversationModel data) {
    // اسکرول به آخرین پیام پخش شده پس از رندر شدن لیست
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentPlayingIndexNotifier.value > 0 &&
          _scrollController.hasClients) {
        final key = _itemKeys[currentPlayingIndexNotifier.value];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.5, // قرار دادن در وسط صفحه
          );
        }
      }
    });

    return ValueListenableBuilder<bool>(
      valueListenable: showTranslationsNotifier,
      builder: (context, showTranslations, _) {
        return ValueListenableBuilder<int>(
          valueListenable: currentPlayingIndexNotifier,
          builder: (context, currentPlayingIndex, _) {
            // اضافه کردن اسکرول خودکار هنگام تغییر ایندکس
            if (_scrollController.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final key = _itemKeys[currentPlayingIndex];
                if (key?.currentContext != null) {
                  Scrollable.ensureVisible(
                    key!.currentContext!,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    alignment: 0.5, // قرار دادن در وسط صفحه
                  );
                } else {
                  // Fallback: اگر آیتم هنوز رندر نشده بود، از تخمین قبلی استفاده می‌کنیم
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double estimatedItemHeight =
                      showTranslations ? 150.0.h : 100.0.h;

                  double targetOffset =
                      (currentPlayingIndex * estimatedItemHeight) -
                          (screenHeight / 2) +
                          (estimatedItemHeight / 2);

                  _scrollController.animateTo(
                    targetOffset.clamp(
                        0, _scrollController.position.maxScrollExtent),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                }
              });
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.r),
              itemCount: sortedMessages?.length ?? 0,
              itemBuilder: (context, index) {
                final message = sortedMessages![index];

                // ایجاد یا دریافت کلید برای این ایندکس
                _itemKeys[index] ??= GlobalKey();

                // بررسی اینکه آیا این پیام در حال پخش است
                final isCurrentPlaying = sortedMessages != null &&
                    currentPlayingIndex < sortedMessages!.length &&
                    sortedMessages![currentPlayingIndex].id == message.id;

                // استفاده از widget جداگانه برای نمایش هر حباب پیام
                return ConversationMessageBubble(
                  key: _itemKeys[index],
                  message: message,
                  isCurrentPlaying: isCurrentPlaying,
                  showTranslations: showTranslations,
                  onTap: () {
                    // پخش صوتی پیام هنگام لمس
                    speakText(message.text, message.voice, message.id);
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
