import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('⚠️ Failed to load .env: $e');
    }
  }

  static const String supportBaleUrl = 'https://ble.ir/example';
  static const String supportTelegramUrl = 'https://t.me/example';
  static const String supportWhatsappUrl = 'https://wa.me/example';

  static String get cafeBazaarRsaKey {
    final value = dotenv.env['CAFEBAZAAR_RSA_KEY']?.trim() ?? '';
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}
