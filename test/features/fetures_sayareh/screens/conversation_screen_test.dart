import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/iknow_voice_cache_service.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/feature_sayareh/screens/converstion_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mocks
class MockSayarehRepository extends Mock implements SayarehRepository {}

class MockIKnowVoiceCacheService extends Mock
    implements IKnowVoiceCacheService {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

// Mock Data
final mockConversationList = [
  Datum(
    id: "1",
    text: "Hello",
    translation: "سلام",
    voice: "male",
    voiceFileId: "voice-1",
    voiceChecksum: "checksum-1",
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
    voiceFileId: "voice-2",
    voiceChecksum: "checksum-2",
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
  late MockIKnowVoiceCacheService mockVoiceCache;
  late MockSettingsCubit mockSettingsCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() async {
    mockSayarehRepository = MockSayarehRepository();
    mockVoiceCache = MockIKnowVoiceCacheService();
    mockSettingsCubit = MockSettingsCubit();

    await getIt.reset();

    getIt.registerSingleton<SayarehRepository>(mockSayarehRepository);
    getIt.registerSingleton<IKnowVoiceCacheService>(mockVoiceCache);

    when(() => mockVoiceCache.ensureVoice(
          fileId: any(named: 'fileId'),
          checksum: any(named: 'checksum'),
        )).thenAnswer((_) async => null);
    when(() => mockVoiceCache.prefetchVoices(any()))
        .thenAnswer((_) async {});

    when(() => mockSayarehRepository.saveConversationPlayback(any(), any()))
        .thenAnswer((_) async => DataSuccess(null));

    when(() => mockSayarehRepository.fetchConversationPlayback(any()))
        .thenAnswer((_) async => DataSuccess(null));

    when(() => mockSettingsCubit.state).thenReturn(const SettingsState());
    when(() => mockSettingsCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSettingsCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) {
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
      },
    );
  }

  testWidgets('نمایش لودینگ در ابتدای بارگذاری', (tester) async {
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
      return DataSuccess(mockConversationModel);
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('نمایش پیام‌ها پس از دریافت موفقیت‌آمیز', (tester) async {
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("How are you?"), findsOneWidget);
  });

  testWidgets('نمایش DotLoading هنگام آماده‌سازی ویس', (tester) async {
    when(() => mockVoiceCache.ensureVoice(
          fileId: any(named: 'fileId'),
          checksum: any(named: 'checksum'),
        )).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      return null;
    });
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(DotLoadingWidget), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('نمایش پیام خطا در صورت بروز مشکل', (tester) async {
    const errorMessage = "خطا در دریافت اطلاعات";
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataFailed(errorMessage));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('نمایش پیام خالی وقتی مکالمه‌ای نیست', (tester) async {
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer(
      (_) async => DataSuccess(
        ConversationModel(ok: true, meta: Meta(), data: const []),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('مکالمه‌ای یافت نشد'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('آیتم غیرفعال از لیست مکالمه حذف می‌شود', (tester) async {
    final now = DateTime.now();
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer(
      (_) async => DataSuccess(
        ConversationModel(
          ok: true,
          meta: Meta(),
          data: [
            Datum(
              id: "1",
              text: "Hello",
              translation: "سلام",
              voice: "male",
              order: 1,
              createdAt: now,
              updatedAt: now,
              disabledAt: null,
              courseId: "course1",
            ),
            Datum(
              id: "2",
              text: "Disabled line",
              translation: "غیرفعال",
              voice: "female",
              order: 2,
              createdAt: now,
              updatedAt: now,
              disabledAt: now.toIso8601String(),
              courseId: "course1",
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Hello"), findsOneWidget);
    expect(find.text("Disabled line"), findsNothing);
  });

  testWidgets('نمایش خطای دسترسی وقتی مکالمه خریداری نشده', (tester) async {
    const errorMessage = "برای مشاهده مکالمه باید این درس را خریده باشید.";
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer(
      (_) async => DataFailed(errorMessage, errorCode: 'forbidden'),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text(errorMessage), findsWidgets);
  });

  testWidgets('ترجمه به صورت پیش‌فرض نمایش داده می‌شود', (tester) async {
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("سلام"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pump();

    expect(find.text("سلام"), findsNothing);
  });

  testWidgets('دکمه پخش بعد از آماده شدن ویس‌ها نمایش داده می‌شود',
      (tester) async {
    when(() => mockSayarehRepository.fetchSayarehConversation(any()))
        .thenAnswer((_) async => DataSuccess(mockConversationModel));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    verify(() => mockVoiceCache.ensureVoice(
          fileId: any(named: 'fileId'),
          checksum: any(named: 'checksum'),
        )).called(greaterThanOrEqualTo(1));
  });
}
