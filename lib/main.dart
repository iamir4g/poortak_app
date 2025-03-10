import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/blocs/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:poortak/config/my_theme.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  await initLocator();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => SplashCubit()),
    BlocProvider(create: (_) => BottomNavCubit()),
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
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale("fa", ""),
      supportedLocales: [Locale("en", ""), Locale("fa", "")],
      routes: {
        IntroMainWrapper.routeName: (context) => IntroMainWrapper(),
        TestScreen.routeName: (context) => TestScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Poortak',
      home: SplashScreen(),
    );
  }
}
