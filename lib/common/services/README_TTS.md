# TTSService Documentation

## Overview

`TTSService` is a comprehensive Text-to-Speech service for Flutter applications that provides voice synthesis capabilities with support for multiple voices, languages, and gender-specific voice selection.

## Features

- ✅ Multiple voice support (Male/Female)
- ✅ Language selection (English, Persian, etc.)
- ✅ Voice pitch and rate control
- ✅ Volume control
- ✅ Gender-specific voice selection
- ✅ Conversation support with different voices
- ✅ Error handling and fallback mechanisms
- ✅ Voice discovery and testing capabilities

## Installation

Make sure you have `flutter_tts` package in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_tts: ^3.8.5
```

## Basic Usage

### 1. Initialize the Service

```dart
final TTSService ttsService = locator<TTSService>();
await ttsService.initialize();
```

### 2. Basic Text-to-Speech

```dart
// Simple text-to-speech
await ttsService.speak("Hello, this is a test");

// With specific voice
await ttsService.speak("Hello", voice: "male");
```

### 3. Gender-Specific Voices

```dart
// Set male voice (en-gb-x-gbd-local)
await ttsService.setMaleVoice();
await ttsService.speak("Hello, I am the male voice");

// Set female voice (en-us-x-sfg-local)
await ttsService.setFemaleVoice();
await ttsService.speak("Hello, I am the female voice");
```

## API Reference

### Core Methods

#### `initialize()`

Initializes the TTS service with default settings.

```dart
await ttsService.initialize();
```

#### `speak(String text, {String? voice})`

Speaks the given text with optional voice selection.

```dart
await ttsService.speak("Hello World");
await ttsService.speak("Hello World", voice: "male");
```

#### `stop()`

Stops the current speech.

```dart
await ttsService.stop();
```

### Voice Control Methods

#### `setMaleVoice()`

Sets the male voice (en-gb-x-gbd-local) with optimized settings.

```dart
await ttsService.setMaleVoice();
```

#### `setFemaleVoice()`

Sets the female voice (en-us-x-sfg-local) with optimized settings.

```dart
await ttsService.setFemaleVoice();
```

#### `setVoice(String voice)`

Sets voice based on gender string ("male" or "female").

```dart
await ttsService.setVoice("male");
await ttsService.setVoice("female");
```

### Voice Discovery Methods

#### `getVoices()`

Returns a list of available voices.

```dart
List<Map<String, String>> voices = await ttsService.getVoices();
```

#### `showEnglishVoices()`

Prints all available English voices to console.

```dart
await ttsService.showEnglishVoices();
```

#### `findVoiceForGender(String gender)`

Finds the best voice for the specified gender.

```dart
Map<String, String>? maleVoice = await ttsService.findVoiceForGender("male");
Map<String, String>? femaleVoice = await ttsService.findVoiceForGender("female");
```

### Testing Methods

#### `testMaleFemaleVoices()`

Tests both male and female voices with sample text.

```dart
await ttsService.testMaleFemaleVoices();
```

#### `testDifferentVoices()`

Tests the first 3 available voices.

```dart
await ttsService.testDifferentVoices();
```

### Configuration Methods

#### `setPitch(double pitch)`

Sets the voice pitch (0.5 to 2.0).

```dart
await ttsService.setPitch(1.0);
```

#### `setLanguage(String language)`

Sets the language for TTS.

```dart
await ttsService.setLanguage("en-US");
await ttsService.setLanguage("fa-IR");
```

## Voice Configuration

### Male Voice Settings

- **Voice**: `en-gb-x-gbd-local`
- **Locale**: `en-GB`
- **Pitch**: 0.9
- **Rate**: 0.4
- **Volume**: 0.9

### Female Voice Settings

- **Voice**: `en-us-x-sfg-local`
- **Locale**: `en-US`
- **Pitch**: 1.2
- **Rate**: 0.5
- **Volume**: 1.0

## Conversation Support

### For Conversation Screens

The service is optimized for conversation screens where different messages need different voices:

```dart
// In your conversation screen
Future<void> speakMessage(String text, String voice) async {
  if (voice == 'male') {
    await ttsService.setMaleVoice();
    await ttsService.speak(text);
  } else if (voice == 'female') {
    await ttsService.setFemaleVoice();
    await ttsService.speak(text);
  }
}
```

### Play All Conversations

```dart
Future<void> playAllConversations(List<Message> messages) async {
  for (var message in messages) {
    if (message.voice == 'male') {
      await ttsService.setMaleVoice();
    } else if (message.voice == 'female') {
      await ttsService.setFemaleVoice();
    }
    await ttsService.speak(message.text);
    await Future.delayed(Duration(milliseconds: 500));
  }
}
```

## Error Handling

The service includes comprehensive error handling:

```dart
try {
  await ttsService.speak("Hello");
} catch (e) {
  print("TTS Error: $e");
  // Fallback to default voice or show error message
}
```

## Best Practices

### 1. Initialize Once

```dart
// Initialize once in your app startup
await ttsService.initialize();
```

### 2. Use Gender-Specific Methods

```dart
// Preferred for conversation apps
await ttsService.setMaleVoice();
await ttsService.speak(text);

// Instead of
await ttsService.speak(text, voice: "male");
```

### 3. Handle Errors Gracefully

```dart
try {
  await ttsService.setMaleVoice();
  await ttsService.speak(text);
} catch (e) {
  // Fallback to default voice
  await ttsService.speak(text);
}
```

### 4. Stop Previous Speech

```dart
// Stop any ongoing speech before starting new one
await ttsService.stop();
await ttsService.speak(newText);
```

## Troubleshooting

### Common Issues

#### 1. Voice Not Found

```
Error: Voice name not found
```

**Solution**: The service will automatically fallback to pitch-based voice settings.

#### 2. TTS Not Initialized

```
Error: TTS not initialized
```

**Solution**: Call `initialize()` before using the service.

#### 3. No Voices Available

```
Error: No voices found
```

**Solution**: Check device TTS settings and ensure voices are installed.

### Debug Methods

#### Check Available Voices

```dart
await ttsService.showEnglishVoices();
```

#### Test Voices

```dart
await ttsService.testMaleFemaleVoices();
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (limited)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Dependencies

- `flutter_tts: ^3.8.5`
- `dart:async` (for Completer)

## License

This service is part of the Poortak application and follows the same license terms.

## Support

For issues or questions regarding the TTS service, please refer to the main project documentation or contact the development team.

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Author**: Poortak Development Team
