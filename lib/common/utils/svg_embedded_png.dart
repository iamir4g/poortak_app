import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map<String, Future<Uint8List?>> _embeddedImageBytesCache = {};

Future<Uint8List?> loadEmbeddedPngBytesFromSvgAsset(String assetPath) async {
  try {
    final svg = await rootBundle.loadString(assetPath);
    final match =
        RegExp(r'data:image\/(?:png|jpe?g);base64,([^"]+)').firstMatch(svg);
    final base64Data = match?.group(1);
    if (base64Data == null || base64Data.isEmpty) return null;
    return base64Decode(base64Data);
  } catch (_) {
    return null;
  }
}

Future<void> precacheEmbeddedRasterFromSvg(
  BuildContext context,
  String assetPath,
) async {
  final bytes = await _embeddedImageBytesCache.putIfAbsent(
    assetPath,
    () => loadEmbeddedPngBytesFromSvgAsset(assetPath),
  );
  if (bytes != null && bytes.isNotEmpty) {
    await precacheImage(MemoryImage(bytes), context);
  }
}

Widget buildImageFromAssetOrEmbeddedSvg(
  String assetPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (assetPath.toLowerCase().endsWith('.svg')) {
    return FutureBuilder<Uint8List?>(
      future: _embeddedImageBytesCache.putIfAbsent(
        assetPath,
        () => loadEmbeddedPngBytesFromSvgAsset(assetPath),
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        final svgFallback = SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (context) =>
              SizedBox(width: width, height: height),
        );

        final child = (bytes != null && bytes.isNotEmpty)
            ? Image.memory(
                bytes,
                width: width,
                height: height,
                fit: fit,
              )
            : svgFallback;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: KeyedSubtree(
            key: ValueKey(bytes != null && bytes.isNotEmpty),
            child: child,
          ),
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
