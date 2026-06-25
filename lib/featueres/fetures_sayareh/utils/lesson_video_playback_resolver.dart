import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';

class LessonVideoPlaybackTarget {
  final String videoId;
  final bool usePublicUrl;
  final bool isEncrypted;

  const LessonVideoPlaybackTarget({
    required this.videoId,
    required this.usePublicUrl,
    required this.isEncrypted,
  });

  @override
  bool operator ==(Object other) {
    return other is LessonVideoPlaybackTarget &&
        other.videoId == videoId &&
        other.usePublicUrl == usePublicUrl &&
        other.isEncrypted == isEncrypted;
  }

  @override
  int get hashCode => Object.hash(videoId, usePublicUrl, isEncrypted);
}

class LessonVideoPlaybackResolver {
  const LessonVideoPlaybackResolver._();

  static bool hasFullVideoAccess({
    required bool isLoggedIn,
    required bool purchasedFromRoute,
    required bool hasCourseAccess,
  }) {
    if (!isLoggedIn) return false;
    if (purchasedFromRoute) return true;
    return hasCourseAccess;
  }

  static LessonVideoPlaybackTarget? resolve({
    required Lesson lesson,
    required bool isLoggedIn,
    required bool purchasedFromRoute,
    required bool hasCourseAccess,
  }) {
    final trailerId = lesson.trailerVideo.trim();
    final mainVideoId = (lesson.video ?? '').trim();
    final hasAccess = hasFullVideoAccess(
      isLoggedIn: isLoggedIn,
      purchasedFromRoute: purchasedFromRoute,
      hasCourseAccess: hasCourseAccess,
    );

    if (!hasAccess) {
      if (trailerId.isEmpty) return null;
      return LessonVideoPlaybackTarget(
        videoId: trailerId,
        usePublicUrl: true,
        isEncrypted: false,
      );
    }

    if (mainVideoId.isEmpty) return null;
    return LessonVideoPlaybackTarget(
      videoId: mainVideoId,
      usePublicUrl: false,
      isEncrypted: true,
    );
  }

  static String? mainVideoIdToCancelWhenPreviewing({
    required Lesson lesson,
    required bool isLoggedIn,
    required bool purchasedFromRoute,
    required bool hasCourseAccess,
  }) {
    if (hasFullVideoAccess(
      isLoggedIn: isLoggedIn,
      purchasedFromRoute: purchasedFromRoute,
      hasCourseAccess: hasCourseAccess,
    )) {
      return null;
    }

    final mainVideoId = (lesson.video ?? '').trim();
    return mainVideoId.isEmpty ? null : mainVideoId;
  }

  static bool isPlayingTrailer({
    required Lesson lesson,
    required String? currentVideoId,
  }) {
    final trailerId = lesson.trailerVideo.trim();
    if (trailerId.isEmpty || currentVideoId == null) return false;
    return currentVideoId == trailerId;
  }

  static bool shouldShowPurchaseDialogAfterVideo({
    required Lesson lesson,
    required String? currentVideoId,
    required bool isLoggedIn,
    required bool purchasedFromRoute,
    required bool hasCourseAccess,
  }) {
    if (hasFullVideoAccess(
      isLoggedIn: isLoggedIn,
      purchasedFromRoute: purchasedFromRoute,
      hasCourseAccess: hasCourseAccess,
    )) {
      return false;
    }

    return isPlayingTrailer(
      lesson: lesson,
      currentVideoId: currentVideoId,
    );
  }
}
