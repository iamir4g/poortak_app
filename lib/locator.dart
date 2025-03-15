import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
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
}
