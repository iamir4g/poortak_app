import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:poortak/common/bloc/storage/storage_bloc.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
