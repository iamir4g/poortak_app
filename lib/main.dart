import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poortak/common/blocs/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/my_theme.dart';
import 'package:poortak/featueres/featureMenu/screens/aboutUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/contactUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/faq_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/settings_screen.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/kavoosh_main_screen.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_word_completed_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_word_box_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_words_inprogress_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/edit_profile_screen.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/converstion_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/practice_vocabulary_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/vocabulary_screen.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/test_screen.dart';
import 'package:poortak/l10n/app_localizations.dart';
// import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quizes_cubit/cubit/quizes_cubit.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/first_quiz_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:flutter/widgets.dart'; // For RouteAware
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  await initLocator();

  await locator<TTSService>().initialize();
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()),
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => locator<ThemeCubit>()),
        BlocProvider(
          create: (_) {
            final bloc = ShoppingCartBloc(repository: locator());
            // Load cart data when the app starts
            bloc.add(GetCartEvent());
            return bloc;
          },
        ),
        BlocProvider(create: (_) => locator<LitnerBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorObservers: [routeObserver],
            themeMode: themeState.themeMode,
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
              AboutUsScreen.routeName: (context) => AboutUsScreen(),
              ContactUsScreen.routeName: (context) => ContactUsScreen(),
              SettingsScreen.routeName: (context) => SettingsScreen(),
              FAQScreen.routeName: (context) => FAQScreen(),
              IntroMainWrapper.routeName: (context) => IntroMainWrapper(),
              TestScreen.routeName: (context) => TestScreen(),
              MainWrapper.routeName: (context) => MainWrapper(),
              LessonScreen.routeName: (context) {
                final args = ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          SayarehCubit(sayarehRepository: locator()),
                    ),
                    BlocProvider(
                      create: (context) =>
                          LessonBloc(sayarehRepository: locator()),
                    ),
                  ],
                  child: LessonScreen(
                    index: args['index'],
                    title: args['title'],
                    lessonId: args['lessonId'],
                    purchased: args['purchased'],
                  ),
                );
              },
              LoginScreen.routeName: (context) => LoginScreen(),
              ProfileScreen.routeName: (context) => ProfileScreen(),
              EditProfileScreen.routeName: (context) => BlocProvider(
                    create: (context) => locator<ProfileBloc>(),
                    child: EditProfileScreen(),
                  ),
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
                return ConversationScreen(
                    conversationId: args['conversationId']);
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
              LitnerWordCompletedScreen.routeName: (context) =>
                  LitnerWordCompletedScreen(),
              KavooshMainScreen.routeName: (context) => KavooshMainScreen(),
              PaymentResultScreen.routeName: (context) {
                final args = ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>;
                return PaymentResultScreen(
                  ok: args['status'] is int
                      ? args['status']
                      : int.parse(args['status'].toString()),
                  ref: args['ref'],
                );
              },
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
        },
      )));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       themeMode: ThemeMode.light,
//       theme: MyThemes.lightTheme,
//       darkTheme: MyThemes.darkTheme,
//       initialRoute: "/",
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       locale: const Locale("fa", ""),
//       supportedLocales: const [Locale("en", ""), Locale("fa", "")],
//       routes: {
//         IntroMainWrapper.routeName: (context) => IntroMainWrapper(),
//         TestScreen.routeName: (context) => TestScreen(),
//         MainWrapper.routeName: (context) => MainWrapper(),
//         LessonScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (context) => SayarehCubit(sayarehRepository: locator()),
//               ),
//               BlocProvider(
//                 create: (context) => LessonBloc(sayarehRepository: locator()),
//               ),
//             ],
//             child: LessonScreen(
//               index: args['index'],
//               title: args['title'],
//               lessonId: args['lessonId'],
//               purchased: args['purchased'],
//             ),
//           );
//         },
//         LoginScreen.routeName: (context) => LoginScreen(),
//         ProfileScreen.routeName: (context) => ProfileScreen(),
//         VocabularyScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return VocabularyScreen(id: args['id']);
//         },
//         PracticeVocabularyScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return BlocProvider(
//             create: (context) =>
//                 PracticeVocabularyBloc(sayarehRepository: locator()),
//             child: PracticeVocabularyScreen(courseId: args['courseId']),
//           );
//         },
//         ConversationScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return ConversationScreen(conversationId: args['conversationId']);
//         },
//         QuizzesScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return BlocProvider(
//             create: (context) => QuizesCubit(),
//             child: QuizzesScreen(courseId: args['courseId']),
//           );
//         },
//         FirstQuizScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (context) => QuizStartBloc(locator()),
//               ),
//               BlocProvider(
//                 create: (context) => QuizAnswerBloc(locator()),
//               ),
//               BlocProvider(
//                 create: (context) => QuizResultBloc(locator()),
//               ),
//             ],
//             child: FirstQuizScreen(
//               quizId: args['quizId'],
//               courseId: args['courseId'],
//               title: args['title'],
//             ),
//           );
//         },
//         QuizScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (context) => QuizStartBloc(locator()),
//               ),
//               BlocProvider(
//                 create: (context) => QuizAnswerBloc(locator()),
//               ),
//               BlocProvider(
//                 create: (context) => QuizResultBloc(locator()),
//               ),
//             ],
//             child: QuizScreen(
//               quizId: args['quizId'],
//               courseId: args['courseId'],
//               title: args['title'],
//               initialQuestion: args['initialQuestion'],
//             ),
//           );
//         },
//         LitnerWordsInprogressScreen.routeName: (context) =>
//             LitnerWordsInprogressScreen(),
//         LitnerWordBoxScreen.routeName: (context) => LitnerWordBoxScreen(),
//         PaymentResultScreen.routeName: (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>;
//           return PaymentResultScreen(
//             ok: args['status'],
//             ref: args['ref'],
//           );
//         },
//       },

//       debugShowCheckedModeBanner: false,
//       title: 'Poortak',

//       // actions: <Widget>[
//       //   IconButton(
//       //     onPressed: () {},
//       //     icon: Icon(Icons.search),
//       //   ),
//       // ],
//       home: DeepLinkHandler(), //SplashScreen()
//     );
//   }
// }
