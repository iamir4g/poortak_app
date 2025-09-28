# FontSizeHelper - راهنمای استفاده از تنظیمات فونت سراسری

## مقدمه
`FontSizeHelper` یک utility class است که امکان اعمال تنظیمات اندازه فونت کاربر را در کل اپلیکیشن فراهم می‌کند.

## نحوه استفاده

### 1. Import کردن
```dart
import 'package:poortak/common/utils/font_size_helper.dart';
```

### 2. استفاده در Text Widgets

#### روش اول: استفاده از `getContentTextStyle`
```dart
Text(
  "متن محتوای درسی",
  style: FontSizeHelper.getContentTextStyle(
    context,
    baseFontSize: 16.0, // اندازه فونت پایه
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ),
)
```

#### روش دوم: استفاده از `getScaledFontSize`
```dart
Text(
  "متن محتوای درسی",
  style: TextStyle(
    fontSize: FontSizeHelper.getScaledFontSize(context, 16.0),
    color: Colors.black,
  ),
)
```

#### روش سوم: استفاده از `getScaledTextStyle`
```dart
Text(
  "متن محتوای درسی",
  style: FontSizeHelper.getScaledTextStyle(
    context,
    16.0,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ),
)
```

## مثال‌های کاربردی

### در Conversation Screen
```dart
Text(
  message.text,
  style: FontSizeHelper.getContentTextStyle(
    context,
    baseFontSize: 16.0,
    color: isFirstPerson ? Colors.white : Colors.black,
  ),
),
```

### در Quiz Screen
```dart
Text(
  questionData.title,
  textAlign: TextAlign.center,
  style: FontSizeHelper.getContentTextStyle(
    context,
    baseFontSize: 16.0,
    fontWeight: FontWeight.bold,
  ),
),
```

## نکات مهم

1. **فقط برای متن‌های محتوای درسی**: این helper فقط برای متن‌های محتوای درسی استفاده می‌شود، نه برای UI elements مثل دکمه‌ها، منوها و غیره.

2. **Context ضروری**: همیشه باید `context` را به عنوان اولین پارامتر ارسال کنید.

3. **baseFontSize**: اندازه فونت پایه را بر اساس طراحی اصلی تعیین کنید.

4. **محدوده تغییر**: اندازه فونت بین 0.8 تا 1.4 برابر اندازه اصلی تغییر می‌کند.

## تنظیمات کاربر

کاربر می‌تواند از طریق صفحه تنظیمات (`SettingsScreen`) اندازه فونت را تغییر دهد:
- اسلایدر "اندازه متون محتوای درسی" 
- تغییرات به صورت خودکار در کل اپلیکیشن اعمال می‌شود
- تنظیمات در SharedPreferences ذخیره می‌شود

## فایل‌های مرتبط

- `SettingsCubit`: مدیریت state تنظیمات
- `SettingsState`: state class برای تنظیمات
- `SettingsScreen`: صفحه تنظیمات کاربر
- `FontSizeHelper`: utility class برای محاسبه اندازه فونت
