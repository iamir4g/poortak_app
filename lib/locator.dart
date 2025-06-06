import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:poortak/common/bloc/storage/storage_bloc.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/lesson_bloc/lesson_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/vocabulary_bloc/vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_start_bloc/quiz_start_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_answer_bloc/quiz_answer_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/quiz_result_bloc/quiz_result_bloc.dart';

GetIt locator = GetIt.instance;

Future<void> initLocator() async {
  final dio = Dio();

  // Add interceptor to set x-lang header
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Set x-lang header for all requests
      options.headers['x-lang'] =
          'fa'; // You can change 'en' to your desired language code
      return handler.next(options);
    },
  ));

  locator.registerSingleton<Dio>(dio);

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);
  locator.registerSingleton<PrefsOperator>(PrefsOperator());

  // Register StorageService
  locator.registerSingleton<StorageService>(StorageService(dio: locator()));

  // Register TTSService
  locator.registerSingleton<TTSService>(TTSService());

  //api provider
  locator.registerSingleton<SayarehApiProvider>(
      SayarehApiProvider(dio: locator()));
  locator.registerSingleton<ProfileApiProvider>(
      ProfileApiProvider(dio: locator()));

  //repository
  locator.registerSingleton<SayarehRepository>(SayarehRepository(locator()));
  locator.registerSingleton<ShoppingCartRepository>(ShoppingCartRepository());
  locator.registerSingleton<ProfileRepository>(ProfileRepository(locator()));
  locator.registerSingleton<BlocStorageBloc>(
      BlocStorageBloc(sayarehRepository: locator()));
  locator
      .registerSingleton<LessonBloc>(LessonBloc(sayarehRepository: locator()));
  locator.registerSingleton<ConverstionBloc>(
      ConverstionBloc(sayarehRepository: locator()));
  locator.registerSingleton<VocabularyBloc>(
      VocabularyBloc(sayarehRepository: locator()));
  // Register PermissionBloc
  locator.registerSingleton<PermissionBloc>(PermissionBloc());

  // Register Quiz Blocs
  locator.registerFactory<QuizStartBloc>(() => QuizStartBloc(locator()));
  locator.registerFactory<QuizAnswerBloc>(() => QuizAnswerBloc(locator()));
  locator.registerFactory<QuizResultBloc>(() => QuizResultBloc(locator()));
}
