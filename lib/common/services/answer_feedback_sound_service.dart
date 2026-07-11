import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AnswerFeedbackSoundService {
  AnswerFeedbackSoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static const String _correctAsset = 'sounds/dragon-studio-correct.mp3';
  static const String _wrongAsset = 'sounds/freesound_community-wrong.mp3';
  static const double _volume = 50.0;

  static Future<void> playCorrect() => _play(_correctAsset);

  static Future<void> playWrong() => _play(_wrongAsset);

  static Future<void> play(bool isCorrect) =>
      isCorrect ? playCorrect() : playWrong();

  static Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath), volume: _volume);
    } catch (e) {
      debugPrint('Failed to play answer feedback sound: $e');
    }
  }

  static Future<void> dispose() => _player.dispose();
}
