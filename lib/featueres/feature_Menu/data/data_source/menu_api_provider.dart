import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';

class MenuApiProvider {
  final Dio dio;

  MenuApiProvider({required this.dio});

  /// api/v1/constants/faq
  Future<Response> callGetFaq() async {
    return dio.get("${Constants.baseUrl}constants/faq");
  }

  /// api/v1/constants/contact-us-info
  Future<Response> callGetContactUsInfo() async {
    return dio.get("${Constants.baseUrl}constants/contact-us-info");
  }
}
