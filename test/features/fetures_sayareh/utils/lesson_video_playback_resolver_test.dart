import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/utils/lesson_video_playback_resolver.dart';

void main() {
  const lessonId = 'bed262ab-3b12-49d6-9613-52ec4737327c';
  const trailerId = 'b7637ac5-e981-40f4-b642-2a58a3db5582';
  const mainVideoId = '955b4085-ec59-4e50-b863-4af9794f1a4c';

  final lessonWithTrailer = Lesson(
    id: lessonId,
    name: 'درس اول',
    description: 'پورتک به سیاره آی نو می‌رود.',
    thumbnail: '2c4d4e04-24d2-498b-aa12-784288ada3ae',
    price: '850000',
    purchased: false,
    trailerVideo: trailerId,
    video: mainVideoId,
    isDemo: true,
    order: 0,
    createdAt: DateTime.parse('2026-05-17T11:39:42.506Z'),
    updatedAt: DateTime.parse('2026-05-17T11:39:42.506Z'),
    publishedAt: DateTime.parse('2026-05-17T11:39:47.165Z'),
  );

  final lessonWithoutTrailer = Lesson(
    id: '0e790245-215c-412e-902e-d06dd1ea483e',
    name: 'درس دوم',
    description: 'بدون تریلر',
    thumbnail: 'thumb',
    price: '850000',
    purchased: false,
    trailerVideo: '',
    video: mainVideoId,
    isDemo: false,
    order: 1,
    createdAt: DateTime.parse('2026-05-17T13:45:02.824Z'),
    updatedAt: DateTime.parse('2026-05-17T13:45:02.824Z'),
    publishedAt: DateTime.parse('2026-05-17T13:45:10.139Z'),
  );

  group('LessonVideoPlaybackResolver.hasFullVideoAccess', () {
    test('بدون لاگین هیچ‌وقت دسترسی کامل ندارد', () {
      expect(
        LessonVideoPlaybackResolver.hasFullVideoAccess(
          isLoggedIn: false,
          purchasedFromRoute: true,
          hasCourseAccess: true,
        ),
        isFalse,
      );
    });

    test('با لاگین و purchasedFromRoute دسترسی کامل دارد', () {
      expect(
        LessonVideoPlaybackResolver.hasFullVideoAccess(
          isLoggedIn: true,
          purchasedFromRoute: true,
          hasCourseAccess: false,
        ),
        isTrue,
      );
    });

    test('با لاگین و hasCourseAccess دسترسی کامل دارد', () {
      expect(
        LessonVideoPlaybackResolver.hasFullVideoAccess(
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: true,
        ),
        isTrue,
      );
    });

    test('با لاگین ولی بدون خرید دسترسی کامل ندارد', () {
      expect(
        LessonVideoPlaybackResolver.hasFullVideoAccess(
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        isFalse,
      );
    });
  });

  group('LessonVideoPlaybackResolver.resolve', () {
    test('بدون لاگین: تریلر از storage/public', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithTrailer,
          isLoggedIn: false,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        const LessonVideoPlaybackTarget(
          videoId: trailerId,
          usePublicUrl: true,
          isEncrypted: false,
        ),
      );
    });

    test('بدون لاگین حتی با purchasedFromRoute: باز هم تریلر', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithTrailer,
          isLoggedIn: false,
          purchasedFromRoute: true,
          hasCourseAccess: true,
        ),
        const LessonVideoPlaybackTarget(
          videoId: trailerId,
          usePublicUrl: true,
          isEncrypted: false,
        ),
      );
    });

    test('با لاگین و بدون خرید: تریلر از storage/public', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithTrailer,
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        const LessonVideoPlaybackTarget(
          videoId: trailerId,
          usePublicUrl: true,
          isEncrypted: false,
        ),
      );
    });

    test('با لاگین و خرید از route: ویدیو اصلی رمزنگاری‌شده', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithTrailer,
          isLoggedIn: true,
          purchasedFromRoute: true,
          hasCourseAccess: false,
        ),
        const LessonVideoPlaybackTarget(
          videoId: mainVideoId,
          usePublicUrl: false,
          isEncrypted: true,
        ),
      );
    });

    test('با لاگین و دسترسی iknow: ویدیو اصلی رمزنگاری‌شده', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithTrailer,
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: true,
        ),
        const LessonVideoPlaybackTarget(
          videoId: mainVideoId,
          usePublicUrl: false,
          isEncrypted: true,
        ),
      );
    });

    test('بدون دسترسی و بدون تریلر: null', () {
      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonWithoutTrailer,
          isLoggedIn: false,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        isNull,
      );
    });

    test('trailerVideo با null از API به‌درستی parse و resolve می‌شود', () {
      final lessonFromJson = Lesson.fromJson({
        'id': lessonId,
        'name': 'درس اول',
        'description': 'desc',
        'thumbnail': 'thumb',
        'price': '850000',
        'video': mainVideoId,
        'trailerVideo': null,
        'isDemo': true,
        'order': 0,
        'createdAt': '2026-05-17T11:39:42.506Z',
        'updatedAt': '2026-05-17T11:39:42.506Z',
        'publishedAt': '2026-05-17T11:39:47.165Z',
      });

      expect(
        LessonVideoPlaybackResolver.resolve(
          lesson: lessonFromJson,
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        isNull,
      );
    });
  });

  group('LessonVideoPlaybackResolver.mainVideoIdToCancelWhenPreviewing', () {
    test('در حالت تریلر، ویدیو اصلی برای cancel برمی‌گردد', () {
      expect(
        LessonVideoPlaybackResolver.mainVideoIdToCancelWhenPreviewing(
          lesson: lessonWithTrailer,
          isLoggedIn: false,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        mainVideoId,
      );
    });

    test('در حالت خرید، ویدیویی برای cancel برنمی‌گردد', () {
      expect(
        LessonVideoPlaybackResolver.mainVideoIdToCancelWhenPreviewing(
          lesson: lessonWithTrailer,
          isLoggedIn: true,
          purchasedFromRoute: true,
          hasCourseAccess: false,
        ),
        isNull,
      );
    });
  });

  group('LessonVideoPlaybackResolver purchase dialog after trailer', () {
    test('بعد از تریلر بدون دسترسی: پاپ‌آپ خرید', () {
      expect(
        LessonVideoPlaybackResolver.shouldShowPurchaseDialogAfterVideo(
          lesson: lessonWithTrailer,
          currentVideoId: trailerId,
          isLoggedIn: false,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        isTrue,
      );
    });

    test('بعد از ویدیو اصلی با دسترسی: بدون پاپ‌آپ خرید', () {
      expect(
        LessonVideoPlaybackResolver.shouldShowPurchaseDialogAfterVideo(
          lesson: lessonWithTrailer,
          currentVideoId: mainVideoId,
          isLoggedIn: true,
          purchasedFromRoute: true,
          hasCourseAccess: false,
        ),
        isFalse,
      );
    });

    test('بعد از تریلر با لاگین ولی بدون خرید: پاپ‌آپ خرید', () {
      expect(
        LessonVideoPlaybackResolver.shouldShowPurchaseDialogAfterVideo(
          lesson: lessonWithTrailer,
          currentVideoId: trailerId,
          isLoggedIn: true,
          purchasedFromRoute: false,
          hasCourseAccess: false,
        ),
        isTrue,
      );
    });
  });
}
