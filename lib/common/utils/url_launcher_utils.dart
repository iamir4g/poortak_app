import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] in an external app (browser, mail, phone).
/// Tries multiple launch modes for Android and iOS compatibility.
Future<bool> launchExternalUri(Uri uri) async {
  final modes = uri.scheme == 'mailto'
      ? const [LaunchMode.platformDefault, LaunchMode.externalApplication]
      : const [LaunchMode.externalApplication, LaunchMode.platformDefault];

  for (final mode in modes) {
    try {
      if (await launchUrl(uri, mode: mode)) {
        return true;
      }
    } catch (_) {
      // Try the next launch mode.
    }
  }

  return false;
}

String normalizeWebsiteUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}
