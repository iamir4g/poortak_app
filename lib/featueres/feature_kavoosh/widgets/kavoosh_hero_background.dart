import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/config/myColors.dart';

class KavooshHeroBackground extends StatelessWidget {
  final String? backgroundImageId;

  const KavooshHeroBackground({
    super.key,
    this.backgroundImageId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackColor =
        isDark ? MyColors.darkBackgroundSecondary : const Color(0xFFF9F6C6);
    final backgroundId = backgroundImageId;

    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: backgroundId == null || backgroundId.isEmpty
          ? ColoredBox(color: fallbackColor)
          : FutureBuilder<String>(
              future: GetImageUrlService().getImageUrl(backgroundId),
              builder: (context, snapshot) {
                final url = snapshot.data;
                if (url == null || url.isEmpty) {
                  return ColoredBox(color: fallbackColor);
                }
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.h,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: fallbackColor),
                );
              },
            ),
    );
  }
}
