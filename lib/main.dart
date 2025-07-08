import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poortak/common/blocs/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/my_theme.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_word_box_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_words_inprogress_screen.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/vocabulary_bloc/vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/practice_vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/test_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quizes_cubit/cubit/quizes_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/first_quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  await initLocator();

  await locator<TTSService>().initialize();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => SplashCubit()),
    BlocProvider(create: (_) => BottomNavCubit()),
    BlocProvider(
      create: (_) {
        final bloc = ShoppingCartBloc(repository: locator());
        // Load cart data when the app starts
        bloc.add(GetCartEvent());
        return bloc;
      },
    ),
    BlocProvider(create: (_) => locator<LitnerBloc>()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      initialRoute: "/",
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale("fa", ""),
      supportedLocales: const [Locale("en", ""), Locale("fa", "")],
      routes: {
        IntroMainWrapper.routeName: (context) => IntroMainWrapper(),
        TestScreen.routeName: (context) => TestScreen(),
        MainWrapper.routeName: (context) => MainWrapper(),
        LessonScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SayarehCubit(sayarehRepository: locator()),
              ),
              BlocProvider(
                create: (context) => LessonBloc(sayarehRepository: locator()),
              ),
            ],
            child: LessonScreen(
              index: args['index'],
              title: args['title'],
              lessonId: args['lessonId'],
            ),
          );
        },
        LoginScreen.routeName: (context) => LoginScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        VocabularyScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return VocabularyScreen(id: args['id']);
        },
        PracticeVocabularyScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return BlocProvider(
            create: (context) =>
                PracticeVocabularyBloc(sayarehRepository: locator()),
            child: PracticeVocabularyScreen(courseId: args['courseId']),
          );
        },
        ConversationScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return ConversationScreen(conversationId: args['conversationId']);
        },
        QuizzesScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => QuizesCubit(),
            child: QuizzesScreen(courseId: args['courseId']),
          );
        },
        FirstQuizScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => QuizStartBloc(locator()),
              ),
              BlocProvider(
                create: (context) => QuizAnswerBloc(locator()),
              ),
              BlocProvider(
                create: (context) => QuizResultBloc(locator()),
              ),
            ],
            child: FirstQuizScreen(
              quizId: args['quizId'],
              courseId: args['courseId'],
              title: args['title'],
            ),
          );
        },
        QuizScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => QuizStartBloc(locator()),
              ),
              BlocProvider(
                create: (context) => QuizAnswerBloc(locator()),
              ),
              BlocProvider(
                create: (context) => QuizResultBloc(locator()),
              ),
            ],
            child: QuizScreen(
              quizId: args['quizId'],
              courseId: args['courseId'],
              title: args['title'],
              initialQuestion: args['initialQuestion'],
            ),
          );
        },
        LitnerWordsInprogressScreen.routeName: (context) =>
            LitnerWordsInprogressScreen(),
        LitnerWordBoxScreen.routeName: (context) => LitnerWordBoxScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Poortak',

      // actions: <Widget>[
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.search),
      //   ),
      // ],
      home: SplashScreen(),
    );
  }
}
