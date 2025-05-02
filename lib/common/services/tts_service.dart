import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.3);

    _isInitialized = true;
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setLanguage(language);
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
