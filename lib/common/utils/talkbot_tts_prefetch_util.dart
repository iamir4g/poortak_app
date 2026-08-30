/// Prefetch helper for Talkbot TTS only.
///
/// وقتی موتور دستگاه فعال باشد هیچ کاری نمی‌کند.
/// منطق پخش مکالمه را تغییر نمی‌دهد؛ فقط کش دیسک را از قبل گرم می‌کند
/// تا هنگام `speak` منتظر API نمانیم.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:poortak/common/config/tts_config.dart';
import 'package:poortak/common/services/tts_client.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/conversation_model.dart';
import 'package:poortak/locator.dart';

/// یک واحد متن + صدای مورد نیاز برای کش کردن.
class TalkbotPrefetchUtterance {
  const TalkbotPrefetchUtterance({
    required this.text,
    required this.voice,
  });

  final String text;
  final String voice;
}

class TalkbotTtsPrefetchUtil {
  TalkbotTtsPrefetchUtil._();

  static int _generation = 0;
  static String? _runningSignature;
  static String? _completedSignature;

  /// همان منطق جداسازی جمله در صفحه مکالمه.
  static List<String> splitIntoSentences(String text) {
    final regExp = RegExp(r'[^.!?]+[.!?]*');
    return regExp
        .allMatches(text)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// پیام‌های مکالمه → جملات + متن کامل هر پیام
  /// (پخش خودکار جمله‌ای است؛ تپ روی پیام کل متن را می‌خواند).
  static List<TalkbotPrefetchUtterance> utterancesFromMessages(
    Iterable<Datum> messages,
  ) {
    final result = <TalkbotPrefetchUtterance>[];
    final seen = <String>{};

    void add(String text, String voice) {
      final key = '$voice|$text';
      if (text.trim().isEmpty || !seen.add(key)) return;
      result.add(TalkbotPrefetchUtterance(text: text, voice: voice));
    }

    for (final message in messages) {
      final voice = message.playbackVoice;
      // اول جملات به‌ترتیب پخش خودکار
      for (final sentence in splitIntoSentences(message.text)) {
        add(sentence, voice);
      }
      // بعد کل پیام برای تپ روی حباب
      add(message.text, voice);
    }
    return result;
  }

  /// به‌محض لود/دیدن مکالمه صدا می‌زند.
  /// فقط وقتی Talkbot فعال است کار می‌کند؛ وگرنه no-op.
  static void warmUpConversationMessages(
    List<Datum> messages, {
    TtsClient? tts,
    int concurrency = 4,
  }) {
    if (!TtsConfig.useTalkbot) return;
    if (messages.isEmpty) return;

    final utterances = utterancesFromMessages(messages);
    warmUp(utterances, tts: tts, concurrency: concurrency);
  }

  /// کش کردن لیست دلخواه از متن/صدا — فقط وقتی Talkbot فعال است.
  static void warmUp(
    List<TalkbotPrefetchUtterance> utterances, {
    TtsClient? tts,
    int concurrency = 4,
  }) {
    if (!TtsConfig.useTalkbot) return;
    if (utterances.isEmpty) return;

    final signature =
        utterances.map((u) => '${u.voice}|${u.text}').join('\u0001');

    if (signature == _completedSignature) {
      debugPrint(
        'Talkbot prefetch: already cached (${utterances.length} items)',
      );
      return;
    }
    if (signature == _runningSignature) {
      debugPrint('Talkbot prefetch: already running');
      return;
    }

    _runningSignature = signature;
    final gen = ++_generation;
    final client = tts ?? locator<TtsClient>();
    final limit = concurrency.clamp(1, 6);

    unawaited(() async {
      debugPrint(
        'Talkbot prefetch: start ${utterances.length} utterances '
        '(concurrency=$limit)',
      );
      final sw = Stopwatch()..start();
      var done = 0;
      var failed = 0;
      var index = 0;

      Future<void> worker() async {
        while (true) {
          if (gen != _generation) return;
          final i = index++;
          if (i >= utterances.length) return;

          final item = utterances[i];
          try {
            await client.prefetch(item.text, voice: item.voice);
            done++;
            if (done == 1 || done % 5 == 0 || done == utterances.length) {
              debugPrint(
                'Talkbot prefetch: progress $done/${utterances.length}',
              );
            }
          } catch (e) {
            failed++;
            debugPrint('Talkbot prefetch item failed: $e');
          }
        }
      }

      await Future.wait(List.generate(limit, (_) => worker()));

      if (gen != _generation) {
        if (_runningSignature == signature) _runningSignature = null;
        debugPrint('Talkbot prefetch: cancelled');
        return;
      }

      _runningSignature = null;
      if (failed == 0 || done > 0) {
        _completedSignature = signature;
      }

      debugPrint(
        'Talkbot prefetch: done ok=$done fail=$failed '
        'in ${sw.elapsedMilliseconds}ms',
      );
    }());
  }

  /// لغو job فعال (خروج از صفحه مکالمه).
  static void cancel() {
    _generation++;
    _runningSignature = null;
    // completed را نگه می‌داریم تا اگر فایل‌ها روی دیسک هستند دوباره API نزنیم
  }

  /// برای اجبار به warm مجدد (مثلاً بعد از پاک کردن کش دیسک).
  static void resetWarmSignature() {
    _completedSignature = null;
    _runningSignature = null;
  }
}
