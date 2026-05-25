import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Uint8List?> loadEmbeddedPngBytesFromSvgAsset(String assetPath) async {
  final svg = await rootBundle.loadString(assetPath);
  final match = RegExp(r'data:image\/(?:png|jpe?g);base64,([^"]+)')
      .firstMatch(svg);
  final base64Data = match?.group(1);
  if (base64Data == null || base64Data.isEmpty) return null;
  return base64Decode(base64Data);
}

Widget buildImageFromAssetOrEmbeddedSvg(
  String assetPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (assetPath.toLowerCase().endsWith('.svg')) {
    return FutureBuilder<Uint8List?>(
      future: loadEmbeddedPngBytesFromSvgAsset(assetPath),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return SizedBox(width: width, height: height);
        }
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  return Image.asset(
    assetPath,
    width: width,
    height: height,
    fit: fit,
  );
}
