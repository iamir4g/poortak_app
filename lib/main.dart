import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poortak/common/blocs/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/my_theme.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_cubit.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/test_screen.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  await initLocator();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => SplashCubit()),
    BlocProvider(create: (_) => BottomNavCubit()),
    BlocProvider(
      create: (_) {
        final cubit = ShoppingCartCubit(shoppingCartRepository: locator());
        // Load cart data when the app starts
        cubit.getCart();
        return cubit;
      },
    ),
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
          return LessonScreen(
            index: args['index'],
            title: args['title'],
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
  }
}
