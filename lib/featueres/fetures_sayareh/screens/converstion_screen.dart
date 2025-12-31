import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
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

  // مشخص می‌کند که آیا در حال پخش تمام مکالمه است
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  // ایندکس پیام فعلی که در حال پخش است
  final ValueNotifier<int> currentPlayingIndexNotifier = ValueNotifier(0);

  // لیست پیام‌های مرتب شده بر اساس order
  List<Datum>? sortedMessages;

  // مشخص می‌کند که آیا ترجمه‌ها باید نمایش داده شوند
  final ValueNotifier<bool> showTranslationsNotifier = ValueNotifier(false);

  @override
  void dispose() {
    isPlayingNotifier.dispose();
    currentPlayingIndexNotifier.dispose();
    showTranslationsNotifier.dispose();
    super.dispose();
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
        if (!isPlayingNotifier.value) break;

        final message = messages[i];
        currentPlayingIndexNotifier.value = i;

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
      if (isPlayingNotifier.value) {
        isPlayingNotifier.value = false;
        currentPlayingIndexNotifier.value = 0;
      }
    }
  }

  /// پخش یک متن با صدای مشخص شده
  /// این متد زمانی که کاربر روی یک پیام کلیک می‌کند فراخوانی می‌شود
  Future<void> speakText(String text, String voice) async {
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
    return BlocProvider(
      // ایجاد و راه‌اندازی Bloc برای مدیریت وضعیت مکالمه
      create: (context) => ConverstionBloc(
        sayarehRepository: locator(),
      )..add(GetConversationEvent(id: widget.conversationId)),
      child: Scaffold(
        backgroundColor: MyColors.secondaryTint4,
        // نوار بالای صفحه با عنوان "مکالمه"
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
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
          title: const Text(
            'مکالمه',
            style: MyTextStyle.textHeader16Bold,
          ),
        ),
        // نوار پایین صفحه شامل دکمه‌های پخش و نمایش ترجمه
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
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
                      color: showTranslations ? Colors.blue : Colors.grey,
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
                    size: 30,
                    color: Colors.black,
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
                      size: 50,
                      color: isPlaying ? Colors.red : Colors.green,
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
                    size: 30,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
        // بدنه صفحه که بر اساس وضعیت Bloc محتوا را نمایش می‌دهد
        body: BlocBuilder<ConverstionBloc, ConverstionState>(
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
    );
  }

  /// ساخت لیست مکالمه با استفاده از ListView.builder
  /// این متد پیام‌های مرتب شده را به صورت اسکرول‌پذیر نمایش می‌دهد
  Widget _buildConversationList(BuildContext context, ConversationModel data) {
    final ScrollController scrollController = ScrollController();

    return ValueListenableBuilder<bool>(
      valueListenable: showTranslationsNotifier,
      builder: (context, showTranslations, _) {
        return ValueListenableBuilder<int>(
          valueListenable: currentPlayingIndexNotifier,
          builder: (context, currentPlayingIndex, _) {
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: sortedMessages?.length ?? 0,
              itemBuilder: (context, index) {
                final message = sortedMessages![index];

                // بررسی اینکه آیا این پیام در حال پخش است
                final isCurrentPlaying = sortedMessages != null &&
                    currentPlayingIndex < sortedMessages!.length &&
                    sortedMessages![currentPlayingIndex].id == message.id;

                // استفاده از widget جداگانه برای نمایش هر حباب پیام
                return ConversationMessageBubble(
                  message: message,
                  isCurrentPlaying: isCurrentPlaying,
                  showTranslations: showTranslations,
                  onTap: () {
                    // پخش صوتی پیام هنگام لمس
                    speakText(message.text, message.voice);
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
