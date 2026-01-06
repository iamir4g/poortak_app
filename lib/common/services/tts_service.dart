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
/// Version: 1.0.0
/// Last Updated: January 2025

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  Completer<void>? _speechCompleter;
  String _currentVoice = 'male';

  Future<void> initialize() async {
    if (_isInitialized) {
      print('TTS already initialized');
      return;
    }
    print('Initializing TTS...');
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
    print('TTS initialized');
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setVoice(String voice) async {
    if (!_isInitialized) {
      await initialize();
    }

    _currentVoice = voice;

    // ابتدا سعی کن صداهای مناسب را پیدا کن
    final foundVoice = await findVoiceForGender(voice);

    if (foundVoice != null) {
      try {
        await _flutterTts.setVoice({
          'name': foundVoice['name'] ?? '',
          'locale': foundVoice['locale'] ?? 'en-US'
        });
        print('Using found voice: ${foundVoice['name']} for $voice');
      } catch (e) {
        print('Failed to set found voice, using pitch settings: $e');
        await _setVoiceByPitch(voice);
      }
    } else {
      print('No specific voice found, using pitch settings for $voice');
      await _setVoiceByPitch(voice);
    }
  }

  Future<void> _setVoiceByPitch(String voice) async {
    if (voice == 'male') {
      // صدای مرد: استفاده از en-gb-x-gbd-local
      try {
        await _flutterTts
            .setVoice({'name': 'en-gb-x-gbd-local', 'locale': 'en-GB'});
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(0.9);
        print(
            'Setting male voice: en-gb-x-gbd-local, pitch=0.9, rate=0.5, volume=0.9');
      } catch (e) {
        print('Failed to set male voice, using fallback: $e');
        await _flutterTts.setLanguage('en-GB');
        await _flutterTts.setPitch(0.3);
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setVolume(0.9);
      }
    } else if (voice == 'female') {
      // صدای زن: استفاده از تنظیمات pitch و rate
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.5);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      print('Setting female voice: pitch=1.5, rate=0.5, volume=1.0');
    }
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setLanguage(language);
  }

  /// Speaks the given text with optional voice selection
  ///
  /// This method converts text to speech using the current voice settings.
  /// If a voice is specified, it will be set before speaking.
  ///
  /// Parameters:
  /// - [text]: The text to be spoken
  /// - [voice]: Optional voice selection ("male" or "female")
  ///
  /// Usage:
  /// ```dart
  /// // Simple text-to-speech
  /// await ttsService.speak("Hello World");
  ///
  /// // With voice selection
  /// await ttsService.speak("Hello", voice: "male");
  /// ```
  Future<void> speak(String text, {String? voice}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // اگر voice مشخص شده، آن را تنظیم کن
    if (voice != null && voice != _currentVoice) {
      await setVoice(voice);
      // تاخیر کوتاه برای اطمینان از اعمال تنظیمات
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _speechCompleter = Completer<void>();
    await _flutterTts.speak(text);
    await _speechCompleter?.future;
  }

  /// Sets the male voice with optimized settings
  ///
  /// This method sets the voice to 'en-gb-x-gbd-local' which is the
  /// selected male voice for the application with the following settings:
  /// - Pitch: 0.9
  /// - Rate: 0.4
  /// - Volume: 0.9
  /// - Locale: en-GB
  ///
  /// Usage:
  /// ```dart
  /// await ttsService.setMaleVoice();
  /// await ttsService.speak("Hello, I am the male voice");
  /// ```
  Future<void> setMaleVoice() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts
          .setVoice({'name': 'en-gb-x-gbd-local', 'locale': 'en-GB'});
      await _flutterTts.setPitch(0.9);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.9);
      _currentVoice = 'male';
      print('Male voice set: en-gb-x-gbd-local');
    } catch (e) {
      print('Failed to set male voice: $e');
    }
  }

  /// Sets the female voice with optimized settings
  ///
  /// This method sets the voice to 'en-us-x-sfg-local' which is the
  /// selected female voice for the application with the following settings:
  /// - Pitch: 1.2
  /// - Rate: 0.45
  /// - Volume: 1.0
  /// - Locale: en-US
  ///
  /// Usage:
  /// ```dart
  /// await ttsService.setFemaleVoice();
  /// await ttsService.speak("Hello, I am the female voice");
  /// ```
  Future<void> setFemaleVoice() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts
          .setVoice({'name': 'en-us-x-sfg-local', 'locale': 'en-US'});
      await _flutterTts.setPitch(1.2);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      _currentVoice = 'female';
      print('Female voice set: en-us-x-sfg-local');
    } catch (e) {
      print('Failed to set female voice: $e');
    }
  }

  Future<void> stop() async {
    if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
      _speechCompleter?.complete();
    }
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }

  // متد برای دریافت لیست صداهای موجود
  Future<List<Map<String, String>>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      final voices = await _flutterTts.getVoices;
      print('Raw voices type: ${voices.runtimeType}');
      print('Raw voices: $voices');

      // تبدیل به List<Map<String, String>>
      List<Map<String, String>> result = [];
      for (var voice in voices) {
        if (voice is Map) {
          Map<String, String> voiceMap = {};
          voice.forEach((key, value) {
            voiceMap[key.toString()] = value.toString();
          });
          result.add(voiceMap);
        }
      }
      return result;
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }

  // متد برای امتحان صداهای مختلف
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

  // متد ساده برای نمایش صداهای موجود
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

  // متد برای نمایش صداهای انگلیسی
  Future<void> showEnglishVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await getVoices();
      print('Total voices: ${voices.length}');

      // فیلتر کردن صداهای انگلیسی
      List<Map<String, String>> englishVoices = [];
      for (var voice in voices) {
        final locale = voice['locale']?.toLowerCase() ?? '';
        if (locale.startsWith('en-')) {
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

  // متد برای پیدا کردن صداهای مناسب
  Future<Map<String, String>?> findVoiceForGender(String gender) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final voices = await getVoices();
      print('Total voices found: ${voices.length}');

      // فیلتر کردن صداهای انگلیسی
      List<Map<String, String>> englishVoices = [];
      for (var voice in voices) {
        final locale = voice['locale']?.toLowerCase() ?? '';
        if (locale.startsWith('en-')) {
          englishVoices.add(voice);
        }
      }

      print('English voices found: ${englishVoices.length}');

      // جستجوی صداهای مناسب بر اساس نام
      for (var voice in englishVoices) {
        final name = voice['name']?.toLowerCase() ?? '';
        print('Checking English voice: $name');

        if (gender == 'male') {
          // جستجوی صداهای مردانه - اولویت با en-gb-x-gbd-local
          if (name.contains('gbd') && name.contains('local')) {
            // en-gb-x-gbd-local (صدای مرد انتخابی)
            print('Found selected male voice: ${voice['name']}');
            return voice;
          } else if (name.contains('gba') || // en-gb-x-gba-local
              name.contains('gbb') || // en-gb-x-gbb-network
              name.contains('rjs') || // en-gb-x-rjs-local
              name.contains('gbg') || // en-gb-x-gbg-local
              name.contains('gbc')) {
            // en-gb-x-gbc-local/network
            print('Found alternative male voice: ${voice['name']}');
            return voice;
          }
        } else if (gender == 'female') {
          // جستجوی صداهای زنانه - اولویت با صداهای آمریکایی
          if (name.contains(
                  'sfg') || // en-us-x-sfg-local/network (بهترین صدای زن)
              name.contains('tpf') || // en-us-x-tpf-local
              name.contains('tpd') || // en-us-x-tpd-local/network
              name.contains('tpc') || // en-us-x-tpc-local/network
              name.contains('iob') || // en-us-x-iob-local/network
              name.contains('iol') || // en-us-x-iol-local/network
              name.contains('iom') || // en-us-x-iom-local/network
              name.contains('iog')) {
            // en-us-x-iog-local/network
            print('Found female voice: ${voice['name']}');
            return voice;
          }
        }
      }

      // اگر صداهای خاص پیدا نشد، اولین صدا انگلیسی را برگردان
      if (englishVoices.isNotEmpty) {
        print('Using default English voice: ${englishVoices.first['name']}');
        return englishVoices.first;
      }
    } catch (e) {
      print('Error finding voice: $e');
    }

    return null;
  }

  // متد برای debug - نمایش تنظیمات فعلی
  void printCurrentSettings() {
    print('Current voice: $_currentVoice');
    print('TTS initialized: $_isInitialized');
  }

  // متد برای امتحان صداهای مختلف
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

  // متد برای امتحان صداهای خاص male و female
  Future<void> testMaleFemaleVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('Testing male and female voices...');

      // امتحان صدای مرد
      final maleVoice = await findVoiceForGender('male');
      if (maleVoice != null) {
        print('Testing male voice: ${maleVoice['name']}');
        try {
          await _flutterTts
              .setVoice({'name': 'en-gb-x-gbd-local', 'locale': 'en-GB'});
          await _flutterTts.setPitch(0.9);
          await _flutterTts.speak('Hello, I am the male voice');
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          print('Failed to test male voice: $e');
        }
      }

      // امتحان صدای زن
      final femaleVoice = await findVoiceForGender('female');
      if (femaleVoice != null) {
        print('Testing female voice: ${femaleVoice['name']}');
        try {
          await _flutterTts.setVoice({
            'name': femaleVoice['name'] ?? '',
            'locale': femaleVoice['locale'] ?? 'en-US'
          });
          await _flutterTts.speak('Hello, I am the female voice');
          await Future.delayed(const Duration(seconds: 3));
        } catch (e) {
          print('Failed to test female voice: $e');
        }
      }
    } catch (e) {
      print('Error testing male/female voices: $e');
    }
  }
}
