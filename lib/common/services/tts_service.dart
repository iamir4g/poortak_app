/// TTSService - Text-to-Speech Service for Flutter
///
/// This service provides comprehensive TTS functionality with support for:
/// - Multiple voices (Male/Female)
/// - Gender-specific voice selection
/// - Conversation support with different voices
/// - Voice discovery and testing
/// - Error handling and fallback mechanisms
///
/// Usage:
/// ```dart
/// final TTSService ttsService = locator<TTSService>();
/// await ttsService.initialize();
///
/// // For male voice
/// await ttsService.setMaleVoice();
/// await ttsService.speak("Hello, I am the male voice");
///
/// // For female voice
/// await ttsService.setFemaleVoice();
/// await ttsService.speak("Hello, I am the female voice");
/// ```
///
/// For detailed documentation, see: lib/common/services/README_TTS.md
///
/// Author: Poortak Development Team
/// Version: 1.1.0
/// Last Updated: July 2026
library;

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  static const double _defaultSpeechRate = 0.5;

  /// Google / Android en-US voice ids known to sound male (priority order).
  static const List<String> _preferredMaleVoiceIds = [
    'en-us-x-iom-local',
    'en-us-x-iom-network',
    'en-us-x-tpd-local',
    'en-us-x-tpd-network',
    'en-us-x-tpc-local',
    'en-us-x-tpc-network',
    'en-us-x-iol-local',
    'en-us-x-iol-network',
    'en-us-x-gcd-local',
    'en-us-x-gcd-network',
  ];

  /// Google / Android en-US voice ids known to sound female (priority order).
  static const List<String> _preferredFemaleVoiceIds = [
    'en-us-x-sfg-local',
    'en-us-x-sfg-network',
    'en-us-x-tpf-local',
    'en-us-x-tpf-network',
    'en-us-x-iob-local',
    'en-us-x-iob-network',
    'en-us-x-iog-local',
    'en-us-x-iog-network',
    'en-us-x-tfa-local',
    'en-us-x-tfa-network',
  ];

  static const Set<String> _maleNameHints = {
    'male',
    'daniel',
    'david',
    'alex',
    'fred',
    'tom',
    'aaron',
    'gordon',
    'rishi',
    'arthur',
    'reed',
  };

  static const Set<String> _femaleNameHints = {
    'female',
    'samantha',
    'karen',
    'moira',
    'tessa',
    'fiona',
    'victoria',
    'susan',
    'allison',
    'ava',
    'emma',
    'zoe',
    'kathy',
    'salli',
    'joanna',
    'ivy',
    'kimberly',
    'kendra',
    'nova',
  };

  bool _isInitialized = false;
  Completer<void>? _speechCompleter;
  String _currentVoice = 'male';
  double _currentSpeechRate = _defaultSpeechRate;
  bool _stopRequested = false;

  /// Serialize speak calls so overlapping utterances cannot flip gender mid-speech.
  Future<void> _speakQueue = Future.value();

  List<Map<String, String>>? _cachedVoices;
  Map<String, String>? _cachedMaleVoice;
  Map<String, String>? _cachedFemaleVoice;
  bool _voicesResolved = false;

  /// Removes emoji and pictographic characters so TTS reads only speakable text.
  static String sanitizeForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\p{Extended_Pictographic}', unicode: true), '')
        .replaceAll(RegExp(r'[\u200D\uFE0F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Normalize API / UI gender values to `male` or `female`.
  static String normalizeGender(String? voice) {
    final value = voice?.toLowerCase().trim() ?? '';
    if (value == 'male' || value == 'm' || value == 'man') return 'male';
    if (value == 'female' || value == 'f' || value == 'woman') return 'female';
    // Unknown values default to female only when explicitly non-male tokens
    // appear; otherwise keep male as the app-wide default for vocab screens.
    if (value.contains('female') ||
        value.contains('woman') ||
        value.contains('maya')) {
      return 'female';
    }
    if (value.contains('male') ||
        value.contains('man') ||
        value.contains('robot')) {
      return 'male';
    }
    return value.isEmpty ? 'male' : 'female';
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      print('TTS already initialized');
      return;
    }
    print('Initializing TTS...');

    try {
      await _flutterTts.awaitSpeakCompletion(true);

      var languageAvailable = await _flutterTts.isLanguageAvailable("en-US");

      if (languageAvailable != null) {
        print('Language en-US availability: $languageAvailable');
        await _flutterTts.setLanguage('en-US');
      } else {
        print(
            'Failed to check language availability - TTS engine might not be ready');
      }

      await _flutterTts.setSpeechRate(_defaultSpeechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      try {
        print('Warming up voices...');
        await _flutterTts.getVoices.timeout(const Duration(seconds: 2),
            onTimeout: () {
          print('Timeout waiting for voices');
          return null;
        });
      } catch (e) {
        print('Error warming up voices: $e');
      }

      _flutterTts.setCompletionHandler(() {
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.complete();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.completeError(msg);
        }
      });

      _isInitialized = true;
      // Resolve preferred male/female voices once so gender stays stable.
      await _resolvePreferredVoices();
      await _applyGenderSettings(_currentVoice);
      print('TTS initialized successfully');
    } catch (e) {
      print('Critical Error initializing TTS: $e');
      _isInitialized = true;
    }
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setVoice(String voice) async {
    final gender = normalizeGender(voice);
    if (gender == 'male') {
      await setMaleVoice();
    } else {
      await setFemaleVoice();
    }
  }

  Future<void> _setVoiceByPitch(String voice) async {
    final gender = normalizeGender(voice);
    if (gender == 'male') {
      try {
        await _flutterTts
            .setVoice({'name': 'en-us-x-iom-local', 'locale': 'en-US'});
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(0.9);
        _currentSpeechRate = 0.5;
        print(
            'Setting male voice: en-us-x-iom-local, pitch=0.9, rate=0.5, volume=0.9');
      } catch (e) {
        print('Failed to set male voice, using fallback: $e');
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setPitch(0.85);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(0.9);
        _currentSpeechRate = 0.5;
      }
    } else {
      try {
        await _flutterTts
            .setVoice({'name': 'en-us-x-sfg-local', 'locale': 'en-US'});
        await _flutterTts.setPitch(1.2);
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setVolume(1.0);
        _currentSpeechRate = 0.45;
        print(
            'Setting female voice: en-us-x-sfg-local, pitch=1.2, rate=0.45, volume=1.0');
      } catch (e) {
        print('Failed to set female voice, using pitch fallback: $e');
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setPitch(1.25);
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setVolume(1.0);
        _currentSpeechRate = 0.45;
      }
    }
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setLanguage(language);
    // Android often resets the selected voice when language changes.
    await _applyGenderSettings(_currentVoice);
  }

  /// Speaks the given text with optional voice selection
  ///
  /// Parameters:
  /// - [text]: The text to be spoken
  /// - [voice]: Optional voice selection ("male" or "female")
  /// - [speechRate]: Optional temporary speech speed for this utterance only
  Future<void> speak(String text, {String? voice, double? speechRate}) {
    final sanitizedText = sanitizeForSpeech(text);
    if (sanitizedText.isEmpty) {
      return Future.value();
    }

    final run = _speakQueue.then((_) => _speakInternal(
          sanitizedText,
          voice: voice,
          speechRate: speechRate,
        ));
    // Keep the queue alive even if a speak fails.
    _speakQueue = run.catchError((_) {});
    return run;
  }

  Future<void> _speakInternal(
    String sanitizedText, {
    String? voice,
    double? speechRate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    _stopRequested = false;

    final targetGender =
        voice != null ? normalizeGender(voice) : _currentVoice;

    // Always re-apply gender before speaking. Engine voice can drift after
    // stop/setLanguage/retry even when _currentVoice already matches.
    await _applyGenderSettings(targetGender);
    await Future.delayed(const Duration(milliseconds: 40));

    if (_stopRequested) return;

    final previousSpeechRate = _currentSpeechRate;
    final shouldTemporarilyOverrideRate =
        speechRate != null && speechRate != previousSpeechRate;

    if (shouldTemporarilyOverrideRate) {
      await _flutterTts.setSpeechRate(speechRate);
    }

    _speechCompleter = Completer<void>();
    try {
      var result = await _flutterTts.speak(sanitizedText);
      if (result != 1 && !_stopRequested) {
        print('Speak method returned $result - might have failed');
        // Re-apply gender AFTER setLanguage — language reset drops named voice.
        await _flutterTts.setLanguage('en-US');
        await _applyGenderSettings(targetGender);
        if (!_stopRequested) {
          await _flutterTts.speak(sanitizedText);
        }
      }
    } catch (e) {
      print('Error during speak: $e');

      if (e.toString().contains("not bound") ||
          e.toString().contains("initialize")) {
        print('TTS engine issue detected. Re-initializing...');
        _isInitialized = false;
        _voicesResolved = false;
        _cachedVoices = null;
        try {
          await initialize();
          await _applyGenderSettings(targetGender);
          if (!_stopRequested) {
            await _flutterTts.speak(sanitizedText);
          }
          return;
        } catch (retryError) {
          print('Retry failed: $retryError');
          if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
            _speechCompleter!.completeError(retryError);
          }
          return;
        }
      }

      if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
        _speechCompleter!.completeError(e);
      }
      return;
    } finally {
      if (shouldTemporarilyOverrideRate) {
        await _flutterTts.setSpeechRate(previousSpeechRate);
      }
    }
  }

  /// Sets the male voice with optimized settings
  Future<void> setMaleVoice() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _applyGenderSettings('male');
  }

  /// Sets the female voice with optimized settings
  Future<void> setFemaleVoice() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _applyGenderSettings('female');
  }

  Future<void> _applyGenderSettings(String gender) async {
    final normalized = normalizeGender(gender);
    await _resolvePreferredVoices();

    final selected =
        normalized == 'male' ? _cachedMaleVoice : _cachedFemaleVoice;

    try {
      if (selected != null) {
        await _flutterTts.setVoice({
          'name': selected['name'] ?? '',
          'locale': selected['locale'] ?? 'en-US',
        });
        print('Applied $normalized voice: ${selected['name']}');
      } else {
        print('No cached $normalized voice — using pitch/name fallback');
        await _setVoiceByPitch(normalized);
      }

      if (normalized == 'male') {
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(0.9);
        _currentSpeechRate = 0.5;
      } else {
        await _flutterTts.setPitch(1.2);
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setVolume(1.0);
        _currentSpeechRate = 0.45;
      }

      _currentVoice = normalized;
    } catch (e) {
      print('Failed to apply $normalized voice: $e');
      await _setVoiceByPitch(normalized);
      _currentVoice = normalized;
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
      _speechCompleter!.complete();
    }
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }

  Future<List<Map<String, String>>> getVoices({bool forceRefresh = false}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!forceRefresh && _cachedVoices != null && _cachedVoices!.isNotEmpty) {
      return _cachedVoices!;
    }

    try {
      final voices = await _flutterTts.getVoices.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Timeout in getVoices');
          return null;
        },
      );

      print('Raw voices type: ${voices.runtimeType}');

      if (voices == null) {
        print('Voices list is null');
        return _cachedVoices ?? [];
      }

      List<Map<String, String>> result = [];

      if (voices is List) {
        for (var voice in voices) {
          if (voice is Map) {
            Map<String, String> voiceMap = {};
            voice.forEach((key, value) {
              voiceMap[key.toString()] = value.toString();
            });
            result.add(voiceMap);
          }
        }
      }

      if (result.isNotEmpty) {
        _cachedVoices = result;
      }
      return result;
    } catch (e) {
      print('Error getting voices: $e');
      return _cachedVoices ?? [];
    }
  }

  Future<void> _resolvePreferredVoices() async {
    if (_voicesResolved &&
        _cachedMaleVoice != null &&
        _cachedFemaleVoice != null) {
      return;
    }

    final voices = await getVoices();
    if (voices.isEmpty) {
      print('Cannot resolve preferred voices — empty list');
      return;
    }

    _cachedMaleVoice ??= _pickVoiceForGender(voices, 'male');
    _cachedFemaleVoice ??= _pickVoiceForGender(voices, 'female');
    _voicesResolved = true;

    print('Resolved male voice: ${_cachedMaleVoice?['name']}');
    print('Resolved female voice: ${_cachedFemaleVoice?['name']}');
  }

  Future<void> testVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await getVoices();
      print('Available voices:');
      for (var voice in voices) {
        print('Voice: ${voice['name']}, Locale: ${voice['locale']}');
      }
    } catch (e) {
      print('Error getting voices: $e');
    }
  }

  Future<void> showAvailableVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await _flutterTts.getVoices;
      print('Raw voices from TTS: $voices');
      print('Number of voices: ${voices.length}');

      for (int i = 0; i < voices.length; i++) {
        final voice = voices[i];
        print('Voice $i: $voice');
        if (voice is Map) {
          print('  - Type: ${voice.runtimeType}');
          voice.forEach((key, value) {
            print('  - $key: $value (${value.runtimeType})');
          });
        }
      }
    } catch (e) {
      print('Error showing voices: $e');
    }
  }

  Future<void> showEnglishVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await getVoices();
      print('Total voices: ${voices.length}');

      List<Map<String, String>> englishVoices = [];
      for (var voice in voices) {
        final locale = voice['locale']?.toLowerCase() ?? '';
        if (locale.startsWith('en-') || locale.startsWith('en_')) {
          englishVoices.add(voice);
        }
      }

      print('English voices found: ${englishVoices.length}');
      print('English voices:');

      for (var voice in englishVoices) {
        print('  - Name: ${voice['name']}, Locale: ${voice['locale']}');
      }
    } catch (e) {
      print('Error showing English voices: $e');
    }
  }

  /// Find a device voice that matches [gender]. Never returns the opposite gender.
  Future<Map<String, String>?> findVoiceForGender(String gender) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _resolvePreferredVoices();
      final normalized = normalizeGender(gender);
      if (normalized == 'male') return _cachedMaleVoice;
      return _cachedFemaleVoice;
    } catch (e) {
      print('Error finding voice: $e');
    }

    return null;
  }

  Map<String, String>? _pickVoiceForGender(
    List<Map<String, String>> voices,
    String gender,
  ) {
    final normalized = normalizeGender(gender);
    final preferredIds = normalized == 'male'
        ? _preferredMaleVoiceIds
        : _preferredFemaleVoiceIds;
    final oppositeIds = normalized == 'male'
        ? _preferredFemaleVoiceIds
        : _preferredMaleVoiceIds;
    final nameHints =
        normalized == 'male' ? _maleNameHints : _femaleNameHints;
    final oppositeHints =
        normalized == 'male' ? _femaleNameHints : _maleNameHints;

    List<Map<String, String>> americanVoices = [];
    List<Map<String, String>> englishVoices = [];

    for (var voice in voices) {
      final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
      if (locale.contains('en-us')) {
        americanVoices.add(voice);
      }
      if (locale.startsWith('en-')) {
        englishVoices.add(voice);
      }
    }

    final searchOrder = <Map<String, String>>[
      ...americanVoices,
      ...englishVoices.where((v) => !americanVoices.contains(v)),
      ...voices.where(
          (v) => !americanVoices.contains(v) && !englishVoices.contains(v)),
    ];

    // 1) Exact preferred Google voice ids
    for (final id in preferredIds) {
      for (final voice in searchOrder) {
        final name = (voice['name'] ?? '').toLowerCase();
        if (name == id || name.contains(id)) {
          print('Matched preferred $normalized voice id: ${voice['name']}');
          return voice;
        }
      }
    }

    // 2) Explicit gender metadata from engine (when present)
    for (final voice in searchOrder) {
      final metaGender = (voice['gender'] ?? voice['quality'] ?? '')
          .toLowerCase()
          .trim();
      if (metaGender == normalized ||
          metaGender.contains(normalized) ||
          (normalized == 'female' && metaGender.contains('woman')) ||
          (normalized == 'male' && metaGender.contains('man'))) {
        final name = (voice['name'] ?? '').toLowerCase();
        if (_matchesAny(name, oppositeIds) || _nameHasHint(name, oppositeHints)) {
          continue;
        }
        print('Matched $normalized via gender metadata: ${voice['name']}');
        return voice;
      }
    }

    // 3) Name hints (Samantha, Daniel, "female", …)
    for (final voice in searchOrder) {
      final name = (voice['name'] ?? '').toLowerCase();
      if (_matchesAny(name, oppositeIds) || _nameHasHint(name, oppositeHints)) {
        continue;
      }
      if (_nameHasHint(name, nameHints)) {
        print('Matched $normalized via name hint: ${voice['name']}');
        return voice;
      }
    }

    // 4) Partial token match on preferred id fragments (iom, sfg, …)
    for (final voice in searchOrder) {
      final name = (voice['name'] ?? '').toLowerCase();
      if (_matchesAny(name, oppositeIds) || _nameHasHint(name, oppositeHints)) {
        continue;
      }
      for (final id in preferredIds) {
        final parts = id.split('-');
        String? token;
        for (final part in parts) {
          if (part.length == 3 &&
              part != 'en' &&
              part != 'us' &&
              part != 'gb') {
            token = part;
          }
        }
        if (token != null &&
            name.contains(token) &&
            (name.contains('local') || name.contains('network'))) {
          print('Matched $normalized via token $token: ${voice['name']}');
          return voice;
        }
      }
    }

    // Do NOT fall back to americanVoices.first — that often flips gender.
    print('No suitable $normalized voice found among ${voices.length} voices');
    return null;
  }

  static bool _matchesAny(String name, List<String> ids) {
    for (final id in ids) {
      if (name == id || name.contains(id)) return true;
    }
    return false;
  }

  static bool _nameHasHint(String name, Set<String> hints) {
    for (final hint in hints) {
      if (name.contains(hint)) return true;
    }
    return false;
  }

  void printCurrentSettings() {
    print('Current voice: $_currentVoice');
    print('Cached male: ${_cachedMaleVoice?['name']}');
    print('Cached female: ${_cachedFemaleVoice?['name']}');
    print('TTS initialized: $_isInitialized');
  }

  Future<void> testDifferentVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await getVoices();
      print('Testing different voices...');

      for (int i = 0; i < voices.length && i < 3; i++) {
        final voice = voices[i];
        print('Testing voice ${i + 1}: ${voice['name']}');

        try {
          await _flutterTts.setVoice({
            'name': voice['name'] ?? '',
            'locale': voice['locale'] ?? 'en-US'
          });
          await _flutterTts.speak('Hello, this is voice ${i + 1}');
          await Future.delayed(const Duration(seconds: 2));
        } catch (e) {
          print('Failed to test voice ${i + 1}: $e');
        }
      }
    } catch (e) {
      print('Error testing voices: $e');
    }
  }

  Future<void> testMaleFemaleVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('Testing male and female voices...');

      await setMaleVoice();
      await speak('Hello, I am the male voice', voice: 'male');
      await Future.delayed(const Duration(seconds: 1));

      await setFemaleVoice();
      await speak('Hello, I am the female voice', voice: 'female');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print('Error testing male/female voices: $e');
    }
  }
}
