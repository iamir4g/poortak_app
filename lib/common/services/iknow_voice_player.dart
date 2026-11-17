import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Single-active player for IKnow server voice files.
class IKnowVoicePlayer {
  final AudioPlayer _player;
  Completer<void>? _completionCompleter;
  StreamSubscription<void>? _completeSub;
  int _playGeneration = 0;

  IKnowVoicePlayer({String? playerId})
      : _player = AudioPlayer(
          playerId: playerId ??
              'iknow-voice-${DateTime.now().microsecondsSinceEpoch}',
        ) {
    _completeSub = _player.onPlayerComplete.listen((_) {
      _completeCurrent();
    });
  }

  /// Plays a local audio file and completes when playback finishes or is stopped.
  Future<void> playFile(String path) async {
    final generation = ++_playGeneration;
    await _stopInternal(invalidate: false);
    if (generation != _playGeneration) return;

    final completer = Completer<void>();
    _completionCompleter = completer;

    try {
      await _player.play(DeviceFileSource(path));
      if (generation != _playGeneration) {
        _completeCurrent();
        return;
      }
      await completer.future;
    } catch (e) {
      debugPrint('IKnowVoicePlayer playFile failed: $e');
      _completeCurrent();
    }
  }

  Future<void> stop() => _stopInternal(invalidate: true);

  Future<void> _stopInternal({required bool invalidate}) async {
    if (invalidate) {
      _playGeneration++;
    }
    _completeCurrent();
    try {
      if (_player.state != PlayerState.stopped) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('IKnowVoicePlayer stop failed: $e');
    }
  }

  void _completeCurrent() {
    final completer = _completionCompleter;
    _completionCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _completeSub?.cancel();
    _completeSub = null;
    await _player.dispose();
  }
}
