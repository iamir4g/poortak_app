# CustomVideoPlayer - راهنمای استفاده از Video Player با قابلیت Fullscreen

## مقدمه
`CustomVideoPlayer` یک video player سفارشی است که قابلیت fullscreen و کنترل‌های پیشرفته را فراهم می‌کند.

## ویژگی‌ها

### ✅ **قابلیت‌های اصلی**
- پخش ویدیو از فایل محلی یا شبکه
- کنترل‌های play/pause
- نوار پیشرفت (progress bar)
- نمایش زمان فعلی و کل ویدیو
- قابلیت fullscreen
- تنظیمات قابل سفارشی‌سازی

### ✅ **قابلیت Fullscreen**
- دکمه fullscreen در کنترل‌ها
- چرخش خودکار به landscape
- مخفی کردن system UI
- کنترل‌های مخصوص fullscreen
- دکمه خروج از fullscreen

## نحوه استفاده

### استفاده پایه
```dart
CustomVideoPlayer(
  videoPath: "path/to/video.mp4",
  isNetworkVideo: false,
  width: 350,
  height: 240,
  borderRadius: 37,
  autoPlay: true,
  showControls: true,
  allowFullscreen: true, // فعال کردن fullscreen
  onVideoEnded: () {
    print('ویدیو تمام شد');
  },
)
```

### استفاده با ویدیو شبکه
```dart
CustomVideoPlayer(
  videoPath: "https://example.com/video.mp4",
  isNetworkVideo: true,
  width: 350,
  height: 240,
  autoPlay: false,
  allowFullscreen: true,
)
```

### استفاده بدون fullscreen
```dart
CustomVideoPlayer(
  videoPath: "path/to/video.mp4",
  isNetworkVideo: false,
  allowFullscreen: false, // غیرفعال کردن fullscreen
  showControls: true,
)
```

## پارامترها

| پارامتر | نوع | پیش‌فرض | توضیح |
|---------|-----|---------|-------|
| `videoPath` | String | - | مسیر ویدیو (اجباری) |
| `isNetworkVideo` | bool | false | آیا ویدیو از شبکه است؟ |
| `width` | double | 350 | عرض ویدیو |
| `height` | double | 240 | ارتفاع ویدیو |
| `borderRadius` | double | 37 | شعاع گوشه‌های گرد |
| `autoPlay` | bool | true | پخش خودکار |
| `showControls` | bool | true | نمایش کنترل‌ها |
| `allowFullscreen` | bool | true | اجازه fullscreen |
| `onVideoEnded` | VoidCallback? | null | callback پایان ویدیو |

## مثال کامل در Lesson Screen

```dart
CustomVideoPlayer(
  videoPath: localVideoPath ?? videoUrl!,
  isNetworkVideo: localVideoPath == null && videoUrl != null,
  width: 350,
  height: 240,
  borderRadius: 37,
  autoPlay: true,
  showControls: true,
  allowFullscreen: true, // فعال کردن fullscreen
  onVideoEnded: () {
    print('ویدیو تمام شد');
    // منطق بعد از پایان ویدیو
  },
)
```

## قابلیت‌های Fullscreen

### کنترل‌های Fullscreen
- **دکمه خروج**: بازگشت به حالت عادی
- **دکمه play/pause مرکزی**: دکمه بزرگ در وسط
- **نوار پیشرفت**: کنترل پیشرفت ویدیو
- **نمایش زمان**: زمان فعلی و کل ویدیو
- **مخفی شدن خودکار**: کنترل‌ها بعد از 3 ثانیه مخفی می‌شوند

### تنظیمات خودکار
- **چرخش صفحه**: خودکار به landscape
- **مخفی کردن UI**: system UI مخفی می‌شود
- **بازگردانی**: هنگام خروج، تنظیمات بازگردانده می‌شود

## نکات مهم

1. **مدیریت حافظه**: VideoPlayerController به صورت خودکار dispose می‌شود
2. **Orientation**: در fullscreen، صفحه به landscape می‌چرخد
3. **System UI**: در fullscreen، system UI مخفی می‌شود
4. **Performance**: برای ویدیوهای بزرگ، از local path استفاده کنید
5. **Network**: برای ویدیوهای شبکه، اتصال اینترنت را بررسی کنید

## خطاهای رایج

### خطای initialization
```dart
// بررسی کنید که مسیر ویدیو صحیح باشد
if (File(videoPath).existsSync()) {
  // ویدیو موجود است
}
```

### خطای network
```dart
// برای ویدیوهای شبکه، اتصال را بررسی کنید
CustomVideoPlayer(
  videoPath: networkUrl,
  isNetworkVideo: true,
  // ...
)
```

## مثال‌های کاربردی

### ویدیو آموزشی
```dart
CustomVideoPlayer(
  videoPath: lessonVideoPath,
  isNetworkVideo: false,
  width: double.infinity,
  height: 200,
  autoPlay: false,
  allowFullscreen: true,
  onVideoEnded: () {
    // رفتن به درس بعدی
    Navigator.pushNamed(context, '/next-lesson');
  },
)
```

### ویدیو تبلیغاتی
```dart
CustomVideoPlayer(
  videoPath: adVideoUrl,
  isNetworkVideo: true,
  width: 300,
  height: 200,
  autoPlay: true,
  allowFullscreen: false, // تبلیغات معمولاً fullscreen ندارند
  showControls: false, // کنترل‌ها مخفی
)
```
