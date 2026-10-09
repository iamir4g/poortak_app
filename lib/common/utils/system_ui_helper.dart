import 'package:flutter/services.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/locator.dart';

/// Applies the app-wide system UI mode based on the full-screen setting.
/// In full-screen mode only the Android navigation bar (back/home/recent)
/// is hidden; the status bar (clock, battery) stays visible.
Future<void> applyAppSystemUiMode() {
  final fullScreen = locator.isRegistered<SettingsCubit>() &&
      locator<SettingsCubit>().state.fullScreenMode;
  if (fullScreen) {
    return SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
  return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
