import 'package:poortak/common/services/tts_client.dart';
import 'package:poortak/common/services/tts_service.dart';

/// Thin adapter so the existing [TTSService] keeps its structure untouched
/// while UI depends on [TtsClient].
class DeviceTtsClient extends TtsClient {
  DeviceTtsClient(this._inner);

  final TTSService _inner;

  TTSService get inner => _inner;

  @override
  Future<void> initialize() => _inner.initialize();

  @override
  Future<void> speak(String text, {String? voice, double? speechRate}) =>
      _inner.speak(text, voice: voice, speechRate: speechRate);

  @override
  Future<void> stop() => _inner.stop();

  @override
  Future<void> setMaleVoice() => _inner.setMaleVoice();

  @override
  Future<void> setFemaleVoice() => _inner.setFemaleVoice();

  @override
  Future<void> setVoice(String voice) => _inner.setVoice(voice);
}
