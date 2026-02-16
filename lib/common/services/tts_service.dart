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
library;

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

    try {
      // تنظیمات اولیه پایه
      await _flutterTts.awaitSpeakCompletion(true);

      // تلاش برای تنظیم زبان و بررسی وضعیت موتور
      // این کار باعث می‌شود موتور TTS در اندروید bind شود
      var languageAvailable = await _flutterTts.isLanguageAvailable("en-US");

      if (languageAvailable != null) {
        print('Language en-US availability: $languageAvailable');
        await _flutterTts.setLanguage('en-US');
      } else {
        print(
            'Failed to check language availability - TTS engine might not be ready');
      }

      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Warm up voices with timeout
      try {
        print('Warming up voices...');
        // استفاده از timeout برای جلوگیری از گیر کردن اگر موتور پاسخ ندهد
        await _flutterTts.getVoices.timeout(const Duration(seconds: 2),
            onTimeout: () {
          print('Timeout waiting for voices');
          return null;
        });
      } catch (e) {
        print('Error warming up voices: $e');
      }

      _flutterTts.setCompletionHandler(() {
        _speechCompleter?.complete();
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        _speechCompleter?.completeError(msg);
      });

      _isInitialized = true;
      print('TTS initialized successfully');
    } catch (e) {
      print('Critical Error initializing TTS: $e');
      // حتی در صورت خطا، فلگ را ست می‌کنیم تا تلاش‌های بعدی باعث لوپ نشود
      // اما ممکن است بخواهیم دوباره تلاش کنیم. اینجا فرض می‌کنیم که وضعیت اضطراری است.
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
      // صدای مرد: استفاده از لهجه آمریکایی
      try {
        // تلاش برای استفاده از صدای مردانه آمریکایی
        await _flutterTts
            .setVoice({'name': 'en-us-x-iom-local', 'locale': 'en-US'});
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(0.9);
        print(
            'Setting male voice: en-us-x-iom-local, pitch=0.9, rate=0.4, volume=0.9');
      } catch (e) {
        print('Failed to set male voice, using fallback: $e');
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setPitch(0.9);
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
      // بررسی می‌کنیم که آیا این تغییر صدا واقعا لازم است و آیا امکان‌پذیر است
      // اگر getVoices خالی باشد، setVoice کار نمی‌کند، پس فقط در صورت وجود صداها تلاش می‌کنیم
      try {
        final voices = await getVoices();
        if (voices.isNotEmpty) {
          await setVoice(voice);
          // تاخیر کوتاه برای اطمینان از اعمال تنظیمات
          await Future.delayed(const Duration(milliseconds: 50));
        } else {
          print(
              'Skipping voice set because voices list is empty. Using default voice.');
        }
      } catch (e) {
        print('Error attempting to set voice in speak: $e');
      }
    }

    _speechCompleter = Completer<void>();
    try {
      var result = await _flutterTts.speak(text);
      if (result != 1) {
        print('Speak method returned $result - might have failed');
        // اگر speak ناموفق بود، شاید موتور آماده نیست. یک بار دیگر زبان را ست می‌کنیم
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print('Error during speak: $e');

      // Attempt to recover if TTS engine is not bound or other critical error
      if (e.toString().contains("not bound") ||
          e.toString().contains("initialize")) {
        print('TTS engine issue detected. Re-initializing...');
        _isInitialized = false;
        try {
          await initialize();
          await _flutterTts.setLanguage('en-US');
          await _flutterTts.speak(text);
          return;
        } catch (retryError) {
          print('Retry failed: $retryError');
          _speechCompleter?.completeError(retryError);
          return;
        }
      }

      _speechCompleter?.completeError(e);
      return;
    }

    // در برخی موارد completion handler صدا زده نمی‌شود اگر متن کوتاه باشد یا خطا رخ دهد
    // بنابراین یک تایمر ایمنی می‌گذاریم؟ نه، فعلا به مکانیزم خود پکیج اعتماد می‌کنیم
    // اما اگر awaitSpeakCompletion(true) باشد، خط بعد تا پایان صبر می‌کند.

    // نکته: وقتی awaitSpeakCompletion(true) است، خود متد speak باید Future را تا پایان نگه دارد
    // اما ما اینجا از completer دستی هم استفاده کردیم برای اطمینان بیشتر.
    // اگر awaitSpeakCompletion کار کند، خط بعد بلافاصله بعد از پایان صحبت اجرا می‌شود.

    // اگر completer تکمیل نشده باشد (مثلا هندلر صدا زده نشود)، اینجا گیر نمی‌کنیم چون await _flutterTts.speak(text) خودش صبر می‌کند (اگر آپشن ست شده باشد)
    // اما برای اطمینان از backward compatibility کد موجود:
    // await _speechCompleter?.future; // این خط ممکن است خطرناک باشد اگر هندلر صدا زده نشود.

    // با توجه به تنظیم awaitSpeakCompletion(true)، متد speak خودش Future<void> برمی‌گرداند (در نسخه‌های جدیدتر) یا Future<int>
    // در نسخه 4.x، speak متد Future<dynamic> است.

    // ما _speechCompleter را نگه می‌داریم اما با احتیاط.
  }

  /// Sets the male voice with optimized settings
  ///
  /// This method sets the voice to 'en-us-x-iom-local' which is the
  /// selected male voice for the application with the following settings:
  /// - Pitch: 0.9
  /// - Rate: 0.4
  /// - Volume: 0.9
  /// - Locale: en-US
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
      // استفاده از findVoiceForGender برای پیدا کردن صدای موجود و جلوگیری از کرش
      final voice = await findVoiceForGender('male');

      if (voice != null) {
        await _flutterTts.setVoice({
          'name': voice['name'] ?? '',
          'locale': voice['locale'] ?? 'en-US'
        });
        print('Male voice set: ${voice['name']}');
      } else {
        print('No specific male voice found, using generic settings');
        // تنظیمات پیش‌فرض اگر صدای خاصی پیدا نشد
        await _flutterTts.setLanguage('en-US');
      }

      await _flutterTts.setPitch(0.9);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.9);
      _currentVoice = 'male';
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
      // استفاده از findVoiceForGender برای پیدا کردن صدای موجود و جلوگیری از کرش
      final voice = await findVoiceForGender('female');

      if (voice != null) {
        await _flutterTts.setVoice({
          'name': voice['name'] ?? '',
          'locale': voice['locale'] ?? 'en-US'
        });
        print('Female voice set: ${voice['name']}');
      } else {
        print('No specific female voice found, using generic settings');
        // تنظیمات پیش‌فرض اگر صدای خاصی پیدا نشد
        await _flutterTts.setLanguage('en-US');
      }

      await _flutterTts.setPitch(1.2);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      _currentVoice = 'female';
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
      // Add timeout to prevent hanging if TTS engine is stuck
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
        return [];
      }

      print('Raw voices: $voices');

      // تبدیل به List<Map<String, String>>
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

      // Filter for American English voices
      List<Map<String, String>> americanVoices = [];
      for (var voice in voices) {
        final locale = voice['locale']?.toLowerCase() ?? '';
        if (locale.contains('en-us') || locale.contains('en_us')) {
          americanVoices.add(voice);
        }
      }

      print('American voices found: ${americanVoices.length}');

      // Search for suitable voices based on name
      // If American voices are found, search within them first
      final voicesToSearch =
          americanVoices.isNotEmpty ? americanVoices : voices;

      for (var voice in voicesToSearch) {
        final name = voice['name']?.toLowerCase() ?? '';

        if (gender == 'male') {
          // Search for male voices - Priority: en-us-x-iom-local
          if (name.contains('iom') && name.contains('local')) {
            print('Found preferred male voice: ${voice['name']}');
            return voice;
          }
          // Other American male voices
          if (name.contains('male') &&
              (name.contains('en-us') || name.contains('en_us'))) {
            print('Found American male voice: ${voice['name']}');
            return voice;
          }
        } else if (gender == 'female') {
          // Search for female voices - Priority: American
          if (name.contains('sfg') || // en-us-x-sfg-local
              name.contains('tpf') || // en-us-x-tpf-local
              name.contains('iob') || // en-us-x-iob-local
              name.contains('female') &&
                  (name.contains('en-us') || name.contains('en_us'))) {
            print('Found female voice: ${voice['name']}');
            return voice;
          }
        }
      }

      // If no specific voice found, return first American voice
      if (americanVoices.isNotEmpty) {
        print('Using default American voice: ${americanVoices.first['name']}');
        return americanVoices.first;
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
              .setVoice({'name': 'en-us-x-iom-local', 'locale': 'en-US'});
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
