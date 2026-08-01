/// TalkbotTtsService — Text-to-Speech via Talkbot API
///
/// Docs:
/// - v2 (ایرانی): https://talkbot.ir/TTS-v2-api
/// - v1 (Azure): https://talkbot.ir/text-to-speech-api
///
/// Latency strategy:
/// 1) Disk cache hit → play local file immediately
/// 2) Miss → synthesize → download once → save → play local
/// 3) [prefetch] warms cache in background for upcoming sentences
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poortak/common/config/tts_config.dart';
import 'package:poortak/common/services/tts_client.dart';
import 'package:poortak/common/services/tts_service.dart';

class TalkbotTtsService extends TtsClient {
  TalkbotTtsService({Dio? dio, AudioPlayer? player})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: TtsConfig.talkbotBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
              ),
            ),
        _player = player ?? AudioPlayer();

  final Dio _dio;
  final AudioPlayer _player;

  bool _isInitialized = false;
  String _currentVoice = 'male';
  bool _stopRequested = false;
  Future<void> _speakQueue = Future.value();
  Completer<void>? _playbackCompleter;
  int _playbackGeneration = 0;

  Directory? _cacheDir;

  /// In-flight downloads so parallel prefetch/speak share one network call.
  final Map<String, Future<File>> _inflight = {};

  int _busyDepth = 0;

  void _retainBusy() {
    _busyDepth++;
    setBusy(true);
  }

  void _releaseBusy() {
    if (_busyDepth > 0) _busyDepth--;
    setBusy(_busyDepth > 0);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    final token = TtsConfig.talkbotApiToken;
    if (token.isEmpty) {
      throw StateError(
        'TALKBOT_API_TOKEN خالی است. توکن را در فایل .env بگذار '
        'یا با --dart-define=TALKBOT_API_TOKEN=... اجرا کن.',
      );
    }

    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setPlaybackRate(TtsConfig.talkbotPlaybackRate);

    _player.onPlayerComplete.listen((_) {
      final c = _playbackCompleter;
      if (c != null && !c.isCompleted) c.complete();
    });

    _cacheDir = await _resolveCacheDir();
    _isInitialized = true;
    debugPrint(
      'Talkbot TTS initialized '
      '(${TtsConfig.talkbotApiVersion.name}, cache=${_cacheDir?.path})',
    );
  }

  Future<Directory> _resolveCacheDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/talkbot_tts_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<void> setMaleVoice() async {
    _currentVoice = 'male';
  }

  @override
  Future<void> setFemaleVoice() async {
    _currentVoice = 'female';
  }

  @override
  Future<void> setVoice(String voice) async {
    final gender = TTSService.normalizeGender(voice);
    if (gender == 'male') {
      await setMaleVoice();
    } else {
      await setFemaleVoice();
    }
  }

  @override
  Future<void> speak(String text, {String? voice, double? speechRate}) {
    final sanitized = TTSService.sanitizeForSpeech(text);
    if (sanitized.isEmpty) return Future.value();

    // فوری لودینگ را روشن کن تا کاربر قبل از رسیدن نوبت صف هم بازخورد ببیند
    _retainBusy();

    final run = _speakQueue.then(
      (_) => _speakInternal(sanitized, voice: voice, speechRate: speechRate),
    );
    _speakQueue = run.catchError((_) {});
    return run;
  }

  @override
  Future<void> prefetch(String text, {String? voice}) async {
    final sanitized = TTSService.sanitizeForSpeech(text);
    if (sanitized.isEmpty) return;

    if (!_isInitialized) {
      await initialize();
    }

    final gender = voice != null
        ? TTSService.normalizeGender(voice)
        : _currentVoice;

    try {
      await _ensureCachedFile(sanitized, gender);
    } catch (e) {
      debugPrint('Talkbot TTS prefetch failed: $e');
    }
  }

  Future<void> _speakInternal(
    String text, {
    String? voice,
    double? speechRate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    _stopRequested = false;

    if (voice != null) {
      await setVoice(voice);
    }

    final rate = _resolvePlaybackRate(speechRate);
    var released = false;

    try {
      final sw = Stopwatch()..start();
      final file = await _ensureCachedFile(text, _currentVoice);
      debugPrint(
        'Talkbot TTS ready in ${sw.elapsedMilliseconds}ms '
        '(${file.path.split('/').last})',
      );

      if (_stopRequested) return;

      // آماده‌سازی تمام شد — پخش شروع می‌شود
      _releaseBusy();
      released = true;
      await _playFile(file, rate);
    } catch (e, st) {
      debugPrint('Talkbot TTS speak error: $e\n$st');
      rethrow;
    } finally {
      if (!released) _releaseBusy();
    }
  }

  double _resolvePlaybackRate(double? speechRate) {
    if (speechRate == null) return TtsConfig.talkbotPlaybackRate;
    // Device rates are typically 0.25–0.5 → map to slower playback rates.
    return (speechRate * 1.7).clamp(0.55, 0.95);
  }

  String _cacheKey(String text, String gender) {
    return '${TtsConfig.talkbotApiVersion.name}|$gender|$text';
  }

  String _fileNameForKey(String cacheKey) {
    final bytes = utf8.encode(cacheKey);
    var h1 = 2166136261;
    for (final b in bytes) {
      h1 ^= b;
      h1 = (h1 * 16777619) & 0xFFFFFFFF;
    }
    final h2 = Object.hashAll(bytes).toUnsigned(32);
    final ext =
        TtsConfig.talkbotApiVersion == TalkbotApiVersion.v2 ? 'wav' : 'mp3';
    return '${h1.toRadixString(16)}_$h2.$ext';
  }

  Future<File> _ensureCachedFile(String text, String gender) {
    final key = _cacheKey(text, gender);
    final existing = _inflight[key];
    if (existing != null) return existing;

    final future = _downloadOrReuse(text, gender, key);
    _inflight[key] = future;
    return future.whenComplete(() => _inflight.remove(key));
  }

  Future<File> _downloadOrReuse(
    String text,
    String gender,
    String cacheKey,
  ) async {
    final dir = _cacheDir ?? await _resolveCacheDir();
    _cacheDir = dir;

    final file = File('${dir.path}/${_fileNameForKey(cacheKey)}');
    if (await file.exists() && await file.length() > 0) {
      // Touch mtime for simple LRU-ish eviction.
      try {
        await file.setLastModified(DateTime.now());
      } catch (_) {}
      return file;
    }

    final url = await _synthesize(text, gender);
    if (_stopRequested && _inflight.containsKey(cacheKey) == false) {
      // still finish download for cache value
    }

    await _dio.download(
      url,
      file.path,
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );

    if (!await file.exists() || await file.length() == 0) {
      throw StateError('Talkbot TTS download produced empty file');
    }

    unawaited(_trimCacheIfNeeded(dir));
    return file;
  }

  Future<void> _trimCacheIfNeeded(Directory dir) async {
    try {
      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();
      if (files.length <= TtsConfig.talkbotCacheMaxFiles) return;

      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      final overflow = files.length - TtsConfig.talkbotCacheMaxFiles;
      for (var i = 0; i < overflow; i++) {
        try {
          await files[i].delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Talkbot TTS cache trim failed: $e');
    }
  }

  Future<String> _synthesize(String text, String gender) async {
    final token = TtsConfig.talkbotApiToken;
    final isV2 = TtsConfig.talkbotApiVersion == TalkbotApiVersion.v2;

    late final String endpoint;
    late final FormData formData;

    if (isV2) {
      endpoint = TtsConfig.talkbotV2Endpoint;
      final voiceId = gender == 'female'
          ? TtsConfig.talkbotV2FemaleVoiceId
          : TtsConfig.talkbotV2MaleVoiceId;
      formData = FormData.fromMap({
        'text': text,
        'voice_id': voiceId,
      });
      debugPrint('Talkbot v2 synthesize voice_id=$voiceId chars=${text.length}');
    } else {
      endpoint = TtsConfig.talkbotV1Endpoint;
      final azureVoice = gender == 'female'
          ? TtsConfig.talkbotV1FemaleVoice
          : TtsConfig.talkbotV1MaleVoice;
      formData = FormData.fromMap({
        'text': text,
        'server': TtsConfig.talkbotV1Server,
        'voice': azureVoice,
      });
      debugPrint('Talkbot v1 synthesize voice=$azureVoice chars=${text.length}');
    }

    final response = await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: Headers.multipartFormDataContentType,
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Talkbot TTS HTTP ${response.statusCode}: ${response.data}',
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw StateError('Talkbot TTS unexpected response: $data');
    }
    if (data['error'] != null) {
      throw StateError('Talkbot TTS error: ${data['error']}');
    }

    final payload = data['response'];
    if (payload is Map && payload['download'] is String) {
      return (payload['download'] as String).replaceAll(r'\/', '/');
    }

    throw StateError('Talkbot TTS failed: $data');
  }

  Future<void> _playFile(File file, double rate) async {
    final generation = ++_playbackGeneration;
    _playbackCompleter = Completer<void>();
    final completer = _playbackCompleter!;

    try {
      await _player.stop();
      if (_stopRequested || generation != _playbackGeneration) return;

      await _player.play(DeviceFileSource(file.path));
      // بعضی دستگاه‌ها rate را فقط بعد از شروع پخش اعمال می‌کنند
      await _player.setPlaybackRate(rate);

      await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          debugPrint('Talkbot TTS playback timed out');
        },
      );
    } finally {
      if (identical(_playbackCompleter, completer) && !completer.isCompleted) {
        completer.complete();
      }
      if (identical(_playbackCompleter, completer)) {
        _playbackCompleter = null;
      }
    }
  }

  @override
  Future<void> stop() async {
    _stopRequested = true;
    _playbackGeneration++;
    _busyDepth = 0;
    setBusy(false);
    final c = _playbackCompleter;
    if (c != null && !c.isCompleted) c.complete();
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
