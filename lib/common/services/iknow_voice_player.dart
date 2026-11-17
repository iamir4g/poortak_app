import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Single-active player for IKnow server voice files.
class IKnowVoicePlayer {
  final AudioPlayer _player;
  Completer<void>? _completionCompleter;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  Timer? _watchdogTimer;
  int _playGeneration = 0;
  Duration? _lastKnownDuration;

  /// When false, completion events from a previous stop/reset are ignored.
  bool _acceptCompletion = false;

  IKnowVoicePlayer({String? playerId})
      : _player = AudioPlayer(
          playerId: playerId ??
              'iknow-voice-${DateTime.now().microsecondsSinceEpoch}',
        ) {
    unawaited(_player.setReleaseMode(ReleaseMode.stop));

    _completeSub = _player.onPlayerComplete.listen((_) {
      debugPrint('IKnowVoicePlayer: onPlayerComplete');
      _finishIfAccepting('onPlayerComplete');
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        debugPrint('IKnowVoicePlayer: state completed');
        _finishIfAccepting('state-completed');
      }
    });
  }

  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  Future<Duration?> getDuration() => _player.getDuration();

  Duration? get lastKnownDuration => _lastKnownDuration;

  /// Emits playback progress in `[0, 1]` while a file is playing.
  Stream<double> watchProgress() async* {
    final generation = _playGeneration;
    Duration? duration = await _player.getDuration();
    if (duration == null || duration.inMilliseconds <= 0) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (generation != _playGeneration) return;
      duration = await _player.getDuration();
    }
    if (duration != null && duration.inMilliseconds > 0) {
      _lastKnownDuration = duration;
    }

    yield 0;

    await for (final position in _player.onPositionChanged) {
      if (generation != _playGeneration) return;

      var total = duration ?? await _player.getDuration();
      if (total != null && total.inMilliseconds > 0) {
        duration = total;
        _lastKnownDuration = total;
      }

      final totalMs = duration?.inMilliseconds ?? 0;
      if (totalMs <= 0) {
        yield 0;
        continue;
      }

      final progress = (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
      yield progress;
      if (progress >= 0.995) return;
    }
  }

  /// Plays a local audio file and completes when playback finishes or is stopped.
  Future<void> playFile(
    String path, {
    void Function()? onStarted,
  }) async {
    final generation = ++_playGeneration;
    await _stopInternal(invalidate: false);
    if (generation != _playGeneration) return;

    final completer = Completer<void>();
    _completionCompleter = completer;
    _lastKnownDuration = null;
    _acceptCompletion = false;

    try {
      await _player.play(DeviceFileSource(path));
      if (generation != _playGeneration) {
        _forceComplete();
        return;
      }

      // Accept completion only after the new source has started. This avoids
      // a late complete/stop event from the previous file finishing this play.
      _acceptCompletion = true;
      unawaited(_resolveDuration(generation));
      _attachPositionCompletionFallback(generation);
      onStarted?.call();
      await completer.future;
    } catch (e) {
      debugPrint('IKnowVoicePlayer playFile failed: $e');
      _forceComplete();
    }
  }

  void _attachPositionCompletionFallback(int generation) {
    unawaited(_positionSub?.cancel());
    _positionSub = _player.onPositionChanged.listen((position) async {
      if (generation != _playGeneration) return;

      var duration = _lastKnownDuration ?? await _player.getDuration();
      if (duration != null && duration.inMilliseconds > 0) {
        _lastKnownDuration = duration;
        _armWatchdog(generation, duration);

        // Some Android AAC paths never emit onPlayerComplete.
        final remaining = duration.inMilliseconds - position.inMilliseconds;
        if (remaining <= 120) {
          _finishIfAccepting(
            'position-near-end '
            '(${position.inMilliseconds}/${duration.inMilliseconds})',
          );
        }
      }
    });
  }

  void _armWatchdog(int generation, Duration duration) {
    _watchdogTimer?.cancel();
    final grace = Duration(
      milliseconds: (duration.inMilliseconds * 0.25).round().clamp(800, 4000),
    );
    _watchdogTimer = Timer(duration + grace, () {
      if (generation != _playGeneration) return;
      _finishIfAccepting(
        'watchdog (${duration.inMilliseconds + grace.inMilliseconds}ms)',
      );
    });
  }

  Future<void> _resolveDuration(int generation) async {
    for (var i = 0; i < 12; i++) {
      if (generation != _playGeneration) return;
      final duration = await _player.getDuration();
      if (duration != null && duration.inMilliseconds > 0) {
        _lastKnownDuration = duration;
        _armWatchdog(generation, duration);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> stop() => _stopInternal(invalidate: true);

  Future<void> _stopInternal({required bool invalidate}) async {
    if (invalidate) {
      _playGeneration++;
    }
    _acceptCompletion = false;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    await _positionSub?.cancel();
    _positionSub = null;
    _forceComplete();
    try {
      if (_player.state != PlayerState.stopped) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('IKnowVoicePlayer stop failed: $e');
    }
  }

  void _finishIfAccepting(String reason) {
    if (!_acceptCompletion) return;
    debugPrint('IKnowVoicePlayer: finish via $reason');
    _forceComplete();
  }

  void _forceComplete() {
    _acceptCompletion = false;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
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
    await _stateSub?.cancel();
    _stateSub = null;
    await _positionSub?.cancel();
    _positionSub = null;
    await _player.dispose();
  }
}
