/// Minimal .env loader (no third-party package).
///
/// Reads `KEY=VALUE` lines from a Flutter asset and exposes them via [Env].
library;

import 'package:flutter/services.dart';

class Env {
  Env._();

  static final Map<String, String> _values = {};
  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static String? maybeGet(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String get(String key, {String fallback = ''}) =>
      maybeGet(key) ?? fallback;

  /// Loads the first available asset from [fileNames].
  static Future<void> load({
    List<String> fileNames = const ['.env', '.env.example'],
  }) async {
    for (final name in fileNames) {
      try {
        final raw = await rootBundle.loadString(name);
        _parse(raw);
        _loaded = true;
        return;
      } catch (_) {
        // try next file
      }
    }
    _loaded = true; // mark attempted; values may stay empty
  }

  static void _parse(String raw) {
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      if (key.isNotEmpty) {
        _values[key] = value;
      }
    }
  }
}
