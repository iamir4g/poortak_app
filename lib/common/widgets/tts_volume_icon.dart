import 'package:flutter/material.dart';
import 'package:poortak/common/config/tts_config.dart';
import 'package:poortak/common/services/tts_client.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/locator.dart';

/// آیکون بلندگو که هنگام آماده‌سازی TTS آنلاین به لودینگ تبدیل می‌شود.
/// با موتور دستگاه همان آیکون معمولی را نشان می‌دهد.
class TtsVolumeIcon extends StatelessWidget {
  const TtsVolumeIcon({
    super.key,
    required this.size,
    this.assetPath,
    this.iconData,
    this.color,
    this.strokeWidth = 2,
  }) : assert(assetPath != null || iconData != null);

  final double size;
  final String? assetPath;
  final IconData? iconData;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final idle = assetPath != null
        ? Image.asset(
            assetPath!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            color: color,
          )
        : Icon(
            iconData,
            size: size,
            color: color,
          );

    if (!TtsConfig.useTalkbot) {
      return idle;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: locator<TtsClient>().isBusy,
      builder: (context, busy, _) {
        if (!busy) return idle;
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? MyColors.primary,
            ),
          ),
        );
      },
    );
  }
}
