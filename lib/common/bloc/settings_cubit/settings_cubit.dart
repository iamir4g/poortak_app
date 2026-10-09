import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poortak/common/utils/system_ui_helper.dart';
import 'package:poortak/locator.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs = locator<SharedPreferences>();

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final fullScreenMode = _prefs.getBool('fullScreenMode') ?? false;
    final autoPlayExerciseSounds = _prefs.getBool('autoPlayExerciseSounds') ?? true;
    final playSoundEffects = _prefs.getBool('playSoundEffects') ?? true;
    final textSize = _prefs.getDouble('textSize') ?? 0.67;

    // Notifications and auto pronunciation are "coming soon" and always off.
    emit(SettingsState(
      fullScreenMode: fullScreenMode,
      achievementNotifications: false,
      generalNotifications: false,
      autoPlayPronunciation: false,
      autoPlayExerciseSounds: autoPlayExerciseSounds,
      playSoundEffects: playSoundEffects,
      textSize: textSize,
    ));
  }

  void updateFullScreenMode(bool value) {
    _prefs.setBool('fullScreenMode', value);
    emit(state.copyWith(fullScreenMode: value));
    applyAppSystemUiMode();
  }

  void updateAchievementNotifications(bool value) {
    _prefs.setBool('achievementNotifications', value);
    emit(state.copyWith(achievementNotifications: value));
  }

  void updateGeneralNotifications(bool value) {
    _prefs.setBool('generalNotifications', value);
    emit(state.copyWith(generalNotifications: value));
  }

  void updateAutoPlayPronunciation(bool value) {
    _prefs.setBool('autoPlayPronunciation', value);
    emit(state.copyWith(autoPlayPronunciation: value));
  }

  void updateAutoPlayExerciseSounds(bool value) {
    _prefs.setBool('autoPlayExerciseSounds', value);
    emit(state.copyWith(autoPlayExerciseSounds: value));
  }

  void updatePlaySoundEffects(bool value) {
    _prefs.setBool('playSoundEffects', value);
    emit(state.copyWith(playSoundEffects: value));
  }

  void updateTextSize(double value) {
    _prefs.setDouble('textSize', value);
    emit(state.copyWith(textSize: value));
  }

  // محاسبه اندازه فونت بر اساس تنظیمات
  double getCalculatedFontSize(double baseFontSize) {
    // حداقل 0.8 و حداکثر 1.4 برابر اندازه اصلی
    return baseFontSize * (0.8 + (state.textSize * 0.6));
  }
}
