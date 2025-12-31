import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart'
    as match_model;
import 'package:poortak/featueres/feature_match/data/models/submit_answer_model.dart'
    as submit_model;
import 'package:poortak/featueres/feature_match/screens/match_screen.dart';
import 'package:poortak/featueres/feature_match/presentation/bloc/match_bloc/match_bloc.dart';

class MockMatchBloc extends Mock implements MatchBloc {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockMatchBloc mockMatchBloc;
  late match_model.Match mockMatch;

  setUp(() {
    mockMatchBloc = MockMatchBloc();
    mockMatch = match_model.Match(
      ok: true,
      meta: match_model.Meta(),
      data: match_model.Data(
        match: match_model.MatchClass(
          id: '1',
          name: 'مسابقه تستی',
          question: 'سوال تستی',
          isCaseSensitive: false,
          startsAt: DateTime.now(),
          endsAt: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        answer: null,
      ),
    );

    // Setup default states
    when(() => mockMatchBloc.state).thenReturn(MatchInitial());
    when(() => mockMatchBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MatchBloc>.value(
        value: mockMatchBloc,
        child: const MatchScreen(),
      ),
    );
  }

  testWidgets('نمایش صحیح عناصر UI در حالت اولیه', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('شرکت در مسابقه'), findsOneWidget);
    expect(find.text('سوال این ماه'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('جواب سوال:'), findsOneWidget);
    expect(find.text('ارسال پاسخ'), findsOneWidget);
  });

  testWidgets('نمایش سوال پس از بارگذاری موفق', (WidgetTester tester) async {
    when(() => mockMatchBloc.state).thenReturn(MatchSuccess(match: mockMatch));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('سوال تستی'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('نمایش خطا در صورت عدم موفقیت', (WidgetTester tester) async {
    when(() => mockMatchBloc.state)
        .thenReturn(MatchError(message: 'خطای تستی'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('خطا در بارگذاری سوال'), findsOneWidget);
  });

  testWidgets('غیرفعال شدن فیلد پس از ارسال پاسخ', (WidgetTester tester) async {
    final now = DateTime.now();
    final answeredMatch = match_model.Match(
      ok: true,
      meta: match_model.Meta(),
      data: match_model.Data(
        match: match_model.MatchClass(
          id: '1',
          name: 'مسابقه تستی',
          question: 'سوال تستی',
          isCaseSensitive: false,
          startsAt: now,
          endsAt: now.add(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
        answer: match_model.Answer(
          id: '1',
          matchId: '1',
          userId: 'user1',
          answer: 'پاسخ تستی',
          isCorrect: true,
          submittedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );

    when(() => mockMatchBloc.state)
        .thenReturn(MatchSuccess(match: answeredMatch));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
    expect(find.text('شما قبلاً پاسخ داده‌اید'), findsOneWidget);
    expect(find.text('پاسخ ارسال شده'), findsOneWidget);
  });

  testWidgets('ارسال پاسخ با موفقیت', (WidgetTester tester) async {
    when(() => mockMatchBloc.state).thenReturn(MatchSuccess(match: mockMatch));
    when(() => mockMatchBloc.stream).thenAnswer((_) => Stream.value(
          MatchAnswerSubmitted(
            response: submit_model.ResponseSubmitAnswer(
              ok: true,
              meta: submit_model.Meta(),
              data: submit_model.Data(
                id: '1',
                matchId: '1',
                userId: 'user1',
                answer: 'پاسخ تستی',
                isCorrect: true,
                submittedAt: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
          ),
        ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Enter answer
    await tester.enterText(find.byType(TextField), 'پاسخ تستی');
    await tester.tap(find.text('ارسال پاسخ'));
    await tester.pump();

    // Verify event dispatch
    verify(() => mockMatchBloc.add(any(that: isA<SubmitAnswerEvent>())))
        .called(1);

    // Wait for modal
    await tester.pumpAndSettle();
    expect(find.text('پاسخ شما با موفقیت ارسال شد.'), findsOneWidget);
  });

  testWidgets('نمایش خطا برای پاسخ خالی', (WidgetTester tester) async {
    when(() => mockMatchBloc.state).thenReturn(MatchSuccess(match: mockMatch));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.text('ارسال پاسخ'));
    await tester.pump();

    expect(find.text('لطفاً پاسخ خود را وارد کنید'), findsOneWidget);
  });

  testWidgets('به‌روزرسانی شمارش معکوس', (WidgetTester tester) async {
    when(() => mockMatchBloc.state).thenReturn(MatchSuccess(match: mockMatch));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify initial countdown values
    expect(find.text('2'), findsOneWidget); // Days
    expect(find.text('48'), findsOneWidget); // Hours (approx)

    // Fast forward time
    await tester.pump(const Duration(hours: 3));
    expect(find.text('45'), findsOneWidget); // Updated hours
  });
}
