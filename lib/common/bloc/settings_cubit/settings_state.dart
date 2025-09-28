part of 'settings_cubit.dart';

class SettingsState {
  final bool fullScreenMode;
  final bool achievementNotifications;
  final bool generalNotifications;
  final bool autoPlayPronunciation;
  final bool autoPlayExerciseSounds;
  final bool playSoundEffects;
  final double textSize;

  const SettingsState({
    this.fullScreenMode = false,
    this.achievementNotifications = true,
    this.generalNotifications = true,
    this.autoPlayPronunciation = true,
    this.autoPlayExerciseSounds = true,
    this.playSoundEffects = true,
    this.textSize = 0.67,
  });

  SettingsState copyWith({
    bool? fullScreenMode,
    bool? achievementNotifications,
    bool? generalNotifications,
    bool? autoPlayPronunciation,
    bool? autoPlayExerciseSounds,
    bool? playSoundEffects,
    double? textSize,
  }) {
    return SettingsState(
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
      generalNotifications: generalNotifications ?? this.generalNotifications,
      autoPlayPronunciation: autoPlayPronunciation ?? this.autoPlayPronunciation,
      autoPlayExerciseSounds: autoPlayExerciseSounds ?? this.autoPlayExerciseSounds,
      playSoundEffects: playSoundEffects ?? this.playSoundEffects,
      textSize: textSize ?? this.textSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.fullScreenMode == fullScreenMode &&
        other.achievementNotifications == achievementNotifications &&
        other.generalNotifications == generalNotifications &&
        other.autoPlayPronunciation == autoPlayPronunciation &&
        other.autoPlayExerciseSounds == autoPlayExerciseSounds &&
        other.playSoundEffects == playSoundEffects &&
        other.textSize == textSize;
  }

  @override
  int get hashCode {
    return fullScreenMode.hashCode ^
        achievementNotifications.hashCode ^
        generalNotifications.hashCode ^
        autoPlayPronunciation.hashCode ^
        autoPlayExerciseSounds.hashCode ^
        playSoundEffects.hashCode ^
        textSize.hashCode;
  }
}
