import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map<String, Future<Uint8List?>> _embeddedImageBytesCache = {};
final Map<String, Future<String?>> _sanitizedSvgCache = {};

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

Future<String?> loadSanitizedSvgWithoutEmbeddedRaster(String assetPath) async {
  try {
    final svg = await rootBundle.loadString(assetPath);
    final withoutDefs = svg.replaceAll(
      RegExp(r'<defs[\s\S]*?</defs>', caseSensitive: false),
      '',
    );
    final withoutPatternRects = withoutDefs.replaceAll(
      RegExp(r'<rect\b[^>]*fill="url\(#pattern[^"]*\)"[^>]*/>',
          caseSensitive: false),
      '',
    );
    final withoutPatternRectPairs = withoutPatternRects.replaceAll(
      RegExp(r'<rect\b[^>]*fill="url\(#pattern[^"]*\)"[^>]*>[\s\S]*?</rect>',
          caseSensitive: false),
      '',
    );
    final trimmed = withoutPatternRectPairs.trim();
    final hasVector = RegExp(
      r'<(path|circle|ellipse|polygon|polyline|line|g)\b',
      caseSensitive: false,
    ).hasMatch(trimmed);
    if (!hasVector) return null;
    return trimmed;
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
    return FutureBuilder<({Uint8List? bytes, String? sanitizedSvg})>(
      future: () async {
        final bytes = await _embeddedImageBytesCache.putIfAbsent(
          assetPath,
          () => loadEmbeddedPngBytesFromSvgAsset(assetPath),
        );
        final sanitizedSvg = await _sanitizedSvgCache.putIfAbsent(
          assetPath,
          () => loadSanitizedSvgWithoutEmbeddedRaster(assetPath),
        );
        return (bytes: bytes, sanitizedSvg: sanitizedSvg);
      }(),
      builder: (context, snapshot) {
        final bytes = snapshot.data?.bytes;
        final sanitizedSvg = snapshot.data?.sanitizedSvg;
        final svgFallback = SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (context) =>
              SizedBox(width: width, height: height),
        );

        final bool hasEmbeddedRaster = bytes != null && bytes.isNotEmpty;
        final bool hasSanitizedSvg =
            sanitizedSvg != null && sanitizedSvg.trim().isNotEmpty;

        final Widget child;
        if (hasSanitizedSvg) {
          child = SvgPicture.string(
            sanitizedSvg!,
            width: width,
            height: height,
            fit: fit,
          );
        } else if (hasEmbeddedRaster) {
          child = Image.memory(
            bytes!,
            width: width,
            height: height,
            fit: fit,
          );
        } else {
          child = svgFallback;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: KeyedSubtree(
            key: ValueKey(hasSanitizedSvg || hasEmbeddedRaster),
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
