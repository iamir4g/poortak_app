# AuthService

`AuthService` یک utility class است که برای مدیریت درخواست‌های API احراز هویت شده استفاده می‌شود.

## ویژگی‌ها

- **مدیریت خودکار Token**: به صورت خودکار token کاربر را از preferences دریافت می‌کند
- **تنظیم Header**: Authorization header را به صورت خودکار تنظیم می‌کند
- **مدیریت خطا**: خطاهای 401/404 را مدیریت کرده و token را پاک می‌کند
- **Logging**: تمام مراحل را لاگ می‌کند
- **متدهای HTTP**: متدهای GET, POST, PUT, PATCH, DELETE را پشتیبانی می‌کند

## نحوه استفاده

### 1. استفاده مستقیم از AuthService

```dart
class MyApiProvider {
  final AuthService _authService;

  MyApiProvider({required Dio dio})
      : _authService = locator<AuthService>();

  Future<Response> getData() async {
    return await _authService.get('/api/data');
  }

  Future<Response> postData(Map<String, dynamic> data) async {
    return await _authService.post('/api/data', data: data);
  }
}
```

### 2. استفاده از makeAuthenticatedRequest برای درخواست‌های پیچیده

```dart
Future<Response> complexRequest() async {
  return await _authService.makeAuthenticatedRequest(
    () => dio.get('/api/complex-endpoint', queryParameters: {
      'param1': 'value1',
      'param2': 'value2',
    }),
  );
}
```

## مزایای استفاده از AuthService

### قبل از AuthService:

```dart
// کد تکراری در هر API Provider
Future<Response> _makeAuthenticatedRequest(
    Future<Response> Function() request) async {
  final token = await _prefsOperator.getUserToken();
  if (token == null) {
    throw UnauthorisedException(message: 'Please login to continue');
  }

  dio.options.headers['Authorization'] = 'Bearer $token';
  try {
    return await request();
  } on DioException catch (e) {
    if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
      await _prefsOperator.logout();
      throw UnauthorisedException(
          message: 'Session expired. Please login again.');
    }
    rethrow;
  }
}
```

### بعد از AuthService:

```dart
// کد ساده و تمیز
Future<Response> getData() async {
  return await _authService.get('/api/data');
}
```

## تنظیمات

`AuthService` به صورت خودکار در `locator.dart` ثبت شده و در تمام API Provider ها قابل استفاده است.

## مدیریت خطا

- **401/404**: Token پاک شده و `UnauthorisedException` پرتاب می‌شود
- **سایر خطاها**: به صورت عادی پرتاب می‌شوند
- **Logging**: تمام مراحل لاگ می‌شوند

