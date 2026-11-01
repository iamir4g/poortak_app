import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/locator.dart';

class AnswerFeedbackSoundService {
  AnswerFeedbackSoundService._();

  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _popupPlayer = AudioPlayer(playerId: 'popup-sfx');

  static const String _correctAsset = 'sounds/correctAnswer.mp3';
  static const String _wrongAsset = 'sounds/wrongAnswer.mp3';
  static const String _clickAsset = 'sounds/click.mp3';
  static const String _cardSwipeAsset = 'sounds/cardSwip.mp3';
  static const String _popupAsset = 'sounds/popUpModal.mp3';
  static const double _volume = 50.0;

  static Future<void>? _preloadFuture;
  static bool _popupReady = false;

  static Future<void> playCorrect() => _play(_correctAsset);

  static Future<void> playWrong() => _play(_wrongAsset);

  static Future<void> play(bool isCorrect) =>
      isCorrect ? playCorrect() : playWrong();

  static Future<void> playClick() => _play(_clickAsset);

  static Future<void> playCardSwipe() => _play(_cardSwipeAsset);

  static Future<void> preload() {
    return _preloadFuture ??= _preloadPopup();
  }

  static Future<void> playPopup() async {
    if (!_soundEffectsEnabled) return;
    try {
      if (!_popupReady) {
        await preload();
      }
      if (!_popupReady) return;

      // lowLatency cannot seek; stop resets to the start of the preloaded clip.
      if (_popupPlayer.state != PlayerState.stopped) {
        await _popupPlayer.stop();
      }
      unawaited(_popupPlayer.resume());
    } catch (e) {
      debugPrint('Failed to play popup sound: $e');
    }
  }

  static bool get _soundEffectsEnabled =>
      !locator.isRegistered<SettingsCubit>() ||
      locator<SettingsCubit>().state.playSoundEffects;

  static Future<void> _preloadPopup() async {
    try {
      await _popupPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _popupPlayer.setReleaseMode(ReleaseMode.stop);
      await _popupPlayer.setVolume(_volume);
      await _popupPlayer.setSourceAsset(_popupAsset);
      _popupReady = true;
    } catch (e) {
      _preloadFuture = null;
      _popupReady = false;
      debugPrint('Failed to preload popup sound: $e');
    }
  }

  static Future<void> _play(String assetPath) async {
    if (!_soundEffectsEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath), volume: _volume);
    } catch (e) {
      debugPrint('Failed to play answer feedback sound: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
    await _popupPlayer.dispose();
  }
}
