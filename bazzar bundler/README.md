# امضای باندل برای کافه‌بازار

این پوشه برای تولید فایل `.bin` امضای بازار است.

## پیش‌نیاز

1. `android/upload-keystore.jks` و `android/key.properties` روی سیستم شما باشد
2. فایل AAB ساخته شده باشد:

```bash
flutter build appbundle --release
```

## تولید فایل bin

```bash
chmod +x "bazzar bundler/generate_bazaar_sign.sh"
./bazzar\ bundler/generate_bazaar_sign.sh
```

یا اگر AAB در مسیر دیگری است:

```bash
./bazzar\ bundler/generate_bazaar_sign.sh /path/to/your.aab
```

خروجی در `bazzar bundler/output/` ذخیره می‌شود.

## مراحل بارگذاری در بازار

1. همان AABی را که با `flutter build appbundle --release` ساخته‌اید در پیشخان بازار بارگذاری کنید
2. با **همان AAB** و **همان keystore** فایل `.bin` را با اسکریپت بالا بسازید
3. فایل `.bin` را در پیشخان بازار آپلود کنید

## نکات مهم

- اگر قبلاً با APK منتشر کرده‌اید، حتماً از **همان keystore قبلی** استفاده کنید
- AAB داده‌شده به Bundle Signer باید **دقیقاً همان فایلی** باشد که در پیشخان بارگذاری کرده‌اید
- `upload-keystore.jks` و `key.properties` را در git قرار ندهید و از آن‌ها backup بگیرید
