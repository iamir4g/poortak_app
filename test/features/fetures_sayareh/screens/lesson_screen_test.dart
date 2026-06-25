import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/bloc/connectivity_cubit/connectivity_cubit.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/video_download_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/course_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/main.dart' show routeObserver;

class MockLessonBloc extends Mock implements LessonBloc {}

class MockVideoDownloadCubit extends Mock implements VideoDownloadCubit {}

class MockVideoDownloadService extends Mock implements VideoDownloadService {}

class MockIknowAccessBloc extends Mock implements IknowAccessBloc {}

class MockPrefsOperator extends Mock implements PrefsOperator {}

class MockStorageService extends Mock implements StorageService {}

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

class FakeVideoDownloadState extends Fake implements VideoDownloadState {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class TestHttpOverrides extends HttpOverrides {
  final HttpClient client;
  TestHttpOverrides(this.client);

  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

const trailerId = 'b7637ac5-e981-40f4-b642-2a58a3db5582';
const mainVideoId = '955b4085-ec59-4e50-b863-4af9794f1a4c';
const lessonId = 'bed262ab-3b12-49d6-9613-52ec4737327c';

final mockLesson = Lesson(
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

final mockCourseProgress = CourseProgressData(
  id: 'progress_123',
  iKnowCourseId: lessonId,
  userId: 'user_1',
  vocabulary: 50,
  conversation: 30,
  quiz: 80,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

void main() {
  late MockLessonBloc mockLessonBloc;
  late MockVideoDownloadCubit mockVideoDownloadCubit;
  late MockVideoDownloadService mockVideoDownloadService;
  late MockIknowAccessBloc mockIknowAccessBloc;
  late MockPrefsOperator mockPrefsOperator;
  late MockStorageService mockStorageService;
  late MockConnectivityCubit mockConnectivityCubit;
  late MockHttpClient mockHttpClient;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(const GetLessonEvenet(id: 'fallback'));
    registerFallbackValue(LessonInitial());
    registerFallbackValue(VideoDownloadInitial());
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() async {
    mockLessonBloc = MockLessonBloc();
    mockVideoDownloadCubit = MockVideoDownloadCubit();
    mockVideoDownloadService = MockVideoDownloadService();
    mockIknowAccessBloc = MockIknowAccessBloc();
    mockPrefsOperator = MockPrefsOperator();
    mockStorageService = MockStorageService();
    mockConnectivityCubit = MockConnectivityCubit();
    mockHttpClient = MockHttpClient();

    HttpOverrides.global = TestHttpOverrides(mockHttpClient);
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();
    final mockHeaders = MockHttpHeaders();

    when(() => mockHttpClient.getUrl(any()))
        .thenAnswer((_) async => mockRequest);
    when(() => mockRequest.headers).thenReturn(mockHeaders);
    when(() => mockRequest.close()).thenAnswer((_) async => mockResponse);
    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.contentLength).thenReturn(0);
    when(() => mockResponse.compressionState)
        .thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(() => mockResponse.listen(any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'))).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      onData([0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x3B]);
      onDone?.call();
      return Stream<List<int>>.empty().listen((_) {});
    });

    await getIt.reset();

    getIt.registerSingleton<VideoDownloadService>(mockVideoDownloadService);
    getIt.registerSingleton<VideoDownloadCubit>(mockVideoDownloadCubit);
    getIt.registerSingleton<IknowAccessBloc>(mockIknowAccessBloc);
    getIt.registerSingleton<PrefsOperator>(mockPrefsOperator);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<ConnectivityCubit>(mockConnectivityCubit);

    when(() => mockLessonBloc.state).thenReturn(LessonInitial());
    when(() => mockLessonBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLessonBloc.add(any())).thenReturn(null);
    when(() => mockLessonBloc.close()).thenAnswer((_) async {});

    when(() => mockVideoDownloadCubit.state).thenReturn(VideoDownloadInitial());
    when(() => mockVideoDownloadCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockVideoDownloadCubit.getDownloadInfo(any())).thenReturn(null);

    when(() => mockIknowAccessBloc.hasCourseAccess(any())).thenReturn(false);
    when(() => mockIknowAccessBloc.state).thenReturn(IknowAccessInitial());
    when(() => mockIknowAccessBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockStorageService.callGetDownloadPublicUrl(any()))
        .thenAnswer((_) async => 'http://example.com/public-file');

    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(false);

    when(() => mockVideoDownloadService.checkAndDownloadVideo(
          videoName: any(named: 'videoName'),
          lessonId: any(named: 'lessonId'),
          hasAccess: any(named: 'hasAccess'),
          isEncrypted: any(named: 'isEncrypted'),
          usePublicUrl: any(named: 'usePublicUrl'),
          videoKey: any(named: 'videoKey'),
          autoStart: any(named: 'autoStart'),
        )).thenAnswer((_) async {});

    when(() => mockVideoDownloadService.cancelDownload(any()))
        .thenReturn(null);
  });

  Widget createWidgetUnderTest({bool purchased = false}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) {
        return MaterialApp(
          navigatorObservers: [routeObserver],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fa'),
            Locale('en'),
          ],
          locale: const Locale('fa'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<LessonBloc>.value(value: mockLessonBloc),
              BlocProvider<VideoDownloadCubit>.value(
                  value: mockVideoDownloadCubit),
              BlocProvider<IknowAccessBloc>.value(value: mockIknowAccessBloc),
            ],
            child: LessonScreen(
              index: 0,
              title: 'درس اول',
              lessonId: lessonId,
              purchased: purchased,
            ),
          ),
        );
      },
    );
  }

  Future<void> pumpLessonSuccess(WidgetTester tester, {bool purchased = false}) async {
    final successState =
        LessonSuccess(lesson: mockLesson, progress: mockCourseProgress);

    when(() => mockLessonBloc.state).thenReturn(LessonInitial());
    when(() => mockLessonBloc.stream)
        .thenAnswer((_) => Stream.fromIterable([successState]));

    await tester.pumpWidget(createWidgetUnderTest(purchased: purchased));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    tester.takeException();
  }

  group('LessonScreen video download integration', () {
    testWidgets('بدون لاگین: تریلر از storage/public دانلود می‌شود', (tester) async {
      when(() => mockPrefsOperator.isLoggedIn()).thenReturn(false);

      await pumpLessonSuccess(tester);

      verify(() => mockVideoDownloadService.cancelDownload(mainVideoId));
      verify(() => mockVideoDownloadService.checkAndDownloadVideo(
            videoName: trailerId,
            lessonId: lessonId,
            hasAccess: false,
            isEncrypted: false,
            usePublicUrl: true,
            videoKey: trailerId,
            autoStart: true,
          )).called(1);
      verifyNever(() => mockVideoDownloadService.checkAndDownloadVideo(
            videoName: mainVideoId,
            lessonId: any(named: 'lessonId'),
            hasAccess: any(named: 'hasAccess'),
            isEncrypted: any(named: 'isEncrypted'),
            usePublicUrl: any(named: 'usePublicUrl'),
            videoKey: any(named: 'videoKey'),
            autoStart: any(named: 'autoStart'),
          ));
    });

    testWidgets('با لاگین و بدون خرید: تریلر از storage/public دانلود می‌شود',
        (tester) async {
      when(() => mockPrefsOperator.isLoggedIn()).thenReturn(true);
      when(() => mockIknowAccessBloc.hasCourseAccess(lessonId)).thenReturn(false);

      await pumpLessonSuccess(tester);

      verify(() => mockVideoDownloadService.checkAndDownloadVideo(
            videoName: trailerId,
            lessonId: lessonId,
            hasAccess: false,
            isEncrypted: false,
            usePublicUrl: true,
            videoKey: trailerId,
            autoStart: true,
          )).called(1);
    });

    testWidgets('با لاگین و خرید: ویدیو اصلی رمزنگاری‌شده دانلود می‌شود',
        (tester) async {
      when(() => mockPrefsOperator.isLoggedIn()).thenReturn(true);

      await pumpLessonSuccess(tester, purchased: true);

      verifyNever(() => mockVideoDownloadService.cancelDownload(mainVideoId));
      verify(() => mockVideoDownloadService.checkAndDownloadVideo(
            videoName: mainVideoId,
            lessonId: lessonId,
            hasAccess: true,
            isEncrypted: true,
            usePublicUrl: false,
            videoKey: mainVideoId,
            autoStart: false,
          )).called(1);
      verifyNever(() => mockVideoDownloadService.checkAndDownloadVideo(
            videoName: trailerId,
            lessonId: any(named: 'lessonId'),
            hasAccess: any(named: 'hasAccess'),
            isEncrypted: any(named: 'isEncrypted'),
            usePublicUrl: any(named: 'usePublicUrl'),
            videoKey: any(named: 'videoKey'),
            autoStart: any(named: 'autoStart'),
          ));
    });
  });

  testWidgets('درخواست دریافت درس در هنگام باز شدن صفحه', (tester) async {
    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    verify(() => mockLessonBloc.add(any(that: isA<GetLessonEvenet>())))
        .called(1);
  });

  testWidgets('نمایش پاپ‌آپ تبریک پس از اتمام درس', (tester) async {
    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(false);

    final initialState =
        LessonSuccess(lesson: mockLesson, progress: mockCourseProgress);
    final completedState = CourseProgressData(
      id: 'progress_completed',
      iKnowCourseId: lessonId,
      userId: 'user_1',
      vocabulary: 100,
      conversation: 100,
      quiz: 100,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final completedLessonState = LessonSuccess(
      lesson: mockLesson,
      progress: completedState,
    );

    when(() => mockLessonBloc.state).thenReturn(initialState);
    when(() => mockLessonBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([initialState, completedLessonState]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('تبریک!'), findsOneWidget);
    expect(find.text('شما این درس را با موفقیت به پایان رساندید.'),
        findsOneWidget);
  });

  testWidgets('نمایش خطا در صورت بروز مشکل', (tester) async {
    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(false);
    const errorMessage = 'خطا در دریافت اطلاعات';

    when(() => mockLessonBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([LessonError(message: errorMessage)]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text(errorMessage), findsOneWidget);
  });
}
