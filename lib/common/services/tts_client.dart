/// Shared TTS contract used by UI call sites.
///
/// Implementations:
/// - [TTSService] via [DeviceTtsClient] (flutter_tts)
/// - [TalkbotTtsService] (Talkbot Azure API)
library;

abstract class TtsClient {
  Future<void> initialize();

  Future<void> speak(String text, {String? voice, double? speechRate});

  /// Warm the cache for [text] without playing (no-op on device TTS).
  Future<void> prefetch(String text, {String? voice}) async {}

  Future<void> stop();

  Future<void> setMaleVoice();

  Future<void> setFemaleVoice();

  Future<void> setVoice(String voice);
}
