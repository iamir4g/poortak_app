import 'package:openai_tts/openai_tts.dart';

/// OpenAITtsService - Text-to-Speech Service using OpenAI API
///
/// This service provides TTS functionality using OpenAI's high-quality voices.
/// It is designed to be a drop-in alternative to the standard TTSService.
///
/// Features:
/// - High quality neural voices (Alloy, Echo, Fable, Onyx, Nova, Shimmer)
/// - Streaming support for low latency
/// - Easy voice switching
///
/// Usage:
/// ```dart
/// final openAIService = OpenAITtsService();
/// await openAIService.initialize(apiKey: "your-api-key");
/// await openAIService.speak("Hello from OpenAI");
/// ```
class OpenAITtsService {
  OpenaiTTS? _openaiTTS;
  bool _isInitialized = false;
  String _currentVoice = 'male'; // 'male' or 'female' or specific voice name
  OpenaiTTSVoice _selectedOpenAIVoice = OpenaiTTSVoice.onyx; // Default male

  /// Gets the current voice gender/type
  String get currentVoice => _currentVoice;

  /// Initializes the OpenAI TTS service with an API key
  Future<void> initialize({required String apiKey}) async {
    if (_isInitialized) {
      print('OpenAI TTS already initialized');
      return;
    }

    try {
      _openaiTTS = OpenaiTTS(apiKey: apiKey);
      _isInitialized = true;
      print('OpenAI TTS initialized successfully');
    } catch (e) {
      print('Error initializing OpenAI TTS: $e');
    }
  }

  /// Speaks the given text using the configured voice
  ///
  /// Parameters:
  /// - [text]: The text to be spoken
  /// - [voice]: Optional voice selection ("male" or "female")
  Future<void> speak(String text, {String? voice}) async {
    if (!_isInitialized || _openaiTTS == null) {
      print('OpenAI TTS not initialized. Call initialize() first.');
      return;
    }

    // Update voice if specified
    if (voice != null) {
      if (voice == 'male') {
        await setMaleVoice();
      } else if (voice == 'female') {
        await setFemaleVoice();
      }
    }

    try {
      print(
          'Speaking via OpenAI: "$text" with voice ${_selectedOpenAIVoice.name}');
      await _openaiTTS!.streamSpeak(
        text,
        voice: _selectedOpenAIVoice,
        model: OpenaiTTSModel.tts1, // Use tts-1 for lower latency
      );
    } catch (e) {
      print('Error during OpenAI speak: $e');
    }
  }

  /// Sets the voice based on gender string ('male' or 'female')
  Future<void> setVoice(String voice) async {
    if (voice.toLowerCase() == 'male') {
      await setMaleVoice();
    } else if (voice.toLowerCase() == 'female') {
      await setFemaleVoice();
    } else {
      print('Unknown voice gender: $voice. Defaulting to Male (Onyx).');
      await setMaleVoice();
    }
  }

  /// Sets the male voice (Onyx)
  Future<void> setMaleVoice() async {
    _selectedOpenAIVoice = OpenaiTTSVoice.onyx;
    _currentVoice = 'male';
    print('OpenAI Voice set to Male (Onyx)');
  }

  /// Sets the female voice (Nova)
  Future<void> setFemaleVoice() async {
    _selectedOpenAIVoice = OpenaiTTSVoice.nova;
    _currentVoice = 'female';
    print('OpenAI Voice set to Female (Nova)');
  }

  /// Stops playback
  Future<void> stop() async {
    if (!_isInitialized || _openaiTTS == null) return;
    try {
      await _openaiTTS!.stopPlayer();
    } catch (e) {
      print('Error stopping OpenAI player: $e');
    }
  }

  /// Disposes resources
  void dispose() {
    try {
      // ignore: undefined_method
      // _openaiTTS?.dispose();
    } catch (e) {
      print('Error disposing OpenAI TTS: $e');
    }
  }
}
