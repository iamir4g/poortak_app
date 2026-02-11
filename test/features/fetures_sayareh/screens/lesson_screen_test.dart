import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/bloc/connectivity_cubit/connectivity_cubit.dart';
import 'package:poortak/common/bloc/video_download_cubit/video_download_cubit.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/video_download_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/course_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';

// Mocks
class MockLessonBloc extends Mock implements LessonBloc {}

class MockVideoDownloadCubit extends Mock implements VideoDownloadCubit {}

class MockVideoDownloadService extends Mock implements VideoDownloadService {}

class MockIknowAccessBloc extends Mock implements IknowAccessBloc {}

class MockPrefsOperator extends Mock implements PrefsOperator {}

class MockStorageService extends Mock implements StorageService {}

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

// Fakes - using concrete implementations for sealed classes
// LessonEvent and LessonState are sealed, so we use concrete instances.
class FakeVideoDownloadState extends Fake implements VideoDownloadState {}

// --- Http Mocking ---
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

// --- Mock Data Helpers ---

final mockLesson = Lesson(
  id: "123",
  name: "درس آزمایشی",
  description: "این یک درس آزمایشی است که شامل مکالمه، واژگان و آزمون می‌باشد.",
  thumbnail: "https://example.com/thumbnail.jpg",
  price: "1000",
  purchased: false,
  trailerVideo: "trailer_key",
  video: "video_key",
  isDemo: false,
  order: 1,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  publishedAt: DateTime.now(),
);

final mockCourseProgress = CourseProgressData(
  id: "progress_123",
  iKnowCourseId: "123",
  userId: "user_1",
  vocabulary: 50,
  conversation: 30,
  quiz: 80,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final mockCompletedCourseProgress = CourseProgressData(
  id: "progress_123_completed",
  iKnowCourseId: "123",
  userId: "user_1",
  vocabulary: 100,
  conversation: 100,
  quiz: 100,
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

    // Setup HttpOverrides
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
      // 1x1 transparent GIF
      onData([
        0x47,
        0x49,
        0x46,
        0x38,
        0x39,
        0x61,
        0x01,
        0x00,
        0x01,
        0x00,
        0x80,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xFF,
        0xFF,
        0xFF,
        0x21,
        0xF9,
        0x04,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x2C,
        0x00,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x01,
        0x00,
        0x00,
        0x02,
        0x02,
        0x44,
        0x01,
        0x00,
        0x3B
      ]);
      onDone?.call();
      return Stream<List<int>>.empty().listen((_) {});
    });

    // Reset GetIt
    await getIt.reset();

    // Register Mocks
    getIt.registerSingleton<VideoDownloadService>(mockVideoDownloadService);
    getIt.registerSingleton<VideoDownloadCubit>(mockVideoDownloadCubit);
    getIt.registerSingleton<IknowAccessBloc>(mockIknowAccessBloc);
    getIt.registerSingleton<PrefsOperator>(mockPrefsOperator);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<ConnectivityCubit>(mockConnectivityCubit);

    // Default Behaviors
    when(() => mockLessonBloc.state).thenReturn(LessonInitial());
    when(() => mockLessonBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLessonBloc.add(any())).thenReturn(null);
    when(() => mockLessonBloc.close()).thenAnswer((_) async {});

    when(() => mockVideoDownloadCubit.state).thenReturn(VideoDownloadInitial());
    when(() => mockVideoDownloadCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockVideoDownloadCubit.getDownloadInfo(any())).thenReturn(null);

    when(() => mockIknowAccessBloc.hasCourseAccess(any())).thenReturn(false);

    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(true);

    when(() => mockStorageService.callGetDownloadPublicUrl(any()))
        .thenAnswer((_) async => "http://example.com/image.jpg");

    when(() => mockVideoDownloadService.checkAndDownloadVideo(
          videoName: any(named: 'videoName'),
          lessonId: any(named: 'lessonId'),
          hasAccess: any(named: 'hasAccess'),
          isEncrypted: any(named: 'isEncrypted'),
          usePublicUrl: any(named: 'usePublicUrl'),
          videoKey: any(named: 'videoKey'),
        )).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
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
          BlocProvider<VideoDownloadCubit>.value(value: mockVideoDownloadCubit),
          BlocProvider<IknowAccessBloc>.value(value: mockIknowAccessBloc),
        ],
        child: const LessonScreen(
          index: 0,
          title: "درس آزمایشی",
          lessonId: "123",
          purchased: false,
        ),
      ),
    );
  }

  testWidgets('درخواست دریافت درس در هنگام باز شدن صفحه', (tester) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    verify(() => mockLessonBloc.add(any(that: isA<GetLessonEvenet>())))
        .called(1);
  });

  testWidgets('نمایش اطلاعات درس پس از دریافت موفقیت‌آمیز', (tester) async {
    // Arrange
    final successState =
        LessonSuccess(lesson: mockLesson, progress: mockCourseProgress);

    when(() => mockLessonBloc.state).thenReturn(LessonInitial());
    when(() => mockLessonBloc.stream)
        .thenAnswer((_) => Stream.fromIterable([successState]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Process initial build
    await tester.pump(); // Process stream emission
    await tester
        .pump(const Duration(milliseconds: 500)); // Process image loading

    // Assert
    expect(find.text("درس آزمایشی"), findsWidgets);
    expect(find.text("مکالمه"), findsOneWidget);
    expect(find.text("واژگان"), findsOneWidget);
    expect(find.text("آزمون"), findsOneWidget);
    expect(find.text("%50"), findsOneWidget); // Vocabulary progress
    expect(find.text("%30"), findsOneWidget); // Conversation progress
    expect(find.text("%80"), findsOneWidget); // Quiz progress
  });

  testWidgets('نمایش پاپ‌آپ تبریک پس از اتمام درس', (tester) async {
    // Arrange
    // Initial state: not completed
    final initialState =
        LessonSuccess(lesson: mockLesson, progress: mockCourseProgress);

    // Final state: completed
    final completedState = LessonSuccess(
        lesson: mockLesson, progress: mockCompletedCourseProgress);

    when(() => mockLessonBloc.state).thenReturn(initialState);
    when(() => mockLessonBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([initialState, completedState]),
    );

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Initial build
    await tester.pump(); // Emit first state
    await tester.pump(); // Emit second state
    await tester.pumpAndSettle(); // Wait for dialog animation

    // Assert
    expect(find.text('تبریک!'), findsOneWidget);
    expect(find.text('شما این درس را با موفقیت به پایان رساندید.'),
        findsOneWidget);
  });

  testWidgets('نمایش خطا در صورت بروز مشکل', (tester) async {
    // Arrange
    const errorMessage = "خطا در دریافت اطلاعات";

    // Simulate error state
    // For BlocBuilder to rebuild, we need to emit the state or have it as current state
    // Since LessonScreen uses BlocListener for error showing (SnackBar), we need to stream it.

    when(() => mockLessonBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([LessonError(message: errorMessage)]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger listener

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });
}
