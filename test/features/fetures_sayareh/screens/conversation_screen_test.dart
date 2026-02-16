
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mocks
class MockSayarehRepository extends Mock implements SayarehRepository {}

class MockTTSService extends Mock implements TTSService {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

// Mock Data
final mockConversationList = [
  Datum(
    id: "1",
    text: "Hello",
    translation: "سلام",
    voice: "male",
    order: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    disabledAt: null,
    courseId: "course1",
  ),
  Datum(
    id: "2",
    text: "How are you?",
    translation: "حالت چطور است؟",
    voice: "female",
    order: 2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    disabledAt: null,
    courseId: "course1",
  ),
];

final mockConversationModel = ConversationModel(
  ok: true,
  meta: Meta(),
  data: mockConversationList,
);

void main() {
  late MockSayarehRepository mockSayarehRepository;
  late MockTTSService mockTTSService;
  late MockSettingsCubit mockSettingsCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() async {
    mockSayarehRepository = MockSayarehRepository();
    mockTTSService = MockTTSService();
    mockSettingsCubit = MockSettingsCubit();

    // Reset GetIt
    await getIt.reset();

    // Register Mocks
    getIt.registerSingleton<SayarehRepository>(mockSayarehRepository);
    getIt.registerSingleton<TTSService>(mockTTSService);

    // Default Behaviors
    when(() => mockTTSService.speak(any(), voice: any(named: 'voice')))
        .thenAnswer((_) async {});
    when(() => mockTTSService.stop()).thenAnswer((_) async {});
    when(() => mockTTSService.setMaleVoice()).thenAnswer((_) async {});
    when(() => mockTTSService.setFemaleVoice()).thenAnswer((_) async {});
    
    // Mock save playback
    when(() => mockSayarehRepository.saveConversationPlayback(any(), any()))
        .thenAnswer((_) async => DataSuccess(null));
        
    // Mock fetch playback
    when(() => mockSayarehRepository.fetchConversationPlayback(any()))
        .thenAnswer((_) async => DataSuccess(null));

    // Mock SettingsCubit
    when(() => mockSettingsCubit.state).thenReturn(const SettingsState());
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSettingsCubit.close()).thenAnswer((_) async {});
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
      home: BlocProvider<SettingsCubit>.value(
        value: mockSettingsCubit,
        child: const ConversationScreen(conversationId: "course1"),
      ),
    );
  }

  testWidgets('نمایش لودینگ در ابتدای بارگذاری', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(seconds: 1));
          return DataSuccess(mockConversationModel);
        });

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start fetching

    // Assert
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    
    // Finish pending timer
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('نمایش پیام‌ها پس از دریافت موفقیت‌آمیز', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data

    // Assert
    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("How are you?"), findsOneWidget);
  });

  testWidgets('نمایش پیام خطا در صورت بروز مشکل', (tester) async {
    // Arrange
    const errorMessage = "خطا در دریافت اطلاعات";
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataFailed(errorMessage));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('پخش صدای پیام با کلیک روی آن', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data

    // Tap on the first message
    await tester.tap(find.text("Hello"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200)); // Wait for delay

    // Assert
    // "Hello" has voice "male"
    verify(() => mockTTSService.setMaleVoice()).called(1);
    verify(() => mockTTSService.speak("Hello")).called(1);
  });

  testWidgets('نمایش ترجمه با کلیک روی دکمه ترجمه', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data

    // Tap translate button
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pump();

    // Check if "سلام" is visible/found.
    expect(find.text("سلام"), findsOneWidget);
  });

  testWidgets('پخش تمام مکالمه با دکمه پخش', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data

    // Find play button (Icon: play_circle)
    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();
    
    // Wait for delays in playAllConversations
    // 1st msg: delay 100ms (voice set) + speak + delay 500ms
    // 2nd msg: delay 100ms + speak + delay 500ms
    // Total approx 1.2s + speak time.
    await tester.pump(const Duration(milliseconds: 2000));
    
    // Assert
    verify(() => mockTTSService.setMaleVoice()).called(1); // For "Hello"
    verify(() => mockTTSService.speak("Hello")).called(1);
  });
  
  testWidgets('رفتن به پیام بعدی', (tester) async {
    // Arrange
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1)); // Wait for data
    
    // Find Next button
    final iconButtons = find.byType(IconButton);
    // 0: AppBar
    // 1: Translate
    // 2: Next
    // 3: Play
    // 4: Prev
    
    await tester.tap(iconButtons.at(2)); // Next
    await tester.pump();
    
    // Tap play to check current index
    await tester.tap(iconButtons.at(3)); // Play
    await tester.pump(const Duration(milliseconds: 1000));
    
    // Assert
    verify(() => mockTTSService.setFemaleVoice()).called(1); // For "How are you?"
    verify(() => mockTTSService.speak("How are you?")).called(1);
  });
}
