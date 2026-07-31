# Talkbot TTS (تست)

مستندات:
- v2 (فعال روی توکن فعلی): https://talkbot.ir/TTS-v2-api
- v1 Azure: https://talkbot.ir/text-to-speech-api

## سوییچ موتور

در `lib/common/config/tts_config.dart`:

```dart
static const TtsProviderType provider = TtsProviderType.talkbot; // تست Talkbot
// static const TtsProviderType provider = TtsProviderType.device;   // موتور دستگاه
```

نسخه API (پیش‌فرض v2):

```dart
static const TalkbotApiVersion talkbotApiVersion = TalkbotApiVersion.v2;
```

## توکن

در فایل `.env` (gitignore شده):

```
TALKBOT_API_TOKEN=sk-...
```

## صداها

### v2 (ایرانی)
| جنسیت | voice_id |
|--------|----------|
| مرد | `parsa` |
| زن | `nooshin` |

### v1 (Azure en-US) — نیاز به دسترسی Azure در حساب
| جنسیت | voice |
|--------|--------|
| مرد | `en-US-AndrewNeural - en-US (Male)` |
| زن | `en-US-AvaNeural - en-US (Female)` |

## سرعت و کش

- سرعت پخش: `TtsConfig.talkbotPlaybackRate` (پیش‌فرض `0.78`)
- کش دیسک: `ApplicationSupport/talkbot_tts_cache` — بار دوم همان جمله بدون شبکه پخش می‌شود
- در مکالمه، جمله بعدی با `prefetch` از قبل دانلود می‌شود
