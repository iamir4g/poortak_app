import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:poortak/common/utils/url_launcher_utils.dart';
import 'package:share_plus/share_plus.dart';

class CafeBazaarUtils {
  CafeBazaarUtils._();

  static const String appPackageName = 'com.example.poortak';
  static const String _bazaarPackageName = 'com.farsitel.bazaar';
  static const String appWebUrl = 'https://cafebazaar.ir/app/$appPackageName';

  static Future<void> openCommentPage() async {
    if (!kIsWeb && Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.EDIT',
        data: 'bazaar://details?id=$appPackageName',
        package: _bazaarPackageName,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      final canOpen = await intent.canResolveActivity() ?? false;
      if (canOpen) {
        await intent.launch();
        return;
      }
    }
    await launchExternalUri(Uri.parse(appWebUrl));
  }

  static Future<void> shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'پورتک؛ اپلیکیشن آموزش زبان انگلیسی را از کافه‌بازار دانلود کنید:\n$appWebUrl',
      ),
    );
  }
}
