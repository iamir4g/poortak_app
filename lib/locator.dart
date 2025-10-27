import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_litner/data/data_source/litner_api_provider.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/repositories/litner_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/vocabulary_bloc/vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/featueres/feature_match/presentation/bloc/match_bloc/match_bloc.dart';
import 'package:poortak/featueres/feature_match/data/data_source/match_api_provider.dart';
import 'package:poortak/featueres/feature_match/repositories/match_repository.dart';

GetIt locator = GetIt.instance;

Future<void> initLocator() async {
  final dio = Dio();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerSingleton<PrefsOperator>(PrefsOperator());

  final prefsOperator = locator<PrefsOperator>();

  // Add interceptor to set x-lang header and authorization token
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Set x-lang header for all requests
      options.headers['x-lang'] =
          'fa'; // You can change 'en' to your desired language code

      // Add authorization token if available
      final token = await prefsOperator.getUserToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    },
  ));

  locator.registerSingleton<Dio>(dio);

  // Register StorageService
  locator.registerSingleton<StorageService>(StorageService(dio: locator()));

  // Register TTSService
  locator.registerSingleton<TTSService>(TTSService());

  // Register AuthService
  locator.registerSingleton<AuthService>(AuthService(dio: locator()));

  //api provider
  locator.registerSingleton<SayarehApiProvider>(
      SayarehApiProvider(dio: locator()));
  locator.registerSingleton<ProfileApiProvider>(
      ProfileApiProvider(dio: locator()));
  locator
      .registerSingleton<LitnerApiProvider>(LitnerApiProvider(dio: locator()));
  locator.registerSingleton<ShoppingCartApiProvider>(
      ShoppingCartApiProvider(dio: locator()));
  locator.registerSingleton<MatchApiProvider>(MatchApiProvider(locator()));

  //repository
  locator.registerSingleton<SayarehRepository>(SayarehRepository(locator()));
  locator.registerSingleton<ShoppingCartRepository>(
      ShoppingCartRepository(apiProvider: locator()));
  locator.registerSingleton<ProfileRepository>(ProfileRepository(locator()));
  locator.registerSingleton<ProfileBloc>(ProfileBloc(repository: locator()));
  locator.registerSingleton<LitnerRepository>(LitnerRepository(locator()));
  locator.registerSingleton<MatchRepository>(MatchRepository(locator()));
  locator.registerSingleton<BlocStorageBloc>(
      BlocStorageBloc(sayarehRepository: locator()));
  locator.registerSingleton<IknowAccessBloc>(
      IknowAccessBloc(sayarehRepository: locator()));
  locator
      .registerSingleton<LessonBloc>(LessonBloc(sayarehRepository: locator()));
  locator.registerSingleton<ConverstionBloc>(
      ConverstionBloc(sayarehRepository: locator()));
  locator.registerSingleton<VocabularyBloc>(
      VocabularyBloc(sayarehRepository: locator()));
  locator
      .registerSingleton<LitnerBloc>(LitnerBloc(litnerRepository: locator()));
  locator
      .registerFactory<MatchBloc>(() => MatchBloc(matchRepository: locator()));

  // Register ShoppingCartBloc
  locator.registerSingleton<ShoppingCartBloc>(
      ShoppingCartBloc(repository: locator()));

  // Register PermissionBloc
  locator.registerSingleton<PermissionBloc>(PermissionBloc());

  // Register Quiz Blocs
  locator.registerFactory<QuizStartBloc>(() => QuizStartBloc(locator()));
  locator.registerFactory<QuizAnswerBloc>(() => QuizAnswerBloc(locator()));
  locator.registerFactory<QuizResultBloc>(() => QuizResultBloc(locator()));

  // Register ThemeCubit
  locator.registerSingleton<ThemeCubit>(ThemeCubit());

  // Register SettingsCubit
  locator.registerSingleton<SettingsCubit>(SettingsCubit());
}
