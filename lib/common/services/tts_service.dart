import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  Completer<void>? _speechCompleter;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.3);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      _speechCompleter?.complete();
    });

    _flutterTts.setErrorHandler((msg) {
      _speechCompleter?.completeError(msg);
    });

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

    _speechCompleter = Completer<void>();
    await _flutterTts.speak(text);
    await _speechCompleter?.future;
  }

  Future<void> stop() async {
    _speechCompleter?.complete();
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
