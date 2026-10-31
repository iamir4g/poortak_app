import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/locator.dart';

class AnswerFeedbackSoundService {
  AnswerFeedbackSoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static const String _correctAsset = 'sounds/correctAnswer.mp3';
  static const String _wrongAsset = 'sounds/wrongAnswer.mp3';
  static const String _clickAsset = 'sounds/click.mp3';
  static const String _cardSwipeAsset = 'sounds/cardSwip.mp3';
  static const String _popupAsset = 'sounds/popUpModal.mp3';
  static const double _volume = 50.0;

  static Future<void> playCorrect() => _play(_correctAsset);

  static Future<void> playWrong() => _play(_wrongAsset);

  static Future<void> play(bool isCorrect) =>
      isCorrect ? playCorrect() : playWrong();

  static Future<void> playClick() => _play(_clickAsset);

  static Future<void> playCardSwipe() => _play(_cardSwipeAsset);

  static Future<void> playPopup() => _play(_popupAsset);

  static bool get _soundEffectsEnabled =>
      !locator.isRegistered<SettingsCubit>() ||
      locator<SettingsCubit>().state.playSoundEffects;

  static Future<void> _play(String assetPath) async {
    if (!_soundEffectsEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath), volume: _volume);
    } catch (e) {
      debugPrint('Failed to play answer feedback sound: $e');
    }
  }

  static Future<void> dispose() => _player.dispose();
}
