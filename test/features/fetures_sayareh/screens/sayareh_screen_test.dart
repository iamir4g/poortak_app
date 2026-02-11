
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart' as progress_model;
import 'package:poortak/featueres/fetures_sayareh/data/models/book_list_model.dart' as book_model;
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart' as home_model;
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/sayareh_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';

// Mocks
class MockSayarehRepository extends Mock implements SayarehRepository {}

class MockShoppingCartRepository extends Mock
    implements ShoppingCartRepository {}

class MockPrefsOperator extends Mock implements PrefsOperator {}

class MockStorageService extends Mock implements StorageService {}

class MockIknowAccessBloc extends Mock implements IknowAccessBloc {}

class MockShoppingCartBloc extends Mock implements ShoppingCartBloc {}

// Fake Classes
class FakeIknowAccessEvent extends Fake implements IknowAccessEvent {}
class FakeIknowAccessState extends Fake implements IknowAccessState {}
class FakeShoppingCartEvent extends Fake implements ShoppingCartEvent {}
class FakeShoppingCartState extends Fake implements ShoppingCartState {}

void main() {
  late MockSayarehRepository mockSayarehRepository;
  late MockShoppingCartRepository mockShoppingCartRepository;
  late MockPrefsOperator mockPrefsOperator;
  late MockStorageService mockStorageService;
  late MockIknowAccessBloc mockIknowAccessBloc;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeIknowAccessEvent());
    registerFallbackValue(FakeIknowAccessState());
    registerFallbackValue(FakeShoppingCartEvent());
    registerFallbackValue(FakeShoppingCartState());
  });

  setUp(() {
    mockSayarehRepository = MockSayarehRepository();
    mockShoppingCartRepository = MockShoppingCartRepository();
    mockPrefsOperator = MockPrefsOperator();
    mockStorageService = MockStorageService();
    mockIknowAccessBloc = MockIknowAccessBloc();

    // Reset GetIt
    getIt.reset();

    // Register Mocks in GetIt
    getIt.registerSingleton<SayarehRepository>(mockSayarehRepository);
    getIt.registerSingleton<ShoppingCartRepository>(mockShoppingCartRepository);
    getIt.registerSingleton<PrefsOperator>(mockPrefsOperator);
    getIt.registerSingleton<StorageService>(mockStorageService);
    getIt.registerSingleton<IknowAccessBloc>(mockIknowAccessBloc);

    // Setup default behaviors for IknowAccessBloc
    when(() => mockIknowAccessBloc.state).thenReturn(IknowAccessInitial());
    when(() => mockIknowAccessBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockIknowAccessBloc.add(any())).thenReturn(null);
    when(() => mockIknowAccessBloc.close()).thenAnswer((_) async {});
    when(() => mockIknowAccessBloc.hasCourseAccess(any())).thenReturn(false);
    when(() => mockIknowAccessBloc.hasBookAccess(any())).thenReturn(false);

    // Setup default behaviors for PrefsOperator
    when(() => mockPrefsOperator.isLoggedIn()).thenReturn(true);

    // Setup default behaviors for StorageService
    when(() => mockStorageService.callGetDownloadPublicUrl(any()))
        .thenAnswer((_) async => "http://example.com/image.jpg");
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
        Locale('fa'), // Persian
        Locale('en'), // English
      ],
      locale: const Locale('fa'),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: SayarehScreen(),
        ),
      ),
    );
  }

  // --- Helpers for Data Generation ---
  home_model.SayarehHomeModel _getEmptySayarehHomeModel() {
    return home_model.SayarehHomeModel(
      ok: true,
      meta: home_model.Meta(),
      data: [],
    );
  }

  book_model.GetBookListModel _getEmptyBookListModel() {
    return book_model.GetBookListModel(
      ok: true,
      meta: book_model.Meta(),
      data: [],
    );
  }

  progress_model.AllCoursesProgressModel _getEmptyProgressModel() {
    return progress_model.AllCoursesProgressModel(
      ok: true,
      meta: home_model.Meta(),
      data: [],
    );
  }

  testWidgets('نمایش لودینگ در ابتدای ورود به صفحه', (tester) async {
    // Arrange
    final completer = Completer<DataState<home_model.SayarehHomeModel>>();
    
    // Delay the future to simulate network request and keep it in loading state
    when(() => mockSayarehRepository.fetchAllCourses()).thenAnswer(
        (_) => completer.future);
    when(() => mockSayarehRepository.fetchBookList()).thenAnswer(
        (_) async => DataSuccess(_getEmptyBookListModel()));
    when(() => mockSayarehRepository.fetchAllCoursesProgress()).thenAnswer(
        (_) async => DataSuccess(_getEmptyProgressModel()));
    
    // Mock Shopping Cart getCart
    when(() => mockShoppingCartRepository.getCart()).thenAnswer((_) async => ShoppingCart());


    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start animations/futures
    // Do NOT pumpAndSettle here, because we want to see the loading state while the future is pending.

    // Assert
    // We expect to verify we are in loading state.
    expect(find.text("کتاب های سیاره آی نو"), findsNothing);
    
    // Cleanup
    completer.complete(DataSuccess(_getEmptySayarehHomeModel()));
    await tester.pumpAndSettle();
  });
  
  testWidgets('نمایش خطا در صورت بروز مشکل در دریافت اطلاعات', (tester) async {
    // Arrange
    const errorMessage = "خطا در برقراری ارتباط";
    when(() => mockSayarehRepository.fetchAllCourses()).thenAnswer(
        (_) async => DataFailed(errorMessage));
    when(() => mockSayarehRepository.fetchBookList()).thenAnswer(
            (_) async => DataSuccess(_getEmptyBookListModel()));
    when(() => mockSayarehRepository.fetchAllCoursesProgress()).thenAnswer(
            (_) async => DataSuccess(_getEmptyProgressModel()));

    when(() => mockShoppingCartRepository.getCart()).thenAnswer((_) async => ShoppingCart());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for all animations and futures

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text("تلاش دوباره"), findsOneWidget);
  });

  testWidgets('نمایش لیست درس‌ها و کتاب‌ها پس از دریافت موفقیت‌آمیز', (tester) async {
    // Arrange
    final lesson = home_model.Lesson(
      id: "1",
      name: "درس اول",
      description: "توضیحات درس اول",
      thumbnail: "thumb.jpg",
      price: "1000",
      purchased: false,
      trailerVideo: "",
      isDemo: false,
      order: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );
    
    final book = book_model.BookList(
        id: "101", 
        title: "کتاب اول", 
        order: 1, 
        thumbnail: "book.jpg", 
        price: "5000", 
        pageCount: 100, 
        publishDate: "2023", 
        file: "book.pdf", 
        createdAt: DateTime.now(), 
        updatedAt: DateTime.now(), 
        purchased: false
    );

    final homeModel = home_model.SayarehHomeModel(
      ok: true,
      meta: home_model.Meta(),
      data: [lesson],
    );

    final bookModel = book_model.GetBookListModel(
      ok: true,
      meta: book_model.Meta(),
      data: [book],
    );

    when(() => mockSayarehRepository.fetchAllCourses()).thenAnswer(
        (_) async => DataSuccess(homeModel));
    when(() => mockSayarehRepository.fetchBookList()).thenAnswer(
        (_) async => DataSuccess(bookModel));
    when(() => mockSayarehRepository.fetchAllCoursesProgress()).thenAnswer(
        (_) async => DataSuccess(_getEmptyProgressModel()));
    
    when(() => mockShoppingCartRepository.getCart()).thenAnswer((_) async => ShoppingCart());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 
    await tester.pump(const Duration(seconds: 2)); // Wait for futures to complete and UI to update

    // Assert
    expect(find.text("درس اول"), findsOneWidget);
    expect(find.text("کتاب اول"), findsOneWidget);
    expect(find.text("کتاب های سیاره آی نو"), findsOneWidget);
  });
}
