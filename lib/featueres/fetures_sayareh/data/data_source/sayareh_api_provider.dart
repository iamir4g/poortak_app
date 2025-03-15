import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';

class SayarehApiProvider {
  Dio dio;
  SayarehApiProvider({required this.dio});

  dynamic callSayarehApi() async {
    final response = await dio.get("${Constants.baseUrl}/sayareh");
  }
}
