import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poortak/locator.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs = locator<SharedPreferences>();

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final fullScreenMode = _prefs.getBool('fullScreenMode') ?? false;
    final achievementNotifications = _prefs.getBool('achievementNotifications') ?? true;
    final generalNotifications = _prefs.getBool('generalNotifications') ?? true;
    final autoPlayPronunciation = _prefs.getBool('autoPlayPronunciation') ?? true;
    final autoPlayExerciseSounds = _prefs.getBool('autoPlayExerciseSounds') ?? true;
    final playSoundEffects = _prefs.getBool('playSoundEffects') ?? true;
    final textSize = _prefs.getDouble('textSize') ?? 0.67;

    emit(SettingsState(
      fullScreenMode: fullScreenMode,
      achievementNotifications: achievementNotifications,
      generalNotifications: generalNotifications,
      autoPlayPronunciation: autoPlayPronunciation,
      autoPlayExerciseSounds: autoPlayExerciseSounds,
      playSoundEffects: playSoundEffects,
      textSize: textSize,
    ));
  }

  void updateFullScreenMode(bool value) {
    _prefs.setBool('fullScreenMode', value);
    emit(state.copyWith(fullScreenMode: value));
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
