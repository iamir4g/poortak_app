import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

Future<Uint8List?> loadEmbeddedPngBytesFromSvgAsset(String assetPath) async {
  final svg = await rootBundle.loadString(assetPath);
  final match = RegExp(r'data:image\/png;base64,([^"]+)').firstMatch(svg);
  final base64Data = match?.group(1);
  if (base64Data == null || base64Data.isEmpty) return null;
  return base64Decode(base64Data);
}
