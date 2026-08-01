/// Shared TTS contract used by UI call sites.
///
/// Implementations:
/// - [DeviceTtsClient] (flutter_tts)
/// - [TalkbotTtsService] (Talkbot API)
library;

import 'package:flutter/foundation.dart';

abstract class TtsClient {
  /// True while online TTS is preparing audio (download/synthesize).
  /// Device engine keeps this false.
  final ValueNotifier<bool> isBusy = ValueNotifier<bool>(false);

  Future<void> initialize();

  Future<void> speak(String text, {String? voice, double? speechRate});

  /// Warm the cache for [text] without playing (no-op on device TTS).
  Future<void> prefetch(String text, {String? voice}) async {}

  Future<void> stop();

  Future<void> setMaleVoice();

  Future<void> setFemaleVoice();

  Future<void> setVoice(String voice);

  @protected
  void setBusy(bool value) {
    if (isBusy.value != value) {
      isBusy.value = value;
    }
  }
}
