/// TTS backend selection and Talkbot credentials.
///
/// قبل از اجرای برنامه فقط [provider] را عوض کن تا بین موتور دستگاه
/// و API تاک‌بات سوییچ شود. بقیهٔ کدهای UI تغییری لازم ندارند.
///
/// برای تست Talkbot:
/// ```dart
/// static const TtsProviderType provider = TtsProviderType.talkbot;
/// ```
library;

import 'package:poortak/common/config/env.dart';

/// موتور TTS فعال در اپ
enum TtsProviderType {
  /// موتور فعلی دستگاه (`flutter_tts`) — پیش‌فرض پایدار
  device,

  /// API تاک‌بات — برای تست کیفیت صدا
  talkbot,
}

/// نسخه API تاک‌بات
/// - [v2]: صداهای ایرانی (parsa/nooshin/...) — روی اکثر بسته‌ها فعال است
/// - [v1]: Azure (en-US-AndrewNeural/...) — نیاز به سطح دسترسی Azure دارد
enum TalkbotApiVersion { v1, v2 }

class TtsConfig {
  TtsConfig._();

  /// ⬇️ فقط این فلگ را قبل از Run عوض کن
  /// - [TtsProviderType.device]  → TTS فعلی دستگاه
  /// - [TtsProviderType.talkbot] → سرویس Talkbot برای تست
  static const TtsProviderType provider = TtsProviderType.talkbot;

  static bool get useTalkbot => provider == TtsProviderType.talkbot;

  /// نسخه API — پیش‌فرض v2 چون روی توکن فعلی کار می‌کند.
  /// اگر بسته Azure فعال شد، به [TalkbotApiVersion.v1] عوض کن.
  static const TalkbotApiVersion talkbotApiVersion = TalkbotApiVersion.v1;

  /// سرعت پخش Talkbot (۱.۰ = عادی، کمتر = کندتر). حدود ۰.۷۵–۰.۸۵ برای یادگیری خوب است.
  static const double talkbotPlaybackRate = 0.78;

  /// حداکثر حجم کش دیسک فایل‌های صوتی Talkbot (تعداد فایل).
  static const int talkbotCacheMaxFiles = 200;

  static const String talkbotBaseUrl = 'https://api.talkbot.ir';

  // --- v2 (ایرانی) https://talkbot.ir/TTS-v2-api ---
  static const String talkbotV2Endpoint = '/v2/media/text-to-speech/REQ';
  static const String talkbotV2MaleVoiceId = 'parsa';
  static const String talkbotV2FemaleVoiceId = 'nooshin';

  // --- v1 (Azure) https://talkbot.ir/text-to-speech-api ---
  static const String talkbotV1Endpoint = '/v1/media/text-to-speech/REQ';
  static const String talkbotV1Server = 'azure';
  static const String talkbotV1MaleVoice = 'en-US-AndrewNeural - en-US (Male)';
  static const String talkbotV1FemaleVoice = 'en-US-AvaNeural - en-US (Female)';

  /// توکن از `.env` خوانده می‌شود؛ در صورت نبود، از --dart-define
  static String get talkbotApiToken {
    final fromEnv = Env.maybeGet('TALKBOT_API_TOKEN')?.trim() ?? '';
    if (fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment('TALKBOT_API_TOKEN', defaultValue: '');
  }
}
