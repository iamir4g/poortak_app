import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_litner/data/models/create_word_model.dart'
    as create_word_model;
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/vocabulary_model.dart'
    as vocabulary_model;
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';

// Mocks
class MockSayarehRepository extends Mock implements SayarehRepository {}

class MockLitnerBloc extends Mock implements LitnerBloc {}

class MockTTSService extends Mock implements TTSService {}

class MockStorageService extends Mock implements StorageService {}

class MockPrefsOperator extends Mock implements PrefsOperator {}

// Fakes
class FakeLitnerEvent extends Fake implements LitnerEvent {}

class FakeLitnerState extends Fake implements LitnerState {}

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

// --- Mock Data ---
final mockVocabularyList = [
  vocabulary_model.Vocabulary(
    id: "1",
    word: "Hello",
    translation: "سلام",
    thumbnail: "thumb1",
    order: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    disabledAt: null,
    courseId: "course1",
  ),
  vocabulary_model.Vocabulary(
    id: "2",
    word: "World",
    translation: "جهان",
    thumbnail: "thumb2",
    order: 2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    disabledAt: null,
    courseId: "course1",
  ),
];

final mockVocabularyModel = vocabulary_model.VocabularyModel(
  ok: true,
  meta: vocabulary_model.Meta(),
  data: mockVocabularyList,
);

final mockCreateWordModel = create_word_model.CreateWord(
  ok: true,
  meta: create_word_model.Meta(),
  data: create_word_model.Data(
    id: "word1",
    userId: "user1",
    boxLevel: 1,
    nextReview: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    word: "Hello",
    translation: "سلام",
  ),
);

void main() {
  late MockSayarehRepository mockSayarehRepository;
  late MockLitnerBloc mockLitnerBloc;
  late MockTTSService mockTTSService;
  late MockStorageService mockStorageService;
  late MockPrefsOperator mockPrefsOperator;
  late MockHttpClient mockHttpClient;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeLitnerEvent());
    registerFallbackValue(FakeLitnerState());
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() async {
    mockSayarehRepository = MockSayarehRepository();
    mockLitnerBloc = MockLitnerBloc();
    mockTTSService = MockTTSService();
    mockStorageService = MockStorageService();
    mockPrefsOperator = MockPrefsOperator();
    mockHttpClient = MockHttpClient();

    // Reset GetIt
    await getIt.reset();

    // Register Mocks
    getIt.registerSingleton<SayarehRepository>(mockSayarehRepository);
    getIt.registerSingleton<TTSService>(mockTTSService);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<PrefsOperator>(mockPrefsOperator);

    // Setup default behaviors
    when(() => mockLitnerBloc.state).thenReturn(LitnerInitial());
    when(() => mockLitnerBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLitnerBloc.close()).thenAnswer((_) async {});
    when(() => mockPrefsOperator.getLoggedIn()).thenAnswer((_) async => true);
    when(() => mockStorageService.callGetDownloadPublicUrl(any()))
        .thenAnswer((_) async => "http://example.com/image.jpg");
    when(() => mockTTSService.speak(any())).thenAnswer((_) async {});

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
  });

  tearDown(() {
    // Reset window size
    // tester.view.resetPhysicalSize(); // Can't access tester here
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
      home: BlocProvider<LitnerBloc>.value(
        value: mockLitnerBloc,
        child: const VocabularyScreen(id: "course1"),
      ),
    );
  }

  testWidgets('نمایش لودینگ در ابتدای بارگذاری', (tester) async {
    // Set size
    // Set a very large screen size to avoid overflow
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
      return DataSuccess(mockVocabularyModel);
    });

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start fetching

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish the pending timer
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('نمایش کلمات پس از دریافت موفقیت‌آمیز و پخش خودکار TTS',
      (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(mockVocabularyModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data and images

    // Assert
    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("سلام"), findsOneWidget);

    // Verify TTS was called for the first word
    // Wait for the post frame callback
    await tester.pump(const Duration(milliseconds: 100));
    verify(() => mockTTSService.speak("Hello")).called(1);
  });

  testWidgets('پیمایش بین کلمات و پخش TTS برای کلمه جدید', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(mockVocabularyModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // Wait for initial TTS
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial state
    expect(find.text("Hello"), findsOneWidget);

    // Tap forward button by key
    await tester.tap(find.byKey(const Key('vocabulary_forward_button')));
    await tester.pump(); // trigger setState
    await tester.pump(const Duration(
        milliseconds: 500)); // wait for post frame callback (TTS)

    // Assert
    expect(find.text("World"), findsOneWidget);
    expect(find.text("جهان"), findsOneWidget);

    // Verify TTS was called for the second word
    verify(() => mockTTSService.speak("World")).called(1);
  });

  testWidgets('پخش TTS با کلیک روی دکمه صدا', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(mockVocabularyModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // Clear previous verify calls (from auto-play)
    clearInteractions(mockTTSService);

    // Find volume button (it's an IconButton containing IconifyIcon)
    // We can just find by IconifyIcon and tap it (since it's inside IconButton, tapping the icon taps the button)
    // Or find IconButton that contains IconifyIcon
    // Since IconifyIcon is not exported/imported easily, we can find by type if we import it, or just find by Type 'IconButton'
    // and filtering.
    // But earlier I found 5 IconButtons.
    // Let's use the row finder strategy.

    final controlsRow = find.ancestor(
      of: find.byIcon(Icons.add_circle_outline),
      matching: find.byType(Row),
    );

    // The volume button is the 3rd one in the row (Back, Add, Volume, Forward)
    // But find.descendant returns all matches in depth-first order.
    // Inside the row:
    // 1. IconButton(arrow_back)
    // 2. BlocBuilder -> IconButton(add)
    // 3. IconButton(IconifyIcon)
    // 4. IconButton(arrow_forward)

    // We can find all IconButtons inside controlsRow.
    final buttons =
        find.descendant(of: controlsRow, matching: find.byType(IconButton));
    // Index 0: Back
    // Index 1: Add
    // Index 2: Volume
    // Index 3: Forward

    await tester.tap(buttons.at(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // Wait for async

    // Assert
    verify(() => mockTTSService.speak("Hello")).called(1);
  });

  testWidgets('افزودن کلمه به لایتنر', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(mockVocabularyModel));

    when(() => mockLitnerBloc.add(any())).thenReturn(null);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // Find add button
    final controlsRow = find.ancestor(
      of: find.byIcon(Icons.add_circle_outline),
      matching: find.byType(Row),
    );
    final buttons =
        find.descendant(of: controlsRow, matching: find.byType(IconButton));
    // Index 1 is Add button

    await tester.tap(buttons.at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // Wait for async

    // Assert
    verify(() => mockLitnerBloc.add(any(that: isA<CreateWordEvent>())))
        .called(1);
  });

  testWidgets('نمایش پیام موفقیت پس از افزودن به لایتنر', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(mockVocabularyModel));

    // Simulate LitnerBloc success state
    when(() => mockLitnerBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([CreateWordSuccess(mockCreateWordModel)]));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // We need to trigger the listener manually or ensure stream is listened to.
    // Since we provided the mockBloc to BlocProvider, BlocListener should listen.
    // However, usually we need to emit the state AFTER the listener is set up.
    // The current setup emits immediately upon subscription.
    // Let's verify if the SnackBar is shown.
    // If it fails, we might need to use a StreamController or delay the emission.

    // Assert
    expect(find.text('لغت به لایتنر اضافه شد'), findsOneWidget);
  });

  testWidgets('نمایش پیام خطا در صورت عدم دریافت اطلاعات', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    const errorMessage = "خطا در دریافت اطلاعات";
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataFailed(errorMessage));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('نمایش پیام خالی بودن لیست', (tester) async {
    tester.view.physicalSize = const Size(2000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Arrange
    final emptyModel = vocabulary_model.VocabularyModel(
        ok: true, meta: vocabulary_model.Meta(), data: []);
    when(() => mockSayarehRepository.fetchVocabulary(any()))
        .thenAnswer((_) async => DataSuccess(emptyModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    // Assert
    expect(find.text('واژگانی یافت نشد'), findsOneWidget);
  });
}
