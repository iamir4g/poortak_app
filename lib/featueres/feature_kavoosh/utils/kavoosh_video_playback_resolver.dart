import 'package:poortak/featueres/feature_kavoosh/data/models/video_course_detail_model.dart';

class KavooshVideoPlaybackTarget {
  final String videoId;
  final String lessonId;
  final String courseId;
  final bool usePublicUrl;
  final bool isEncrypted;

  const KavooshVideoPlaybackTarget({
    required this.videoId,
    required this.lessonId,
    required this.courseId,
    required this.usePublicUrl,
    required this.isEncrypted,
  });
}

class KavooshVideoPlaybackResolver {
  const KavooshVideoPlaybackResolver._();

  static bool hasFullCourseAccess({
    required bool purchasedFromApi,
    required bool hasAccessFromApi,
  }) {
    return purchasedFromApi || hasAccessFromApi;
  }

  static bool canPlayLesson({
    required VideoCourseLesson lesson,
    required VideoCourseInfo course,
  }) {
    if (lesson.isFree) return true;
    return hasFullCourseAccess(
      purchasedFromApi: course.purchased,
      hasAccessFromApi: course.hasAccess,
    );
  }

  static KavooshVideoPlaybackTarget? resolve({
    required VideoCourseLesson lesson,
    required VideoCourseInfo course,
  }) {
    final fileId = lesson.fileId?.trim() ?? '';
    if (fileId.isEmpty) return null;

    if (!canPlayLesson(lesson: lesson, course: course)) {
      return null;
    }

    if (lesson.isFree) {
      return KavooshVideoPlaybackTarget(
        videoId: fileId,
        lessonId: lesson.id,
        courseId: course.id,
        usePublicUrl: true,
        isEncrypted: false,
      );
    }

    return KavooshVideoPlaybackTarget(
      videoId: fileId,
      lessonId: lesson.id,
      courseId: course.id,
      usePublicUrl: false,
      isEncrypted: true,
    );
  }
}
